declare -A app_front_distribution;

declare -A app_bucket_distribution;


function create_distribution(){
    # $1 domain
    # $2 origin_domain
    # $3 origin_id
    # $4 origin_item
    # $5 certificate_arn

    echo "Create $1 distribution ..."
    
    if ! check_exists=$(
            aws cloudfront list-distributions \
            --query "DistributionList.Items[?contains(Aliases.Items, '$1')] | [0] "\
            --output json
        ); 
    then
        echo "Error while distribution"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        domain_dist=$(echo "$check_exists" | jq -r ".DomainName")
        arn=$(echo "$check_exists" | jq -r ".ARN")
        echo "Distribution is already exists"
        echo "$domain_dist"
        echo "$arn"
        rt1="$domain_dist"
        rt2="$arn"
        return 0
    fi


    time=$(date -u +"%Y-%m-%d-%H-%M-%S")
    config=$(cat << EOF 
    {
        "CallerReference": "$time",
        "Comment": "",
        "Enabled": true,
        "Aliases": {
            "Quantity": 1,
            "Items": ["$1"]
        },
        "Origins": {
            "Quantity": 1,
            "Items": [
                $4
            ]
        },
        "DefaultCacheBehavior": {
            "TargetOriginId": "$3",
            "ViewerProtocolPolicy": "redirect-to-https",
            "MinTTL": 0,
            "DefaultTTL": 300,
            "MaxTTL": 3600,
            "ForwardedValues": {
                "QueryString": false,
                "Cookies": { "Forward": "none" },
                "Headers": {
                    "Quantity": 1,
                    "Items": ["Cache-Control"]
                }
            },    
            "AllowedMethods": {
                    "Quantity": 7,
                    "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
                    "CachedMethods": {
                        "Quantity": 2,
                        "Items": ["GET", "HEAD"]
                    }
                }
        },
        "ViewerCertificate": {
            "ACMCertificateArn": "$5",
            "SSLSupportMethod": "sni-only",
            "MinimumProtocolVersion": "TLSv1.2_2021"
        }
    }
EOF
    )


    if ! dist=$(aws cloudfront create-distribution \
        --distribution-config "$config" \
        --query "Distribution" \
        --output json); 
    then
        echo "Error while distribution"
        exit 1
    fi

    domain_dist=$(echo "$dist" | jq -r ".DomainName")
    arn=$(echo "$dist" | jq -r ".ARN")
    echo "Distribution created successfully"
    echo "$domain_dist"
    echo "$arn"
    rt1="$domain_dist"
    rt2="$arn"
}


function create_origin_access_control(){
    # $1 name
    # $2 type

    echo "Create $1 origin access control ..."
    
    if ! check_exists=$(
            aws cloudfront list-origin-access-controls \
            --query "OriginAccessControlList.Items[?Name == '$1'] | [0].Id "\
            --output text
        ); 
    then
        echo "Error while create origin access control"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        id="$check_exists"
        echo "Origin access control is already exists"
        echo "$id"
        rt="$id"
        return 0
    fi

    config=$(cat << EOF
    {
            "Name": "$1",
            "SigningProtocol": "sigv4",
            "SigningBehavior": "always",
            "OriginAccessControlOriginType": "$2"
    }
EOF
)

    if ! id=$(aws cloudfront create-origin-access-control \
          --origin-access-control-config "$config" \
        --query "OriginAccessControl.Id" \
        --output text); 
    then
        echo "Error while create origin access control"
        exit 1
    fi

    echo "Origin access control created successfully"
    echo "$id"
    rt="$id"
}


app_front_distribution[domain]="$app_system_domain"
app_front_distribution[origin_domain]="$app_front_domain"
app_front_distribution[origin_id]="$prefix-app-front-dist-origin"
app_front_distribution[certificate_arn]="${app_system_certificate[arn]}"
app_front_distribution[origin_item]=$(cat << EOF
{
    "Id": "${app_front_distribution[origin_id]}",
    "DomainName": "${app_front_distribution[origin_domain]}",
    "CustomOriginConfig": {
        "HTTPPort": 80,
        "HTTPSPort": 443,
        "OriginProtocolPolicy": "https-only"
    }
}
EOF
)

create_distribution "${app_front_distribution[domain]}" "${app_front_distribution[origin_domain]}" "${app_front_distribution[origin_id]}" "${app_front_distribution[origin_item]}" "${app_front_distribution[certificate_arn]}"
app_front_distribution[domain_dist]="$rt1"
app_front_distribution[arn]="$rt2"

print_sperator

change=$(cat <<EOF
{
    "Name": "$app_system_domain",
    "Type": "A",
    "AliasTarget": {
        "HostedZoneId": "Z2FDTNDATAQYW2",
        "DNSName": "${app_front_distribution[domain_dist]}",
        "EvaluateTargetHealth": false
    }
}
EOF
)

create_dns_record "$app_system_domain" "$hosted_zone_id" "$change"

print_sperator


app_bucket_distribution[domain]="$app_bucket_domain"
app_bucket_distribution[origin_domain]="${app_bucket[domain]}"
app_bucket_distribution[origin_id]="$prefix-app-bucket-dist-origin"
app_bucket_distribution[certificate_arn]="${app_bucket_certificate[arn]}"
app_bucket_distribution[origin_access_control_name]="$prefix-app-bucket-dist-origin-access-control"
app_bucket_distribution[origin_access_control_type]="s3"

create_origin_access_control "${app_bucket_distribution[origin_access_control_name]}" "${app_bucket_distribution[origin_access_control_type]}" 
app_bucket_distribution[origin_access_control_id]="$rt"

app_bucket_distribution[origin_item]=$(cat << EOF
{
    "Id": "${app_bucket_distribution[origin_id]}",
    "DomainName": "${app_bucket_distribution[origin_domain]}",
    "S3OriginConfig": {
        "OriginAccessIdentity": ""
    },
    "OriginAccessControlId": "${app_bucket_distribution[origin_access_control_id]}"
}
EOF
)

print_sperator

create_distribution "${app_bucket_distribution[domain]}" "${app_bucket_distribution[origin_domain]}" "${app_bucket_distribution[origin_id]}" "${app_bucket_distribution[origin_item]}" "${app_bucket_distribution[certificate_arn]}"
app_bucket_distribution[domain_dist]="$rt1"
app_bucket_distribution[arn]="$rt2"

print_sperator

change=$(cat <<EOF
{
    "Name": "$app_bucket_domain",
    "Type": "A",
    "AliasTarget": {
        "HostedZoneId": "Z2FDTNDATAQYW2",
        "DNSName": "${app_bucket_distribution[domain_dist]}",
        "EvaluateTargetHealth": false
    }
}
EOF
)

create_dns_record "$app_bucket_domain" "$hosted_zone_id" "$change"

print_sperator

policy=$(cat <<EOF
{
	"Version": "2008-10-17",
	"Id": "PolicyForCloudFrontPrivateContent",
	"Statement": [
		{
			"Sid": "AllowCloudFrontServicePrincipal",
			"Effect": "Allow",
			"Principal": {
				"Service": "cloudfront.amazonaws.com"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${app_bucket[name]}/*",
			"Condition": {
				"ArnLike": {
					"AWS:SourceArn": "${app_bucket_distribution[arn]}"
				}
			}
		}
	]
}
EOF
)

put_bucket_policy "${app_bucket[name]}" "$policy"

print_sperator