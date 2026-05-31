account_id=$(aws sts get-caller-identity --query Account --output text)
account_id="${account_id%$'\n'}"

declare -A app_bucket
app_bucket[name]="$prefix-app-bucket-$account_id"

declare -A lambda_code_bucket
lambda_code_bucket[name]="$prefix-lambda-code-bucket-$account_id"



function create_bucket(){
    # $1 bucket_name

    echo "Create $1 bucket ..."

    if ! check_exists=$(
        aws s3api list-buckets \
            --prefix "$1" \
            --bucket-region $region \
            --region $region \
            --query "Buckets[0].Name" \
            --output text
        ); 
    then
        echo "Error while creating bucket"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        echo "Bucket is already exists"
    elif ! output=$(aws s3api create-bucket \
                    --bucket "$1" \
                    --region $region \
                    --create-bucket-configuration "LocationConstraint=$region") \
        || \
        ! output=$(aws s3api put-public-access-block \
            --bucket "$1" \
            --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
        ); 
    then
        echo "Error while creating bucket"
        exit 1
    fi

    rt="$1.s3.$region.amazonaws.com"
    echo "Bucket $1 is created successfully"
}


function put_bucket_policy(){
    # $1 bucket_name
    # $2 bucket_policy

    echo "Putting policy for $1 bucket ..."

    if ! output=$(
            aws s3api put-bucket-policy \
            --region $region \
            --bucket "$1" \
            --policy "$2"
        ); 
    then
        echo "Error while putting policy"
        exit 1
    fi

    echo "Put Policy for $1 bucket successfully"
}


create_bucket "${app_bucket[name]}"
app_bucket[domain]="$rt"
print_sperator

create_bucket "${lambda_code_bucket[name]}"
lambda_code_bucket[domain]="$rt"
print_sperator
 
