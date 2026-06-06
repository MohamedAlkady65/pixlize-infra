#!/bin/bash

function print_sperator(){
    echo "-----------------------------------------------------------------------"
}

env_arg="$1"

source ./config/domain_config.sh

case "$env_arg" in
  prod)
    source ./config/config.prod.sh
    ;;
  dev)
    source ./config/config.dev.sh
    ;;
  staging)
    source ./config/config.staging.sh
    ;;
  qc)
    source ./config/config.qc.sh
    ;;
  *)
    echo "Error: invalid environment '$env_arg'" >&2
    echo "Usage: $0 {prod|dev}" >&2
    exit 1
    ;;
esac

source ./config/main_config.sh

source ./vpc.sh
source ./security.sh
source ./database.sh
source ./roles.sh
source ./s3.sh
source ./sqs.sh
source ./sns.sh
source ./lambda.sh
source ./config_parametars.sh
source ./app/launch_template.sh
source ./app/load_balancer.sh
source ./dns.sh
source ./certificate.sh
source ./app/load_balancer_listener.sh
source ./app/auto_scaling_group.sh
source ./pipeline/github.sh
source ./pipeline/codebuild.sh
source ./pipeline/codedeploy.sh
source ./pipeline/codepipeline.sh
source ./app/sns_subscription.sh
source ./cloud_front.sh