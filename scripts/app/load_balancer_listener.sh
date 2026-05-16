function create_listener(){
    # $1 elb_arn
    # $2 port
    # $3 tg_arn

    echo "Create listener $1 to $3 ..."

    if ! output=$(
        aws elbv2 create-listener \
            --load-balancer-arn "$1" \
            --protocol TCP \
            --port "$2" \
            --default-actions "Type=forward,TargetGroupArn=$3" \
            --output text
        ); 
    then
        echo "Error while creating listener"
        exit 1
    fi
    

    echo "Listener is created successfully"
}


create_listener "${app_back_elb[arn]}" "${app_back_elb[port]}" "${app_back_tg[arn]}"

print_sperator

create_listener "${app_front_elb[arn]}" "${app_front_elb[port]}" "${app_front_tg[arn]}"

print_sperator