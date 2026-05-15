#!/bin/bash

function print_sperator(){
    echo "-----------------------------------------------------------------------"
}

keys_dir="/home/alkady/Desktop/key_pairs"
github_private_key_secret_arn="arn:aws:secretsmanager:eu-west-3:595923192190:secret:github-private-key-PyzdaS"

source ./config/config.prod.sh

source ./vpc.sh
source ./security.sh
source ./database.sh
source ./config_parametars.sh
source ./app/app.sh