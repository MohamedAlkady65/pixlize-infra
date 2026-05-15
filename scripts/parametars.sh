app_front_config_name="$prefix-app-front-config"
app_back_config_name="$prefix-app-back-config"

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


app_front_config_value=$(cat <<EOF
ENV=
VITE_API_URL=http://localhost:3000
VITE_WS_URL=http://localhost:3000
EOF
)

app_back_config_value=$(cat <<EOF
ENV=
DB_HOST=mysql
DB_PORT=3306
DB_USER=<<DB_USER>>
DB_PASS=<<DB_PASS>>
DB_NAME=pixlize

JWT_SECRET=<<JWT_SECRET>>

AWS_REGION=$region
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_ENDPOINT=http://localstack:4566

S3_BUCKET_NAME=pixlize-images
SQS_QUEUE_URL=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/pixlize-jobs
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:pixlize-notifications
SNS_WEBHOOK_URL=http://backend:3000/webhooks/sns

NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173

EOF
)


create_parametar "$app_front_config_name" "$app_front_config_value"
app_front_config_arn=$rt

print_sperator

create_parametar "$app_back_config_name" "$app_back_config_value"
app_back_config_arn=$rt

print_sperator
