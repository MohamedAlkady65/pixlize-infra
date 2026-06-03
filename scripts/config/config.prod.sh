#!/bin/bash

app=pixlize
env=prod

region=eu-west-3
az1=eu-west-3a
az2=eu-west-3b

prefix="$app-$env"

app_env="production"

app_back_port_in_container="3000"
app_back_port_in_host="80"
app_front_port_in_container="80"
app_front_port_in_host="80"

domain="alkady.link"

app_back_domain="api.pixlize.$domain"

app_front_domain="front.pixlize.$domain"

app_system_domain="system.pixlize.$domain"

app_bucket_domain="bucket.pixlize.$domain"