

declare -A app_lambda
app_lambda[name]="$prefix-app-lambda"
app_lambda[runtime]="python3.12"
app_lambda[handler]="handler.lambda_handler"


app_lambda_assume_role_document=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)


declare -A app_lambda_role
app_lambda_role[name]="$prefix-app-lambda-role"
app_lambda_role[attach_policy_arn]="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

app_lambda_role[policy_name]="${app_lambda_role[name]}-policy"

app_lambda_role[policy_document]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S1",
            "Effect": "Allow",
            "Action": "sns:*",
            "Resource": "${app_topic[arn]}"
        },
        {
            "Sid": "S2",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${app_bucket[name]}/*"
        },
        {
            "Sid": "S3",
            "Effect": "Allow",
            "Action": "sqs:*",
            "Resource": "${app_queue[arn]}"
        }
    ]
}
EOF
)



function upload_lambda_code_to_bucket(){
    # $1 repo
    # $2 branch
    # $3 bucket_name

    repo="$1"
    branch="$2"
    lambda_code_bucket_name="$3"
    temp_dir="../temp_lambda"
    output_dir="$temp_dir/output"
    src_dir="$temp_dir/src"
    code_dir="$temp_dir/src/code"
    image_name="lambda_upload_image"
    container_name="lambda_upload_container"

    rm -rf "$temp_dir"

    mkdir -p "$temp_dir"
    mkdir -p "$output_dir"
    mkdir -p "$src_dir"
    mkdir -p "$code_dir"

    echo "Cloning repo ..."
    git clone --branch "$branch" "$repo" "$code_dir"  &> /dev/null

    echo "Copying build files ..."
    cp ./lambda/package_build.sh "$src_dir/build.sh"
    cp ./lambda/package_docker_file "$src_dir/Dockerfile"

    exists=$(docker container ls -a --filter "name=$container_name" --format "{{.Names}}")

    if [[ -n "$exists" ]];then
        docker container rm "$container_name" > /dev/null
    fi

    exists=$(docker image ls "$image_name" --format "{{.ID}}")

    if [[ -n "$exists" ]];then
        docker image rm "$image_name" > /dev/null
    fi

    echo "Building image ..."
    docker build -t "$image_name" "$src_dir" &> /dev/null

    echo "Running container ..."
    docker container run --name "$container_name" -v "$output_dir:/lambda/output" "$image_name" &> /dev/null

    time=$(date -u +"%Y-%m-%d-%H-%M-%S")
    lambda_code_s3_key="lambda_code_$time.zip"
    
    echo "Uploading $lambda_code_s3_key to bucket ..."

    aws s3 cp "$output_dir/lambda.zip" "s3://$lambda_code_bucket_name/$lambda_code_s3_key" > /dev/null

    echo "Cleaning ..."

    docker container rm "$container_name" > /dev/null
    docker image rm "$image_name" > /dev/null
    rm -rf "$temp_dir"

    rt="$lambda_code_s3_key"
    echo "Lambda code uploaded successfully to bucket $lambda_code_bucket_name with key $lambda_code_s3_key"
}
 


function create_lambda_function(){
    # $1 function_name
    # $2 runtime
    # $3 role_arn
    # $4 handler
    # $5 bucket_name
    # $6 bucket_key

    echo "Create $1 lambda function ..."

    if ! check_exists=$(
        aws lambda list-functions \
            --region $region \
            --query "Functions[?FunctionName == '$1'] | [0].FunctionArn" \
            --output text
        ); 
    then
        echo "Error while creating lambda function"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Lambda function is already exists"
        rt="$check_exists"
        echo "$check_exists"
        return 0
    fi


    if ! arn=$(aws lambda create-function \
        --region $region \
        --function-name "$1" \
        --runtime "$2" \
        --role "$3" \
        --handler "$4" \
        --code "S3Bucket=$5,S3Key=$6"\
        --query "FunctionArn" \
        --output text); 
    then
        echo "Error while creating lambda function"
        exit 1
    fi

    if ! output=$(aws lambda wait function-active \
                --region $region \
                --function-name "$1"
                ); 
    then
        echo "Error while creating lambda function"
        exit 1
    fi

    if ! output=$(aws lambda update-function-configuration \
                --region $region \
                --function-name "$1" \
                --environment "$7"); 
    then
        echo "Error while creating lambda function"
        exit 1
    fi

    echo "Lambda function $1 is created successfully"
    rt="$arn"
    echo "$arn"
}


function add_event_trigger_to_lambda_function(){
    # $1 function_name
    # $2 event_arn

    echo "Adding event trigger $2 to $1 lambda function ..."

    if ! check_exists=$(
        aws lambda list-event-source-mappings \
            --region $region \
            --function-name "$1" \
            --event-source-arn "$2" \
            --query "EventSourceMappings[0].UUID" \
            --output text
        ); 
    then
        echo "Error while creating event trigger"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Event trigger is already exists"
        return 0
    fi

    if ! output=$(
            aws lambda create-event-source-mapping \
                --region $region \
                --function-name "$1" \
                --event-source-arn "$2"
        ); 
    then
        echo "Error while adding event trigger"
        exit 1
    fi

    echo "Event trigger $2 is added successfully"
}


upload_lambda_code_to_bucket "git@github.com:MohamedAlkady65/pixlize-lambda.git" "main" "${lambda_code_bucket[name]}"
lambda_code_s3_key="$rt"

print_sperator

create_role "${app_lambda_role[name]}" "${app_lambda_assume_role_document}"
app_lambda_role[id]="$rt1"
app_lambda_role[arn]="$rt2"

print_sperator

attach_policy_to_role "${app_lambda_role[name]}" "${app_lambda_role[attach_policy_arn]}"

print_sperator

put_policy_to_role "${app_lambda_role[name]}" "${app_lambda_role[policy_name]}" "${app_lambda_role[policy_document]}" 

print_sperator

create_lambda_function "${app_lambda[name]}" "${app_lambda[runtime]}" "${app_lambda_role[arn]}" "${app_lambda[handler]}" "${lambda_code_bucket[name]}" "$lambda_code_s3_key" "Variables={MY_AWS_REGION=$region,S3_BUCKET_NAME=${app_bucket[name]},SNS_TOPIC_ARN=${app_topic[arn]}}"
app_lambda[arn]="$rt"

print_sperator

add_event_trigger_to_lambda_function "${app_lambda[name]}" "${app_queue[arn]}"

print_sperator