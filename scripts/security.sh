

# aws ec2 authorize-security-group-ingress \
#     --group-id sg-1234567890abcdef0 \
#     --ip-permissions \
    # 'IpProtocol=tcp,FromPort=3389,ToPort=3389,IpRanges=[{CidrIp=172.31.0.0/16}]'
    # 'IpProtocol=tcp,FromPort=3389,ToPort=3389,UserIdGroupPairs=[{GroupId=172.31.0.0/16}]'
    # 'IpProtocol=all,UserIdGroupPairs=[{GroupId=0.0.0.0/0}]'


declare -A sg_app_front_end=(
  [name]="$prefix-app-front-end"
  [inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]"
)

declare -A sg_app_back_end=(
  [name]="$prefix-app-back-end"
  [inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]"
)

declare -A sg_load_balancer_front_end=(
  [name]="$prefix-load-balancer-front-end"
  [inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]"
)

declare -A sg_load_balancer_back_end=(
  [name]="$prefix-load-balancer-back-end"
  [inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]"
)

declare -A sg_db=(
  [name]="$prefix-db"
  [inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]"
)



sgs=(
  "sg_app_front_end"
  "sg_app_back_end"
  "sg_load_balancer_front_end"
  "sg_load_balancer_back_end"
  "sg_db"
)



function create_security_group(){
    # $1 sg_name
    # $2 vpc_id
    # return security_group_id

    echo "Create $1 Security Group ..."
    
    if ! check_exists=$(
        aws ec2 describe-security-groups \
            --region $region \
            --filters "Name=vpc-id,Values=$2" "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "SecurityGroups[0].GroupId" \
            --output text
        ); 
    then
        echo "Error while creating security group"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        sg_id="$check_exists"
        echo "Security group is already exists"
    elif sg_id=$(aws ec2 create-security-group \
        --region $region \
        --vpc-id "$2" \
        --group-name "$1" \
        --description "$1" \
        --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]"\
        --query "GroupId" \
        --output text); 
    then
        echo "Security group $1 is created successfully"
    else
        echo "Error while creating security group"
        exit 1
    fi


    echo "$sg_id"
    rt="$sg_id"
}

function add_in_rules_to_security_group(){
    # $1 sg_id
    # $2 inrules

    sg_id="$1"
    inrules="$2"

    echo "Adding in-bound rules to security group $sg_id"


    readarray -t current_rules < <(
        aws ec2 describe-security-group-rules \
            --filters "Name=group-id,Values=$sg_id" \
            --query "SecurityGroupRules[?IsEgress==\`false\`].SecurityGroupRuleId" \
            --output text \
        | tr '\t' '\n'
    )

    if [[ "${#current_rules[@]}" != "0" ]]; then
        if ! output=$(
            aws ec2 revoke-security-group-ingress \
                --group-id "$sg_id" \
                --security-group-rule-ids "${current_rules[@]}"
                ); 
        then
            echo "Error while adding in-bound rules to security group"
            exit 1
        fi
    fi

    IFS='&&' read -ra rules <<< $inrules

    if ! output=$(
        aws ec2 authorize-security-group-ingress \
            --group-id "$sg_id" \
            --ip-permissions "${rules[@]}"); 
    then
        echo "Error while adding in-bound rules to security group"
        exit 1
    fi

}


for sg_name in "${sgs[@]}"; do
    declare -n sg="$sg_name"

    create_security_group "${sg[name]}" "$vpc_id" "${sg[inrules]}"
    sg[id]="$rt"

    print_sperator
done

for sg_name in "${sgs[@]}"; do
    declare -n sg="$sg_name"

    add_in_rules_to_security_group "${sg[id]}" "${sg[inrules]}"

    print_sperator
done
