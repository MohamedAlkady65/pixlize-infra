
source vars_state.sh

function create_hosted_zone(){
    # $1 domain

    echo "Create hosted zone for domain $1 ..."


    if ! check_exists=$(
        aws route53 list-hosted-zones-by-name \
            --region "$region" \
            --dns-name $1 \
            --query "HostedZones[0].Id" \
            --output text
        ); 
    then
        echo "Error while creating hosted zone"
        exit 1
    fi


    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        hosted_zone_id="$check_exists"
        echo "Host zone is already exists"
        echo "$hosted_zone_id"
        rt="$hosted_zone_id"
        return 0
    fi

    time=$(date -u +"%Y-%m-%d-%H-%M-%S")

    if ! hosted_zone_id=$(
        aws route53 create-hosted-zone \
        --region "$region" \
        --name $1 \
        --caller-reference $time \
        --query "HostedZone.Id" \
        --output text); 
    then
        echo "Error while creating hosted zone"
        exit 1
    fi

    echo "Hosted zone for domain $1 is created successfully"
    echo "$hosted_zone_id"
    rt="$hosted_zone_id"

}

create_dns_record()
{
    # $1 domain
    # $2 hosted_zone_id
    # $3 resource_record_set


    echo "Create DNS record for domain $1 ..."


    if ! check_exists=$(
        aws route53 list-resource-record-sets \
            --region "$region" \
            --hosted-zone-id "$2" \
            --query "ResourceRecordSets[?Name == '$1.'] | [0] | Name" \
            --output text
        ); 
    then
        echo "Error while creating DNS record"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "DNS record is already exists"
        return 0
    fi

        change=$(cat << EOF
{
  "Changes": 
  [
    {
      "Action": "CREATE",
      "ResourceRecordSet": $3
    }
  ]
}
EOF
)

    if ! output=$(
        aws route53 change-resource-record-sets \
            --hosted-zone-id "$2" \
            --change-batch "$change" \
            --output text); 
    then
        echo "Error while creating DNS record"
        exit 1
    fi

    echo "DNS record for domain $1 is created successfully"
}


create_hosted_zone "$domain"
hosted_zone_id="$rt"

print_sperator

change=$(cat <<EOF
{
    "Name": "$app_back_domain",
    "Type": "A",
    "AliasTarget": {
        "HostedZoneId": "${app_back_elb[hosted_zone_id]}",
        "DNSName": "${app_back_elb[dns_name]}",
        "EvaluateTargetHealth": false
    }
}
EOF
)

create_dns_record "$app_back_domain" "$hosted_zone_id" "$change"

print_sperator

change=$(cat <<EOF
{
    "Name": "$app_front_domain",
    "Type": "A",
    "AliasTarget": {
        "HostedZoneId": "${app_front_elb[hosted_zone_id]}",
        "DNSName": "${app_front_elb[dns_name]}",
        "EvaluateTargetHealth": false
    }
}
EOF
)

create_dns_record "$app_front_domain" "$hosted_zone_id" "$change"

print_sperator