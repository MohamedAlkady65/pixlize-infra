declare -p > vars_state.sh

declare -A app_distribution;
app_distribution[domain]="$app_system_domain"
app_distribution[domain_origin]="$app_front_domain"
app_distribution[origin_id]="$prefix-app-dist-origin"
app_distribution[certificate_arn]="${app_system_certificate[arn]}"


function create_distribution_to_https(){
    # $1 domain
    # $2 domain_origin
    # $3 origin_id
    # $4 certificate_arn

    echo "Create $1 distribution ..."
    
    if ! check_exists=$(
            aws cloudfront list-distributions \
            --query "DistributionList.Items[?contains(Aliases.Items, '$1')] | [0].DomainName "\
            --output text
        ); 
    then
        echo "Error while distribution"
        exit 1
    fi

    echo "$check_exists"

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        domain_dist="$check_exists"
        echo "Distribution is already exists"
        echo "$domain_dist"
        rt="$domain_dist"
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
                {
                    "Id": "$3",
                    "DomainName": "$2",
                    "CustomOriginConfig": {
                        "HTTPPort": 80,
                        "HTTPSPort": 443,
                        "OriginProtocolPolicy": "https-only"
                    }
                }
            ]
        },
        "DefaultCacheBehavior": {
            "TargetOriginId": "$3",
            "ViewerProtocolPolicy": "redirect-to-https",
            "MinTTL": 0,
            "ForwardedValues": {
                "QueryString": false,
                "Cookies": { "Forward": "none" }
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
            "ACMCertificateArn": "$4",
            "SSLSupportMethod": "sni-only",
            "MinimumProtocolVersion": "TLSv1.2_2021"
        }
    }
EOF
    )


    if ! domain_dist=$(aws cloudfront create-distribution \
        --distribution-config "$config" \
        --query "Distribution.DomainName" \
        --output text); 
    then
        echo "Error while distribution"
        exit 1
    fi

    echo "Distribution created successfully"
    echo "$domain_dist"
    rt="$domain_dist"
}


app_distribution[domain]="$app_system_domain"
app_distribution[domain_origin]="$app_front_domain"
app_distribution[origin_id]="$prefix-app-dist-origin"
app_distribution[certificate_arn]="${app_system_certificate[arn]}"

create_distribution_to_https "${app_distribution[domain]}" "${app_distribution[domain_origin]}" "${app_distribution[origin_id]}" "${app_distribution[certificate_arn]}"
app_distribution[domain_dist]="$rt"

print_sperator

change=$(cat <<EOF
{
    "Name": "$app_system_domain",
    "Type": "A",
    "AliasTarget": {
        "HostedZoneId": "Z2FDTNDATAQYW2",
        "DNSName": "${app_distribution[domain_dist]}",
        "EvaluateTargetHealth": false
    }
}
EOF
)

create_dns_record "$app_system_domain" "$hosted_zone_id" "$change"

print_sperator