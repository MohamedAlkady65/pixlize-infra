source vars_state.sh


declare -A app_back_elb
declare -A app_back_tg

app_back_elb[name]="$prefix-back-elb"
app_back_elb[subnets]="${subnet_public_1[id]} ${subnet_public_2[id]}"
app_back_elb[security_group]="${sg_load_balancer_back_end[id]}"
app_back_elb[port]=80

app_back_tg[name]="$prefix-back-tg"
app_back_tg[port]=80

declare -A app_front_elb
declare -A app_front_tg

app_front_elb[name]="$prefix-front-elb"
app_front_elb[subnets]="${subnet_public_1[id]} ${subnet_public_2[id]}"
app_front_elb[security_group]="${sg_load_balancer_front_end[id]}"
app_front_elb[port]=80

app_front_tg[name]="$prefix-front-tg"
app_front_tg[port]=80

function create_load_balancer(){
    # $1 asg_name
    # $2 subnets_ids
    # $3 security_group

    echo "Create $1 load balancer ..."

    check_exists=$(
        aws elbv2 describe-load-balancers \
            --region $region \
            --query "LoadBalancers[0].LoadBalancerArn" \
            --names "$1" \
            --output text 2>&1
        ); 
    if [ $? -eq 0 ]; then
        arn="$check_exists"
        echo "Load balancer is already exists"
        echo "$arn"
        rt="$arn"
        return 0
    elif [[ "$check_exists" != *"LoadBalancerNotFound"* ]]; then
        echo "$check_exists" >&2
        echo "Error while creating load balancer"
        exit 1
    fi

    subnets_ids=($2)

    if ! arn=$(
        aws elbv2 create-load-balancer \
            --region "$region" \
            --name "$1" \
            --type network \
            --scheme internet-facing \
            --subnets "${subnets_ids[@]}" \
            --security-groups "$3" \
            --query "LoadBalancers[0].LoadBalancerArn" \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app" \
            --output text
        ); 
    then
        echo "Error while creating load balancer"
        exit 1
    fi
    


    echo "Load balancer $1 is created successfully"
    echo "$arn"
    rt="$arn"
}

function create_target_group(){
    # $1 tg_name
    # $2 vpc_id
    # $3 port

    echo "Create $1 target group ..."

    check_exists=$(
        aws elbv2 describe-target-groups \
            --region $region \
            --query "TargetGroups[0].TargetGroupArn" \
            --names "$1" \
            --output text 2>&1
        ); 

    if [ $? -eq 0 ]; then
        arn="$check_exists"
        echo "Target group is already exists"
        echo "$arn"
        rt="$arn"
        return 0
    elif [[ "$check_exists" != *"TargetGroupNotFound"* ]]; then
        echo "$check_exists" >&2
        echo "Error while creating target group"
        exit 1
    fi

    if ! arn=$(
        aws elbv2 create-target-group \
            --region "$region" \
            --name $1 \
            --protocol TCP \
            --target-type instance \
            --vpc-id $2 \
            --port $3 \
            --query "TargetGroups[0].TargetGroupArn" \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app" \
            --output text
        ); 
    then
        echo "Error while creating target group"
        exit 1
    fi
    


    echo "Target group $1 is created successfully"
    echo "$arn"
    rt="$arn"
}

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


create_target_group "${app_back_tg[name]}" "$vpc_id" "${app_back_tg[port]}"
app_back_tg[arn]="$rt"

print_sperator


create_load_balancer "${app_back_elb[name]}" "${app_back_elb[subnets]}" "${app_back_elb[security_group]}"
app_back_elb[arn]="$rt"

print_sperator

create_listener "${app_back_elb[arn]}" "${app_back_elb[port]}" "${app_back_tg[arn]}"

print_sperator




create_target_group "${app_front_tg[name]}" "$vpc_id" "${app_front_tg[port]}"
app_front_tg[arn]="$rt"

print_sperator


create_load_balancer "${app_front_elb[name]}" "${app_front_elb[subnets]}" "${app_front_elb[security_group]}"
app_front_elb[arn]="$rt"

print_sperator

create_listener "${app_front_elb[arn]}" "${app_front_elb[port]}" "${app_front_tg[arn]}"

print_sperator