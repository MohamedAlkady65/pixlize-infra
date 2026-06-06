#!/bin/bash

app=pixlize

region=eu-west-3
az1=eu-west-3a
az2=eu-west-3b

prefix="$app-$env"


app_back_port_in_container="3000"
app_back_port_in_host="80"
app_front_port_in_container="80"
app_front_port_in_host="80"

db_port=3306

app_back_domain="api.pixlize.$domain"

app_front_domain="front.pixlize.$domain"

app_system_domain="pixlize.$domain"

app_bucket_domain="bucket.pixlize.$domain"

keys_dir="~/${app}_key_pairs"

app_back_repo="MohamedAlkady65/pixlize-back"

app_front_repo="MohamedAlkady65/pixlize-front"

app_lambda_repo="MohamedAlkady65/pixlize-lambda"


account_id=$(aws sts get-caller-identity --query Account --output text)
account_id="${account_id%$'\n'}"