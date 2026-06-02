declare -A codebuild_app_back
codebuild_app_back[name]="$prefix-app-back-codebuild"

declare -A codebuild_app_back_role
codebuild_app_back_role[name]="${codebuild_app_back[name]}-role"

codebuild_app_back_role[policy_name]="${codebuild_app_back_role[name]}-policy"

codebuild_app_back_role[policy_document]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:$region:$account_id:log-group:/aws/codebuild/${codebuild_app_back_role[name]}",
                "arn:aws:logs:$region:$account_id:log-group:/aws/codebuild/${codebuild_app_back_role[name]}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${pipeline_bucket[name]}/*",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        }
    ]
}
EOF
)

codebuild_app_back_role[assume_documnet]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)


function create_codebuild_project(){
    # $1 project_name
    # $1 role_arn

    echo "Create $1 code build project ..."

    if ! check_exists=$(
        aws codebuild batch-get-projects \
         --region "$region" \
         --names "$1" \
         --query "projects[?name == '$1'] | [0] | arn" \
         --output text
        ); 
    then
        echo "Error while creating code build project"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        project_arn="$check_exists"
        echo "Code build project is already exists"
        echo "$project_arn"
        rt="$project_arn"
        return 0
    fi

    json_config=$(cat <<EOF
{
    "name": "$1",
    "serviceRole": "$2",
    "source": {
        "type": "CODEPIPELINE",
        "sourceIdentifier": "1"
    },
    "artifacts": {
        "type": "CODEPIPELINE"
    },
    "environment": {
        "type": "LINUX_CONTAINER",
        "image": "aws/codebuild/amazonlinux-x86_64-standard:6.0",
        "computeType": "BUILD_GENERAL1_MEDIUM",
        "privilegedMode": false
    },
    "logsConfig": {
        "cloudWatchLogs": {
            "status": "ENABLED",
            "groupName": "/aws/codebuild/$1"
        }
    }
}
EOF
)

    if ! project_arn=$(
        aws codebuild create-project \
         --region "$region" \
         --cli-input-json  "$json_config" \
         --query "project.arn" \
         --output text
    ); 
    then
       - echo "Error while creating code build project"
        exit 1
    fi

    echo "Code build project $1 is created successfully"
    echo "$project_arn"
    rt="$project_arn"
}


create_role "${codebuild_app_back_role[name]}" "${codebuild_app_back_role[assume_documnet]}"
codebuild_app_back_role[id]="$rt1"
codebuild_app_back_role[arn]="$rt2"

print_sperator

put_policy_to_role "${codebuild_app_back_role[name]}" "${codebuild_app_back_role[policy_name]}" "${codebuild_app_back_role[policy_document]}" 

print_sperator

create_codebuild_project "${codebuild_app_back[name]}" "${codebuild_app_back_role[arn]}"
codebuild_app_back[arn]="$rt"

print_sperator