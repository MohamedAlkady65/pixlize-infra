declare -A app_topic
app_topic[name]="$prefix-app-topic"

function create_sns_topic(){
    # $1 topic_name

    echo "Create $1 topic ..."

    if ! check_exists=$(
        aws sns list-topics \
            --region $region \
            --query "Topics[?contains(TopicArn, '$1')] | [0].TopicArn" \
            --output text
        ); 
    then
        echo "Error while creating topic"
        exit 1
    fi
    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Topic is already exists"
        rt="$check_exists"
        echo "$rt"
        return 0
    fi


    if ! arn=$(aws sns create-topic \
                    --name "$1" \
                    --region $region \
                    --tags "Key=Env,Value=$env" "Key=App,Value=$app" \
                    --query "TopicArn" \
                    --output text ); 
    then
        echo "Error while creating topic"
        exit 1
    fi

    echo "Topic $1 is created successfully"
    rt="$arn"
    echo "$rt"
}


create_sns_topic "${app_topic[name]}"
app_topic[arn]="$rt"
print_sperator
