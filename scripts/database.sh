db_name_instance="$prefix-db"
db_name="${app}_${env}_db"
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
    # 1 db_name_instance
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

        echo "DB instance $1 is created successfully"
    fi


    echo "Fetching DB secret name"

    secret_arn=$(echo "$db" | jq -r ".MasterUserSecret.SecretArn")

    secret_name=$(aws secretsmanager list-secrets \
                --query "SecretList[?ARN=='$secret_arn'] | [0] | Name" \
                --output text)
    
    if ! [ $? -eq 0 ] || [ "$secret_name" = "None" ];
    then
            echo "Error while creating DB instance"
            exit 1
    fi
    

    rt1="$secret_name"
    rt2="$secret_arn"
    rt3=$(echo "$db" | jq -r ".Endpoint.Address")
    rt4=$(echo "$db" | jq -r ".Endpoint.Port")


}


create_db_subnet_group "$db_subnet_group_name" "${subnet_private_3[id]} ${subnet_private_4[id]}"

print_sperator

create_db_instance  "$db_name_instance" "$db_subnet_group_name" "$db_instance_class" "$engine" "$master_username" "$storage_type" "$allocated_storage" "${sg_db[id]}" "$db_name"
declare -A rds_db
rds_db[instance_name]="$db_name_instance"
rds_db[name]="$db_name"
rds_db[secret_name]="$rt1"
rds_db[secret_arn]="$rt2"
rds_db[host]="$rt3"
rds_db[port]="$rt4"

print_sperator
