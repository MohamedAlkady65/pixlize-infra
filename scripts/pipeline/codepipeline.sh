declare -A codepipeline_app_back
codepipeline_app_back[name]="$prefix-app-back-codepipeline"

declare -A codepipeline_app_back_role
codepipeline_app_back_role[name]="${codepipeline_app_back[name]}-role"

codepipeline_app_back_role[policy_name]="${codepipeline_app_back_role[name]}-policy"

codepipeline_app_back_role[policy_document]=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketVersioning",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${pipeline_bucket[name]}/*",
        "arn:aws:s3:::${pipeline_bucket[name]}/*"
      ]
    },
    {
      "Sid": "Connections",
      "Effect": "Allow",
      "Action": [
        "codeconnections:UseConnection"
      ],
      "Resource": "${github_connection_app[arn]}"
    },
    {
      "Sid": "CodeBuild",
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetBuildBatches",
        "codebuild:StartBuildBatch"
      ],
      "Resource": "${codebuild_app_back[arn]}"
    },
    {
      "Sid": "CodeDeploy",
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetDeploymentGroup",
        "codedeploy:ListDeployments",
        "codedeploy:ListDeploymentGroups",
        "codedeploy:ListDeploymentConfigs"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)

codepipeline_app_back_role[assume_documnet]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)



function create_codepipeline_project(){

    # $1 name
    # $2 role_arn
    # $3 bucket_name
    # $4 github_connection_arn
    # $5 repository_name
    # $6 branch
    # $7 codebuild_project_name
    # $8 codedeploy_application_name
    # $9 codedeploy_deployment_group

    echo "Create $1 code pipeline ..."

    if ! check_exists=$(
        aws codepipeline list-pipelines \
            --region "$region" \
            --query "pipelines[?name == '$1'] | [0] | name" \
            --output text
        ); 
    then
        echo "Error while creating code pipeline"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Code pipeline is already exists"
        return 0
    fi

    json_config=$(cat <<EOF
{
  "pipeline": {
    "version": 1,
    "name": "$1",
    "roleArn": "$2",
    "artifactStore": {
      "type": "S3",
      "location": "$3"
    },
    "executionMode": "QUEUED",
    "pipelineType": "V2",
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "GitHub_Source",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeStarSourceConnection",
              "version": "1"
            },
            "configuration": {
              "ConnectionArn": "$4",
              "FullRepositoryId": "$5",
              "BranchName": "$6",
              "OutputArtifactFormat": "CODE_ZIP"
            },
            "outputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Build",
        "actions": [
          {
            "name": "CodeBuild",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "$7"
            },
            "inputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ],
            "outputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Deploy",
        "actions": [
          {
            "name": "CodeDeploy",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "CodeDeploy",
              "version": "1"
            },
            "configuration": {
              "ApplicationName": "$8",
              "DeploymentGroupName": "$9"
            },
            "inputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      }
    ]
  }
}
EOF
)

    if ! output=$(
        aws codepipeline create-pipeline \
         --region "$region" \
         --cli-input-json  "$json_config" \
         --query "pipeline.name" \
         --output text
    ); 
    then
        echo "Error while creating code pipeline"
        exit 1
    fi

    echo "Code pipeline project $1 is created successfully"
}



create_role "${codepipeline_app_back_role[name]}" "${codepipeline_app_back_role[assume_documnet]}"
codepipeline_app_back_role[id]="$rt1"
codepipeline_app_back_role[arn]="$rt2"

print_sperator

put_policy_to_role "${codepipeline_app_back_role[name]}" "${codepipeline_app_back_role[policy_name]}" "${codepipeline_app_back_role[policy_document]}" 

print_sperator

create_codepipeline_project \
    "${codepipeline_app_back[name]}" \
    "${codepipeline_app_back_role[arn]}" \
    "${pipeline_bucket[name]}" \
    "${github_connection_app[arn]}" \
    "${app_back_repo}" \
    "${app_back_branch}" \
    "${codebuild_app_back[name]}" \
    "${codedeploy_app_back[app_name]}" \
    "${codedeploy_app_back[deployment_group_name]}"

print_sperator
