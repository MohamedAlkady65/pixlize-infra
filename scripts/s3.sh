account_id=$(aws sts get-caller-identity --query Account --output text)

app_bucket_name="$prefix-app-bucket-$account_id"

lambda_code_bucket_name="$prefix-lambda-code-bucket-$account_id"



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
        return 0
    fi


    if ! output=$(aws s3api create-bucket \
                    --bucket "$1" \
                    --region $region \
                    --create-bucket-configuration "LocationConstraint=$region"); 
    then
        echo "Error while creating bucket"
        exit 1
    fi

    echo "Bucket $1 is created successfully"
}


create_bucket "${app_bucket_name}"
print_sperator
create_bucket "${lambda_code_bucket_name}"
print_sperator
 
