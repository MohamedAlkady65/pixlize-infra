#!/bin/bash



vpc_name="$prefix-vpc"
vpc_cidr="10.0.0.0/16"


declare -A route_table_private=(
  [name]="$prefix-private-route-table"
  [internet]="none"
)

declare -A route_table_private_nat=(
  [name]="$prefix-private-nat-route-table"
  [internet]="nat"
)

declare -A route_table_public=(
  [name]="$prefix-public-route-table"
  [internet]="igw"
)


declare -A subnet_public_1=(
  [type]="public"
  [name]="$prefix-public-1"
  [cidr]="10.0.1.0/24"
  [az]="$az1"
  [route_table]="route_table_public"
)

declare -A subnet_private_1=(
  [type]="private"
  [name]="$prefix-private-1"
  [cidr]="10.0.2.0/24"
  [az]="$az1"
  [route_table]="route_table_private_nat"
)

declare -A subnet_private_2=(
  [type]="private"
  [name]="$prefix-private-2"
  [cidr]="10.0.3.0/24"
  [az]="$az2"
  [route_table]="route_table_private_nat"
)

declare -A subnet_private_3=(
  [type]="private"
  [name]="$prefix-private-3"
  [cidr]="10.0.4.0/24"
  [az]="$az1"
  [route_table]="route_table_private"
)

declare -A subnet_private_4=(
  [type]="private"
  [name]="$prefix-private-4"
  [cidr]="10.0.5.0/24"
  [az]="$az2"
  [route_table]="route_table_private"
)


route_tables=(
    "route_table_private"
    "route_table_private_nat"
    "route_table_public"
)

subnets=(
  "subnet_public_1"
  "subnet_private_1"
  "subnet_private_2"
  "subnet_private_3"
  "subnet_private_4"
)


igw_name="$prefix-igw"

nat_name="$prefix-nat"

function create_vpc(){
    # return vpc_id

    echo "Create $vpc_name VPC ..."
    
    if ! check_exists=$(
        aws ec2 describe-vpcs \
            --region $region \
            --filters \
            "Name=tag:Name,Values=$vpc_name" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "Vpcs[0].VpcId" \
            --output text
        ); 
    then
        echo "Error while creating vpc"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        vpc_id="$check_exists"
        echo "VPC is already exists"
        echo "$vpc_id"
        rt="$vpc_id"
        return 0
    fi


    if ! vpc_id=$(aws ec2 create-vpc \
        --region $region \
        --cidr-block "$vpc_cidr" \
        --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$vpc_name},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
        --query "Vpc.VpcId" \
        --output text); 
    then
        echo "Error while creating vpc"
        exit 1
    fi

    echo "VPC $vpc_name is created successfully"
    echo "$vpc_id"
    rt="$vpc_id"
}

function create_subnet(){
    # $1 subnet_name
    # $2 vpc_id
    # $3 cidr
    # $4 az
    # $5 type public,private
    # return subnet_id

    echo "Create $1 Subnet ..."
    
    if ! check_exists=$(
        aws ec2 describe-subnets \
            --region $region \
            --filters "Name=vpc-id,Values=$2" "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "Subnets[0].SubnetId" \
            --output text
        ); 
    then
        echo "Error while creating subnet"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        subnet_id="$check_exists"
        echo "Subnet is already exists"
        echo "$subnet_id"
        rt="$subnet_id"
    elif 
    subnet_id=$(aws ec2 create-subnet \
        --region $region \
        --vpc-id "$2" \
        --cidr-block "$3" \
        --availability-zone "$4" \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]"\
        --query "Subnet.SubnetId" \
        --output text); 
    then
        echo "Subnet $1 is created successfully"
        echo "$subnet_id"
    else
        echo "Error while creating subnet"
        exit 1
    fi


    if [ "$5" = "public" ] ; then
        echo "Enabling auto-assign public IPv4 address"
        if 
        ! output=$(aws ec2 modify-subnet-attribute \
            --region $region \
            --subnet-id "$subnet_id" \
            --map-public-ip-on-launch
            ); 
        then
            echo "Error while associate route table to subnet"
            exit 1
        fi
    fi

    rt="$subnet_id"
}

function create_internet_gateway(){
    # return igw_id

    echo "Create $igw_name Internet Gateway ..."
    
    if ! check_exists=$(
        aws ec2 describe-internet-gateways \
            --region $region \
            --filters "Name=tag:Name,Values=$igw_name" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "InternetGateways[0].InternetGatewayId" \
            --output text
        ); 
    then
        echo "Error while creating internet gateway"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        igw_id="$check_exists"
        echo "Internet gateway is already exists"
        echo "$igw_id"
        rt="$igw_id"
        return 0
    fi


    if ! igw_id=$(aws ec2 create-internet-gateway \
        --region $region \
        --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$igw_name},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
        --query "InternetGateway.InternetGatewayId" \
        --output text); 
    then
        echo "Error while creating internet gateway"
        exit 1
    fi

    echo "Internet gateway $igw_name is created successfully"
    echo "$igw_id"
    rt="$igw_id"
}

function attach_internet_gateway(){
    # $1 igw_id
    # $2 vpc_id

    echo "Attach Internet Gateway $1 To VPC $2 ..."

    if ! attached_vpc_id=$(aws ec2 describe-internet-gateways \
        --internet-gateway-ids "$1" \
        --query "InternetGateways[0].Attachments[0].VpcId" \
        --output text); 
    then
        echo "Error while attaching internet gateway to vpc"
        exit 1
    fi

    attached_vpc_id="${attached_vpc_id%$'\n'}"


    if [ "$attached_vpc_id" = "$2" ]; then
        echo "Internet gateway is already attached"
        return 0
    fi


    if ! output=$(aws ec2 attach-internet-gateway \
            --internet-gateway-id "$1" \
            --vpc-id "$2"); 
    then
        echo "Error while attaching internet gateway to vpc"
        exit 1
    fi

    echo "Internet gateway attached to vpc successfully"

}


