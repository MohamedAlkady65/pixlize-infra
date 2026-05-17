app_front_config_name="$prefix-app-front-config"
app_back_config_name="$prefix-app-back-config"


app_front_config_value=$(cat <<EOF
APP_ENV=$app_env
APP_API_URL=https://$app_back_domain
APP_WS_URL=https://$app_back_domain
EOF
)

app_back_config_value=$(cat <<EOF
ENV=$app_env
PORT=$app_back_port_in_container

DB_USER=<<DB_USER>>
DB_PASS="<<DB_PASS>>"

DB_HOST=${rds_db[host]}
DB_PORT=${rds_db[port]}
DB_NAME=${rds_db[name]}

JWT_SECRET=<<JWT_SECRET>>

AWS_REGION=$region

AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_ENDPOINT=http://localstack:4566

S3_BUCKET_NAME=pixlize-images
SQS_QUEUE_URL=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/pixlize-jobs
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:pixlize-notifications
SNS_WEBHOOK_URL=http://backend:3000/webhooks/sns

FRONTEND_URL=https://$app_front_domain

EOF
)

declare -A app_back_jwt_secret

app_back_jwt_secret[name]="$prefix-app-back-jwt-secret"

function create_parametar(){
    # $1 parametar_name
    # $2 parametar_value

    if ! output=$(
        aws ssm delete-parameters \
            --region $region \
            --names "$1"
        ); 
    then
        echo "Error while creating parametar"
        exit 1
    fi

    if ! output=$(
        aws ssm put-parameter \
            --region $region \
            --name "$1" \
            --value "$2" \
            --type "String" \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app"
        ); 
    then
        echo "Error while creating parametar"
        exit 1
    fi

    if ! arn=$(
        aws ssm get-parameter \
            --region $region \
            --query "Parameter.ARN" \
            --name "$1" \
            --output text
        ); 
    then
        echo "Error while creating parametar"
        exit 1
    fi

    rt=$arn
    echo "Parametar $1 is created successfully"
}

function create_secret(){
    # $1 secret_name
    # $2 secret_value

    echo "Create $1 secret ..."
    
    if ! check_exists=$(
        aws secretsmanager list-secrets \
            --region $region \
            --filter Key="name",Values="$1" \
            --query "SecretList[0].ARN" \
            --output text
        ); 
    then
        echo "Error while creating secret"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        secret_arn="$check_exists"
        echo "Secret is already exists"
        echo "$secret_arn"
        rt="$secret_arn"
        return 0
    fi


    if ! secret_arn=$(
        aws secretsmanager create-secret \
            --region $region \
            --name "$1" \
            --description "$1" \
            --secret-string "$2" \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app"\
            --query "ARN" \
            --output text
    ); 
    then
        echo "Error while creating secret"
        exit 1
    fi

    echo "Secret $1 is created successfully"
    echo "$secret_arn"
    rt="$secret_arn"
}


create_parametar "$app_front_config_name" "$app_front_config_value"
app_front_config_arn=$rt

print_sperator

create_parametar "$app_back_config_name" "$app_back_config_value"
app_back_config_arn=$rt

print_sperator

app_back_jwt_secret_value=$(openssl rand -hex 64)
app_back_jwt_secret_value_json=$( cat <<EOF
{
    "Secret":"$app_back_jwt_secret_value"
}
EOF
)

create_secret "${app_back_jwt_secret[name]}" "$app_back_jwt_secret_value_json"
app_back_jwt_secret[arn]="$rt"

print_sperator