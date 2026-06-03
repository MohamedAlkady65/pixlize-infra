function create_codedeploy_app(){
    # $1 app_name
    # $2 type

    echo "Create $1 code deploy app ..."

    if ! check_exists=$(
        aws deploy batch-get-applications \
         --region "$region" \
         --application-names "$1" \
         --query "applicationsInfo[?applicationName == '$1'] | [0] | applicationId" \
         --output text
        ); 
    then
        echo "Error while creating code deploy app"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        app_id="$check_exists"
        echo "Code deploy app is already exists"
        echo "$app_id"
        rt="$app_id"
        return 0
    fi


    if ! app_id=$(
        aws deploy create-application \
            --region "$region" \
            --application-name "$1" \
            --compute-platform "$2" \
            --query "applicationId" \
            --output text
    ); 
    then
       - echo "Error while creating code deploy app"
        exit 1
    fi

    echo "Code deploy app $1 is created successfully"
    echo "$app_id"
    rt="$app_id"
}



function create_deployment_group(){
    # $1 app_name
    # $2 deployment_group_name
    # $3 role_arn
    # $4 deployment_config_name
    # $5 type ASG | Lambda
    # $5 auto_scaling_group


    echo "Create $1 deployment group ..."

    if ! check_exists=$(
        aws deploy batch-get-deployment-groups \
            --region "$region" \
            --application-name "$1" \
            --deployment-group-names "$2" \
            --query "deploymentGroupsInfo[?deploymentGroupName == '$2'] | [0] | deploymentGroupId" \
            --output text
    );
    then
        echo "Error while creating deployment group"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Deployment group is already exists"
        rt="$check_exists"
        echo "$rt"
        return 0
    fi

    cmd=(
        aws deploy create-deployment-group
            --region "$region"
            --application-name "$1"
            --deployment-group-name "$2"
            --service-role-arn "$3"
            --deployment-config-name "$4"
            --query "deploymentGroupId"
            --output text
    )

    [[ "$5" != "ASG" ]] && cmd+=(
        --auto-scaling-groups "$6"
        --termination-hook-enabled
        --load-balancer-info targetGroupInfoList=[{name="$6"}]
        --deployment-style deploymentType=IN_PLACE,deploymentOption=WITH_TRAFFIC_CONTROL
    )


    if ! id=$("${cmd[@]}");
    then
        echo "Error while creating deployment group"
        exit 1
    fi

    rt="$id"

    echo "Deployment group $2 is created successfully"
    echo "$rt"
}


# Backend

declare -A codedeploy_app_back
codedeploy_app_back[app_name]="$prefix-app-back-codedeploy-application"
codedeploy_app_back[app_type]="Server"
codedeploy_app_back[deployment_group_name]="$prefix-app-back-codedeploy-deployment-group"


declare -A codedeploy_app_back_deployment_group_role
codedeploy_app_back_deployment_group_role[name]="${codedeploy_app_back[deployment_group_name]}-role"

codedeploy_app_back_deployment_group_role[attach_policy_arn]="arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"

codedeploy_app_back_deployment_group_role[assume_documnet]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)


create_role "${codedeploy_app_back_deployment_group_role[name]}" "${codedeploy_app_back_deployment_group_role[assume_documnet]}"
codedeploy_app_back_deployment_group_role[id]="$rt1"
codedeploy_app_back_deployment_group_role[arn]="$rt2"

print_sperator

attach_policy_to_role "${codedeploy_app_back_deployment_group_role[name]}" "${codedeploy_app_back_deployment_group_role[attach_policy_arn]}"

print_sperator

create_codedeploy_app "${codedeploy_app_back[app_name]}" "${codedeploy_app_back[app_type]}"
codedeploy_app_back[app_id]="$rt"

print_sperator

create_deployment_group "${codedeploy_app_back[app_name]}" "${codedeploy_app_back[deployment_group_name]}" "${codedeploy_app_back_deployment_group_role[arn]}" "CodeDeployDefault.OneAtATime" "ASG" "${app_back_asg[name]}"
codedeploy_app_back[deployment_group_id]="$rt"

print_sperator

# Frontend

declare -A codedeploy_app_front
codedeploy_app_front[app_name]="$prefix-app-front-codedeploy-application"
codedeploy_app_front[app_type]="Server"
codedeploy_app_front[deployment_group_name]="$prefix-app-front-codedeploy-deployment-group"


declare -A codedeploy_app_front_deployment_group_role
codedeploy_app_front_deployment_group_role[name]="${codedeploy_app_front[deployment_group_name]}-role"

codedeploy_app_front_deployment_group_role[attach_policy_arn]="arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"

codedeploy_app_front_deployment_group_role[assume_documnet]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)


create_role "${codedeploy_app_front_deployment_group_role[name]}" "${codedeploy_app_front_deployment_group_role[assume_documnet]}"
codedeploy_app_front_deployment_group_role[id]="$rt1"
codedeploy_app_front_deployment_group_role[arn]="$rt2"

print_sperator

attach_policy_to_role "${codedeploy_app_front_deployment_group_role[name]}" "${codedeploy_app_front_deployment_group_role[attach_policy_arn]}"

print_sperator

create_codedeploy_app "${codedeploy_app_front[app_name]}" "${codedeploy_app_front[app_type]}"
codedeploy_app_front[app_id]="$rt"

print_sperator

create_deployment_group "${codedeploy_app_front[app_name]}" "${codedeploy_app_front[deployment_group_name]}" "${codedeploy_app_front_deployment_group_role[arn]}" "CodeDeployDefault.OneAtATime" "ASG" "${app_front_asg[name]}"
codedeploy_app_front[deployment_group_id]="$rt"

print_sperator

# Lambda

declare -A codedeploy_app_lambda
codedeploy_app_lambda[app_name]="$prefix-app-lambda-codedeploy-application"
codedeploy_app_lambda[app_type]="Lambda"
codedeploy_app_lambda[deployment_group_name]="$prefix-app-lambda-codedeploy-deployment-group"


declare -A codedeploy_app_lambda_deployment_group_role
codedeploy_app_lambda_deployment_group_role[name]="${codedeploy_app_lambda[deployment_group_name]}-role"

codedeploy_app_lambda_deployment_group_role[attach_policy_arn]="arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"

codedeploy_app_lambda_deployment_group_role[assume_documnet]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)


create_role "${codedeploy_app_lambda_deployment_group_role[name]}" "${codedeploy_app_lambda_deployment_group_role[assume_documnet]}"
codedeploy_app_lambda_deployment_group_role[id]="$rt1"
codedeploy_app_lambda_deployment_group_role[arn]="$rt2"

print_sperator

attach_policy_to_role "${codedeploy_app_lambda_deployment_group_role[name]}" "${codedeploy_app_lambda_deployment_group_role[attach_policy_arn]}"

print_sperator

create_codedeploy_app "${codedeploy_app_lambda[app_name]}" "${codedeploy_app_lambda[app_type]}"
codedeploy_app_lambda[app_id]="$rt"

print_sperator

create_deployment_group "${codedeploy_app_lambda[app_name]}" "${codedeploy_app_lambda[deployment_group_name]}" "${codedeploy_app_lambda_deployment_group_role[arn]}" "CodeDeployDefault.LambdaAllAtOnce" "Lambda"
codedeploy_app_lambda[deployment_group_id]="$rt"

print_sperator