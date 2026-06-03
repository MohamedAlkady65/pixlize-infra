#!/bin/bash

source ./config/main_config.sh
source ./config/config.prod.sh

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