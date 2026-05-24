declare -A app_back_certificate
app_back_certificate[domain]="$app_back_domain"


declare -A app_front_certificate
app_front_certificate[domain]="$app_front_domain"

declare -A app_system_certificate
app_system_certificate[domain]="$app_system_domain"


function validate_certificate(){
    # $1 certificate_arn
    # $2 try_number

    try_number="$2"

    if [ "$try_number" = "" ];
    then
        echo "Validating certificate ..."
        try_number=1
    fi


    record=$(
        aws acm describe-certificate \
            --certificate-arn "$1" \
            --query "Certificate.DomainValidationOptions[0]"\
            --output "json"
        ); 

    if ! [ $? -eq 0 ] || [ "$record" = "null" ];
    then
            echo "Error while validating certificate"
            exit 1
    fi

    record=$(echo -n "$record" | jq -r ".ResourceRecord")

    if [ "$record" = "null" ];
    then
        try_number="$((try_number+1))"

        if [ $try_number -eq 5 ];
        then
            echo "Error while validating certificate"
            exit 1
        else    
                sleep 10
                validate_certificate "$1" "$try_number"
            return 0
        fi
    fi

    

    name=$(echo -n "$record" | jq -r ".Name")
    type=$(echo -n "$record" | jq -r ".Type")
    value=$(echo -n "$record" | jq -r ".Value")


    change=$(cat <<EOF
{
    "Name": "$name",
    "Type": "$type",
    "TTL": 300,
    "ResourceRecords": [
        {
            "Value": "$value"
        }
    ]
}
EOF
)


    create_dns_record "$name" "$hosted_zone_id" "$change"

    echo "Waiting Validation, this action may take some time ..."

    if ! output=$(
        aws acm  wait  certificate-validated \
            --certificate-arn "$1"
        ); 
    then
        echo "Error while creating certificate"
        exit 1
    fi

    echo "Certificate validated successfully"
}


function create_certificate(){
    # $1 domain
    # $2 certificate_region

    echo "Create $1 certificate ..."

    certificate_region="${2:-$region}"


    if ! check_exists=$(
        aws acm list-certificates \
            --region "$certificate_region" \
            --query "CertificateSummaryList[?DomainName == '$1'] | [0]" \
            --output "json"
        ); 
    then
        echo "Error while creating certificate"
        exit 1
    fi


    check_exists="${check_exists%$'\n'}"
    if [[ "$check_exists" != "null" ]]; then
        echo "Certificate is already exists"
        arn=$(echo -n "$check_exists" | jq -r ".CertificateArn")
        status=$(echo -n "$check_exists" | jq -r ".Status")

        if [[ "$status" = "PENDING_VALIDATION" ]]; then
            validate_certificate "$arn"
        else
            echo "Certificate is already validated"
        fi
        
        rt="$arn"
        echo "$arn"
        return 0
    fi


    if ! arn=$(
        aws acm request-certificate \
            --region "$certificate_region" \
            --domain-name "$1" \
            --validation-method DNS \
            --query "CertificateArn" \
            --tags "Key=Env,Value=$env" "Key=App,Value=$app" \
            --output text
        ); 
    then
        echo "Error while creating certificate"
        exit 1
    fi

    echo "Certificate $1 is created successfully"

    validate_certificate "$arn"

    rt="$arn"
    echo "$arn"
}


create_certificate "${app_back_certificate[domain]}"
app_back_certificate[arn]="$rt"

print_sperator

create_certificate "${app_front_certificate[domain]}"
app_front_certificate[arn]="$rt"

print_sperator

create_certificate "${app_system_certificate[domain]}"
app_system_certificate[arn]="$rt"

print_sperator