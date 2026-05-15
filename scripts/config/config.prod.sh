#!/bin/bash

app=pixlize
env=prod

region=eu-west-3
az1=eu-west-3a
az2=eu-west-3b

prefix="$app-$env"

app_env="production"

app_back_port_inside_container="3000"
