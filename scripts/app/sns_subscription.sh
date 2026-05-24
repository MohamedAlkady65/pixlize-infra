

function https_topic_subscription(){
    # $1 topic_arn
    # $2 url
    echo "Subscribe https to topic $1"

    count=1
    status=''

    echo "Check app is running before subscribe ..."

    while true; do
        echo "Try $count ..."

        res=$(curl -X POST -d '{"Type": "HealthCheck"}' "$2" 2>/dev/null)
        status=$(echo "$res" | jq -r ".status")

        if [[ $status == "success" ]]; then
            break
        fi

        ((count++))

        if [[ $count -gt 10 ]]; then
            echo "Failed. App is not running"
            exit 1
        fi
        
        sleep 60
    done
    
    if ! output=$(aws sns subscribe \
                    --topic-arn "$1" \
                    --protocol https \
                    --notification-endpoint "$2" \
                    --output json ); 
    then
        echo "Failed to subscribe to topic"
        exit 1
    fi

    echo "Subscription request sent successfully"

    sleep 10

    if ! check_exists=$(aws sns list-subscriptions-by-topic \
            --topic-arn "$1" \
            --query "Subscriptions[?Subscriptions == '$2' && SubscriptionArn != 'PendingConfirmation'] | [0]" \
            --output text ); 
    then
        echo "Failed to subscribe to topic"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Failed to subscribe to topic"
        exit 1
    fi

    echo "Subscription is done successfully"
}




https_topic_subscription "${app_topic[arn]}" "https://$app_back_domain/webhooks/sns"

print_sperator