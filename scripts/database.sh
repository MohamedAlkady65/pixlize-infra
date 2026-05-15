db_name="$prefix-db"
db_subnet_group_name="$prefix-db-subnet-group"
db_instance_class="db.t3.micro"
engine=mysql
master_username=admin
storage_type=gp3
allocated_storage=20


function create_db_subnet_group(){
    # $1 db_subnet_group_name
    # $2 subnet_ids

    read -ra subnet_ids <<< "$2"

    echo "Create $1 DB subnet group ..."
    
    check_exists=$(
        aws rds describe-db-subnet-groups \
            --region $region \
            --db-subnet-group-name "$1" \
            --query "DBSubnetGroups[0].DBSubnetGroupName" \
            --output text 2>&1
        ); 

    if [ $? -eq 0 ]; then
        echo "Subnet group is already exists"
        return 0
    elif [[ "$check_exists" != *"DBSubnetGroupNotFoundFault"* ]]; then
        echo "$check_exists" >&2
        echo "Error while creating DB subnet group"
        exit 1
    fi



    if ! output=$(
        aws rds create-db-subnet-group \
            --region $region \
            --db-subnet-group-name "$1" \
            --db-subnet-group-description "$1" \
            --subnet-ids "${subnet_ids[@]}"
        ); 
    then
        echo "Error while creating DB subnet group"
        exit 1
    fi

    echo "DB subnet group $1 is created successfully"
}


function create_db_instance(){
    # 1 db_name
    # 2 db_subnet_group_name
    # 3 db_instance_class
    # 4 engine
    # 5 master_username
    # 6 storage_type
    # 7 allocated_storage
    # 8 security_group_id


    echo "Create $1 DB intsance ..."
    
    check_exists=$(
        aws rds describe-db-instances \
            --region $region \
            --db-instance-identifier "$1" \
            --output json \
            --query "DBInstances[0]" 2>&1
        ); 

    if [ $? -eq 0 ]; then
        echo "DB intsance is already exists"
        db="$check_exists"
    elif [[ "$check_exists" != *"DBInstanceNotFound"* ]]; then
        echo "$check_exists" >&2
        echo "Error while creating DB intsance"
        exit 1
    else 
        db=$(
            aws rds create-db-instance \
                --region $region \
                --db-instance-identifier "$1" \
                --db-subnet-group-name "$2" \
                --db-instance-class "$3" \
                --engine "$4" \
                --master-username "$5" \
                --manage-master-user-password \
                --storage-type "$6" \
                --allocated-storage "$7"  \
                --vpc-security-group-ids "$8" \
                --db-name "$9" \
                --no-publicly-accessible \
                --query "DBInstance"\
                --output json
            )
        
        if ! [ $? -eq 0 ];
        then
            echo "Error while creating DB instance"
            exit 1
        fi
    fi


    rt=$(echo "$db" | jq -r ".MasterUserSecret.SecretArn")

    echo "DB instance $1 is created successfully"
    echo "$rt"
}


create_db_subnet_group "$db_subnet_group_name" "${subnet_private_3[id]} ${subnet_private_4[id]}"

print_sperator

create_db_instance  "$db_name" "$db_subnet_group_name" "$db_instance_class" "$engine" "$master_username" "$storage_type" "$allocated_storage" "${sg_db[id]}" "$db_name"
db_master_user_secret_arn="$rt"

print_sperator
