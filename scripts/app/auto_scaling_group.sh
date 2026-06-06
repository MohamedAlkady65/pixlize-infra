declare -A app_back_asg

app_back_asg[name]="$prefix-back-asg"
app_back_asg[min]=1
app_back_asg[max]=1
app_back_asg[subnets]="${subnet_private_1[id]},${subnet_private_2[id]}"


declare -A app_front_asg

app_front_asg[name]="$prefix-front-asg"
app_front_asg[min]=1
app_front_asg[max]=1
app_front_asg[subnets]="${subnet_private_1[id]},${subnet_private_2[id]}"


function create_auto_scaling_group(){
    # $1 asg_name
    # $2 launch_template_id
    # $3 min_size
    # $4 max_size
    # $5 subnets_ids
    # $6 target_group_arn

    echo "Create $1 auto scaling group ..."


    if ! check_exists=$(
        aws autoscaling describe-auto-scaling-groups \
            --region $region \
            --auto-scaling-group-names "$1" \
            --query "AutoScalingGroups[0].AutoScalingGroupName" \
            --output text
        ); 
    then
        echo "Error while creating auto scaling group"
        exit 1
    fi


    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Auto scaling group is already exists"
        return 0
    fi


    if ! output=$(
        aws autoscaling create-auto-scaling-group \
            --region "$region" \
            --auto-scaling-group-name "$1" \
            --launch-template "LaunchTemplateId=$2" \
            --min-size "$3" \
            --max-size "$4" \
            --vpc-zone-identifier "$5" \
            --target-group-arns "$6" \
            --health-check-type EC2 \
            --health-check-grace-period 600 \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app"
        ); 
    then
        echo "Error while creating auto scaling group"
        exit 1
    fi

    echo "Auto scaling group $1 is created successfully"
}

create_auto_scaling_group "${app_back_asg[name]}" "${back_launch_tamplate[id]}" "${app_back_asg[min]}" "${app_back_asg[max]}" "${app_back_asg[subnets]}" "${app_back_tg[arn]}"

print_sperator

create_auto_scaling_group "${app_front_asg[name]}" "${front_launch_tamplate[id]}" "${app_front_asg[min]}" "${app_front_asg[max]}" "${app_front_asg[subnets]}" "${app_front_tg[arn]}"

print_sperator