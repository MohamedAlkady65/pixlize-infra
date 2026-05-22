declare -A app_queue
app_queue[name]="$prefix-app-queue"

function create_sqs_queue(){
    # $1 queue_name

    echo "Create $1 queue ..."

    if ! check_exists=$(
        aws sqs list-queues \
            --queue-name-prefix "$1" \
            --region $region \
            --query "QueueUrls[0]" \
            --output text
        ); 
    then
        echo "Error while creating queue"
        exit 1
    fi
    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Queue is already exists"
        url="$check_exists"
    elif ! url=$(aws sqs create-queue \
                    --queue-name "$1" \
                    --region $region \
                    --tags "Env=$env,App=$app" \
                    --query "QueueUrl" \
                    --output text ); 
    then
        echo "Error while creating queue"
        exit 1
    fi

    if ! arn=$(aws sqs get-queue-attributes \
                    --queue-url "$url" \
                    --attribute-names QueueArn \
                    --query "Attributes.QueueArn" \
                    --output text ); 
    then
        echo "Error while creating queue"
        exit 1
    fi

    echo "Queue $1 is created successfully"
    rt1="$url"
    rt2="$arn"
    
    echo "$rt2"
}


create_sqs_queue "${app_queue[name]}"
app_queue[url]="$rt1"
app_queue[arn]="$rt2"
print_sperator
 
