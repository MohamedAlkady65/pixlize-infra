key_name="$prefix-app-instance-key"
imageId="ami-0be40a46b4111e7f5"
instance_type="t2.medium"
volume_size="15"
volume_type="gp3"

declare -A back_launch_tamplate
back_launch_tamplate[name]="$prefix-app-back-launch-template"

declare -A front_launch_tamplate
front_launch_tamplate[name]="$prefix-app-front-launch-template"


app_instance_assume_role_document=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)

declare -A app_back_instance_role

app_back_instance_role[name]="$prefix-app-back-instance-role"

app_back_instance_role[instance_profile_name]="${app_back_instance_role[name]}"

app_back_instance_role[policy_name]="${app_back_instance_role[name]}-policy"

app_back_instance_role[policy_document]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S1",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "$github_private_key_secret_arn"
        },
        {
            "Sid": "S2",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${rds_db[secret_arn]}"
        },
        {
            "Sid": "S3",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${app_back_jwt_secret[arn]}"
        },
        {
            "Sid": "S4",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "$app_back_config_arn"
        },
        {
            "Sid": "S5",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${app_bucket_name}/*"
        },
        {
            "Sid": "S6",
            "Effect": "Allow",
            "Action": "sqs:*",
            "Resource": "${app_queue[arn]}"
        }
    ]
}
EOF
)


declare -A app_front_instance_role

app_front_instance_role[name]="$prefix-app-front-instance-role"

app_front_instance_role[instance_profile_name]="${app_front_instance_role[name]}"

app_front_instance_role[policy_name]="${app_front_instance_role[name]}-policy"

app_front_instance_role[policy_document]=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S1",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "$github_private_key_secret_arn"
        },
        {
            "Sid": "S2",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "$app_front_config_arn"
        }
    ]
}
EOF
)


function create_key_pair(){
    # $1 key_name

    echo "Create $1 key pair ..."
    
    if ! check_exists=$(
        aws ec2 describe-key-pairs \
            --region $region \
            --filters \
            "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "KeyPairs[0].KeyPairId" \
            --output text
        ); 
    then
        echo "Error while creating key pair"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        key_id="$check_exists"
        echo "Key pair is already exists"
        echo "$key_id"
        rt="$key_id"
        return 0
    fi

    output=$(
        aws ec2 create-key-pair  \
            --region $region \
            --key-name "$1" \
            --tag-specifications "ResourceType=key-pair,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
            --output json
            ); 

    if ! [ $? -eq 0 ];
    then
        echo "Error while creating key pair"
        exit 1
    fi

    key_id=$(echo -n "$output" | jq -r ".KeyPairId")
    echo -n "$output" | jq -r ".KeyMaterial" > "$keys_dir/${1}.pem"

    echo "Key pair $1 is created successfully"
    echo "$key_id"
    rt="$key_id"
}

function create_launch_tamplate_data(){
    
    launch_template_data=$(cat <<EOF
        {
        "KeyName": "<<KeyName>>",
        "ImageId": "<<ImageId>>",
        "InstanceType": "<<InstanceType>>",
        "UserData": "<<UserData>>",
        "MetadataOptions": {
            "HttpEndpoint": "enabled",
            "HttpPutResponseHopLimit": 2,
            "HttpTokens": "required"
        },
        "SecurityGroupIds": [
            "<<SecurityGroupIds>>"
        ],
        "BlockDeviceMappings": [
            {
            "DeviceName": "/dev/sda1",
            "Ebs": {
                "Encrypted": false,
                "DeleteOnTermination": true,
                "VolumeSize": <<VolumeSize>>,
                "VolumeType": "<<VolumeType>>"
            }
            }
        ],
        "IamInstanceProfile": {
            "Arn": "<<IamInstanceProfileArn>>"
        }
        }
EOF
    )
    

    keys=("<<KeyName>>" "<<ImageId>>" "<<InstanceType>>" "<<UserData>>" "<<SecurityGroupIds>>" "<<VolumeSize>>" "<<VolumeType>>" "<<IamInstanceProfileArn>>")
    values=("$@") 

    for i in "${!keys[@]}"; do
        launch_template_data=$(echo "${launch_template_data//${keys[$i]}/${values[$i]}}")
    done



    rt=$launch_template_data
}

function create_launch_tamplate(){
    # $1 launch_template_name
    # $2 launch_template_data

    echo "Create $1 launch template ..."
    
    if ! check_exists=$(
        aws ec2 describe-launch-templates \
            --region $region \
            --filters \
            "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "LaunchTemplates[0].LaunchTemplateId" \
            --output text
        ); 
    then
        echo "Error while creating launch template"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        launch_template_id="$check_exists"
        echo "Launch template is already exists"
        echo "$launch_template_id"
        rt="$launch_template_id"
        return 0
    fi


    if ! launch_template_id=$(
            aws ec2 create-launch-template \
                --region $region \
                --launch-template-name "$1" \
                --version-description "$1" \
                --tag-specifications "ResourceType=launch-template,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
                --launch-template-data "$2" \
                --query "LaunchTemplate.LaunchTemplateId" \
                --output text
            );
    then
        echo "Error while creating launch template"
        exit 1
    fi


    echo "Launch template $1 is created successfully"
    echo "$launch_template_id"
    rt="$launch_template_id"
}

function create_instance_profile(){
    # $1 instance_profile_name
    # $2 role_name


    echo "Create $1 instance profile ..."
    
    if ! check_exists=$(
        aws iam list-instance-profiles \
            --region $region \
            --query "InstanceProfiles[?InstanceProfileName=='$1'] | [0]" \
            --output json
        ); 
    then
        echo "Error while creating instance profile"
        exit 1
    fi

    if [[ "$check_exists" != "null" ]]; then
        instance_profile="$check_exists"
        echo "Instance profile is already exists"
    else

        if instance_profile=$(
            aws iam create-instance-profile \
                --region $region \
                --instance-profile-name "$1" \
                --query "InstanceProfile" \
                --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app" \
                --output json
                    );
        then
            echo "Instance profile $1 is created successfully"
        else
            echo "Error while creating instance profile"
            exit 1
        fi
    fi

    instance_profile_arn=$(echo -n "$instance_profile" | jq -r ".Arn")


    echo "Removing Role $2 to $1 instance profile"
    if ! output=$(
        aws iam remove-role-from-instance-profile \
            --instance-profile-name "$1" \
            --role-name "$2" 2>&1
        ); 
    then
        if [[ "$output" != *"NoSuchEntity"* ]]; then
            echo "$output" >&2
            echo "Error while creating instance profile"
            exit 1
        fi
    fi

    echo "Adding Role $2 to $1 instance profile"
    if ! output=$(
        aws iam add-role-to-instance-profile \
            --instance-profile-name "$1" \
            --role-name "$2" 
        ); 
    then
        echo "Error while creating instance profile"
        exit 1
    fi

    echo $instance_profile_arn
    rt=$instance_profile_arn

}

create_key_pair $key_name 
key_id=$rt

print_sperator



create_role "${app_back_instance_role[name]}" "${app_instance_assume_role_document}"
app_back_instance_role[id]="$rt1"
app_back_instance_role[arn]="$rt2"

print_sperator

put_policy_to_role "${app_back_instance_role[name]}" "${app_back_instance_role[policy_name]}" "${app_back_instance_role[policy_document]}"

print_sperator

create_role "${app_front_instance_role[name]}" "${app_instance_assume_role_document}"
app_front_instance_role[id]="$rt1"
app_front_instance_role[arn]="$rt2"

print_sperator

put_policy_to_role "${app_front_instance_role[name]}" "${app_front_instance_role[policy_name]}" "${app_front_instance_role[policy_document]}"

print_sperator

create_instance_profile "${app_back_instance_role[instance_profile_name]}" "${app_back_instance_role[name]}"
app_back_instance_role[instance_profile_arn]=$rt

print_sperator

create_instance_profile "${app_front_instance_role[instance_profile_name]}" "${app_front_instance_role[name]}"
app_front_instance_role[instance_profile_arn]=$rt

print_sperator


back_launch_tamplate[user_data]=$(cat "./app/user_data_scripts/app_back_user_data.sh")


keys_to_replace=("<<jwt_secret_name>>" "<<db_secret_name>>" "<<parametar_config_name>>" "<<port_in_container>>" "<<port_in_host>>")
values_to_replace=("${app_back_jwt_secret[name]}" "${rds_db[secret_name]}" "$app_back_config_name" "$app_back_port_in_container" "$app_back_port_in_host")


for i in "${!keys_to_replace[@]}"; do
    back_launch_tamplate[user_data]=$(echo "${back_launch_tamplate[user_data]//${keys_to_replace[$i]}/${values_to_replace[$i]}}")
done

back_launch_tamplate[user_data]=$(echo "${back_launch_tamplate[user_data]}" | base64 -w 0)


create_launch_tamplate_data "$key_name" "$imageId" "$instance_type" "${back_launch_tamplate[user_data]}" "${sg_app_back_end[id]}" "$volume_size" "$volume_type" "${app_back_instance_role[instance_profile_arn]}"
back_launch_tamplate[data]="$rt"

create_launch_tamplate "${back_launch_tamplate[name]}" "${back_launch_tamplate[data]}"
back_launch_tamplate[id]="$rt"

print_sperator

front_launch_tamplate[user_data]=$(cat "./app/user_data_scripts/app_front_user_data.sh")

keys_to_replace=("<<parametar_config_name>>" "<<port_in_host>>")
values_to_replace=("$app_front_config_name" "$app_front_port_in_host")


for i in "${!keys_to_replace[@]}"; do
    front_launch_tamplate[user_data]=$(echo "${front_launch_tamplate[user_data]//${keys_to_replace[$i]}/${values_to_replace[$i]}}")
done

front_launch_tamplate[user_data]=$(echo "${front_launch_tamplate[user_data]}" | base64 -w 0)

create_launch_tamplate_data "$key_name" "$imageId" "$instance_type" "${front_launch_tamplate[user_data]}" "${sg_app_front_end[id]}" "$volume_size" "$volume_type" "${app_front_instance_role[instance_profile_arn]}"
front_launch_tamplate[data]="$rt"

create_launch_tamplate "${front_launch_tamplate[name]}" "${front_launch_tamplate[data]}"
front_launch_tamplate[id]="$rt"

