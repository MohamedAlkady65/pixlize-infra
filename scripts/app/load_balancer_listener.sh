function create_tls_listener(){
    # $1 elb_arn
    # $2 port
    # $3 tg_arn
    # $4 certificate_arn

    echo "Create listener $1 to $3 ..."

    if ! output=$(
        aws elbv2 create-listener \
            --load-balancer-arn "$1" \
            --protocol TLS \
            --port "$2" \
            --default-actions "Type=forward,TargetGroupArn=$3" \
            --certificates "CertificateArn=$4" \
            --ssl-policy "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09" \
            --output text
        ); 
    then
        echo "Error while creating listener"
        exit 1
    fi
    

    echo "Listener is created successfully"
}


create_tls_listener "${app_back_elb[arn]}" "${app_back_elb[port]}" "${app_back_tg[arn]}" "${app_back_certificate[arn]}"

print_sperator

create_tls_listener "${app_front_elb[arn]}" "${app_front_elb[port]}" "${app_front_tg[arn]}" "${app_front_certificate[arn]}"

print_sperator