function allocate_eip(){
    # $1 eip_name
    # return allocation_id

    echo "Allocation $1 EIP ..."
    
    if ! check_exists=$(
        aws ec2 describe-addresses \
            --region $region \
            --filters "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "Addresses[0].AllocationId" \
            --output text
        ); 
    then
        echo "Error while creating EIP"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        allocation_id="$check_exists"
        echo "EIP is already exists"
        echo "$allocation_id"
        rt="$allocation_id"
        return 0
    fi


    if ! allocation_id=$(aws ec2 allocate-address \
        --region $region \
        --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
        --query "AllocationId" \
        --output text); 
    then
        echo "Error while creating EIP"
        exit 1
    fi

    echo "EIP $1 is allocated successfully"
    echo "$allocation_id"
    rt="$allocation_id"
}



function create_nat_gateway(){
    # $1 subnet_id
    # return nat_id

    echo "Create $nat_name NAT Gateway ..."
    
    if ! check_exists=$(
        aws ec2 describe-nat-gateways \
            --region $region \
            --filter "Name=state,Values=pending,available" "Name=tag:Name,Values=$nat_name" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "NatGateways[0].NatGatewayId" \
            --output text
        ); 
    then
        echo "Error while creating NAT gateway"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        nat_id="$check_exists"
        echo "NAT gateway is already exists"
        echo "$nat_id"
        rt="$nat_id"
        return 0
    fi

    allocate_eip "$nat_name-eip"
    allocation_id="$rt"


    if ! nat_id=$(aws ec2 create-nat-gateway \
        --region $region \
        --subnet-id "$1" \
        --connectivity-type public \
        --allocation-id "$allocation_id" \
        --tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=$nat_name},{Key=Env,Value=$env},{Key=App,Value=$app}]" \
        --query "NatGateway.NatGatewayId" \
        --output text); 
    then
        echo "Error while creating NAT gateway"
        exit 1
    fi

    echo "NAT gateway $nat_name is created successfully"
    echo "$nat_id"
    rt="$nat_id"
}


function create_route_table(){
    # $1 rt_name
    # $2 vpc_id
    # return rt_id

    echo "Create $1 Route Table ..."
    
    if ! check_exists=$(
        aws ec2 describe-route-tables \
            --region $region \
            --filters "Name=tag:Name,Values=$1" "Name=tag:Env,Values=$env" "Name=tag:App,Values=$app" \
            --query "RouteTables[0].RouteTableId" \
            --output text
        ); 
    then
        echo "Error while creating route table"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        rt_id="$check_exists"
        echo "Route table is already exists"
        echo "$rt_id"
        rt="$rt_id"
        return 0
    fi


    if ! rt_id=$(aws ec2 create-route-table \
        --region $region \
        --vpc-id "$2" \
        --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$1},{Key=Env,Value=$env},{Key=App,Value=$app}]"\
        --query "RouteTable.RouteTableId" \
        --output text); 
    then
        echo "Error while creating route table"
        exit 1
    fi

    echo "Route table $1 is created successfully"
    echo "$rt_id"
    rt="$rt_id"
}

function add_gateway_to_route_table(){
    # $1 rt_id
    # $2 gateway_id

    echo "Add $2 To Route Table $1 ..."

    if ! check_exists=$(
        aws ec2 describe-route-tables \
        --region $region \
        --route-table-ids "$1" \
        --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'] | [0]" \
        --output text
        ); 
    then
        echo "Error while add gateway to route table"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Gateway is already exists"
        return 0
    fi


    if ! output=$(aws ec2 create-route \
        --route-table-id "$1" \
        --destination-cidr-block "0.0.0.0/0" \
        --gateway-id "$2"); 
    then
        echo "Error while add gateway to route table"
        exit 1
    fi

    echo "Gateway added to route table successfully"
}

function associate_route_table_to_subnet(){
    # $1 rt_id
    # $2 subnet_id

    echo "Associate Route Table $1 To Subnet $2 ..."

    if ! output=$(aws ec2 associate-route-table \
        --route-table-id "$1" \
        --subnet-id "$2"); 
    then
        echo "Error while associate route table to subnet"
        exit 1
    fi

    echo "Route Table Associated to Subnet successfully"

}

create_vpc
vpc_id="$rt"

print_sperator


for subnet_name in "${subnets[@]}"; do
    declare -n subnet="$subnet_name"

    create_subnet "${subnet[name]}" "$vpc_id" "${subnet[cidr]}" "${subnet[az]}" "${subnet[type]}"
    subnet[id]="$rt"

    print_sperator
done



create_internet_gateway
igw_id="$rt"
attach_internet_gateway "$igw_id" "$vpc_id"

print_sperator


create_nat_gateway "${subnet_public_1[id]}"
nat_id="$rt" 

print_sperator




for route_table_name in "${route_tables[@]}"; do
    declare -n route_table="$route_table_name"

    create_route_table "${route_table[name]}" "$vpc_id"
    route_table[id]="$rt"

    if [[ "${route_table[internet]}" == "igw" ]]; then
        add_gateway_to_route_table "${route_table[id]}" "$igw_id"
    fi

    if [[ "${route_table[internet]}" == "nat" ]]; then
        add_gateway_to_route_table "${route_table[id]}" "$nat_id"
    fi

    print_sperator
done



for subnet_name in "${subnets[@]}"; do
    declare -n subnet="$subnet_name"
    declare -n route_table="${subnet[route_table]}"

    associate_route_table_to_subnet "${route_table[id]}" "${subnet[id]}"

    print_sperator
done
