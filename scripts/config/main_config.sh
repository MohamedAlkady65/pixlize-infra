#!/bin/bash

function print_sperator(){
    echo "-----------------------------------------------------------------------"
}

keys_dir="/home/alkady/Desktop/key_pairs"
github_private_key_secret_arn="arn:aws:secretsmanager:eu-west-3:595923192190:secret:github-private-key-PyzdaS"

app_back_repo="MohamedAlkady65/pixlize-back"
app_back_branch="main"

app_front_repo="MohamedAlkady65/pixlize-front"
app_front_branch="main"
