
function put_policy_to_role(){
    # $1 role_name
    # $2 policy_name
    # $3 policy_document

    echo "Putting policy $2 to $1"

    if ! output=$(
        aws iam put-role-policy \
            --region $region \
            --role-name "$1" \
            --policy-name "$2" \
            --policy-document "$3"
        ); 
    then
        echo "Error while creating role"
        exit 1
    fi

    echo "Policy $2 added sucessfully to $1"
}

function attach_policy_to_role(){
    # $1 role_name
    # $2 policy_arn
    
    echo "Attaching policy $2 to $1"


    if ! output=$(
        aws iam attach-role-policy \
            --role-name "$1" \
            --policy-arn "$2"
        ); 
    then
        echo "Error while creating role"
        exit 1
    fi


    echo "Policy $2 attached sucessfully to $1"
}


function create_role(){
    # $1 role_name
    # $2 assume_role_policy_document

    echo "Create $1 role ..."
    
    if ! check_exists=$(
        aws iam list-roles \
            --region $region \
            --query "Roles[?RoleName=='$1'] | [0]" \
            --output json
        ); 
    then
        echo "Error while creating role"
        exit 1
    fi

    if [[ "$check_exists" != "null" ]]; then
        output="$check_exists"
        echo "Role is already exists"
    else
        output=$(
        aws iam create-role \
            --region $region \
            --role-name "$1" \
            --assume-role-policy-document "$2" \
            --query "Role" \
            --tags "Key=Name,Value=$1" "Key=Env,Value=$env" "Key=App,Value=$app" \
            --output json
                ); 

        if [ $? -eq 0 ];
        then
            echo "Role $1 is created successfully"
            sleep 20
        else
            echo "Error while creating role"
            exit 1
        fi
    fi


    role_id=$(echo -n "$output" | jq -r ".RoleId")
    role_arn=$(echo -n "$output" | jq -r ".Arn")

    echo $role_id
    echo $role_arn

    rt1=$role_id
    rt2=$role_arn
}