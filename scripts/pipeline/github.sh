declare -A github_connection_app
github_connection_app[name]="$app-app-github-connection"



function create_github_connection(){
    # $1 name

    echo "Create $1 github connection ..."

    if ! check_exists=$(
        aws codeconnections list-connections \
            --region "$region" \
            --provider-type-filter GitHub \
            --query "Connections[?ConnectionName=='$1'] | [0] | ConnectionArn" \
            --output text
        );
    then
        echo "Error while creating github connection"
        exit 1
    fi

    check_exists="${check_exists%$'\n'}"

    if [[ "$check_exists" != "None" ]]; then
        arn="$check_exists"
        echo "Github connection is already exists"
        echo "$arn"
        rt="$arn"
        return 0
    fi

    if ! arn=$(
        aws codeconnections create-connection \
            --region "$region" \
            --provider-type GitHub \
            --connection-name "$1" \
            --query "ConnectionArn" \
            --output text
    );
    then
        echo "Error while creating github connection"
        exit 1
    fi

    echo "Github connection $1 is created successfully"
    echo "$arn"
    rt="$arn"
}


function wait_github_connection_handshake(){
    # $1 connection_arn

    max_tries=20
    try=1

    echo "Waiting for github connection handshake ..."
    echo "Complete the OAuth handshake in the AWS console:"
    echo "https://$region.console.aws.amazon.com/codesuite/settings/connections"

    while [[ $try -le $max_tries ]]; do
        echo "Try $try ..."

        if ! status=$(
            aws codeconnections get-connection \
                --region "$region" \
                --connection-arn "$1" \
                --query "Connection.ConnectionStatus" \
                --output text
            );
        then
            echo "Error while checking github connection status"
            exit 1
        fi

        status="${status%$'\n'}"

        if [[ "$status" == "AVAILABLE" ]]; then
            echo "Github connection handshake completed successfully"
            return 0
        fi

        if [[ "$status" == "ERROR" ]]; then
            echo "Github connection handshake failed"
            exit 1
        fi

        sleep 20
        (( try++ ))
    done

    echo "Github connection handshake timed out after $max_tries tries"
    exit 1
}



create_github_connection "${github_connection_app[name]}"
github_connection_app[arn]="$rt"

print_sperator

wait_github_connection_handshake "${github_connection_app[arn]}"

print_sperator