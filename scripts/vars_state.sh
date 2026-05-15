declare -x USER="alkady"
declare -x USERNAME="alkady"
declare -x VSCODE_DEBUGPY_ADAPTER_ENDPOINTS="/home/alkady/.cursor/extensions/ms-python.debugpy-2026.6.0-linux-x64/.noConfigDebugAdapterEndpoints/endpoint-b0a266f3a22a0132.txt"
declare -x VSCODE_GIT_ASKPASS_EXTRA_ARGS=""
declare -x VSCODE_GIT_ASKPASS_MAIN="/usr/share/cursor/resources/app/extensions/git/dist/askpass-main.js"
declare -x VSCODE_GIT_ASKPASS_NODE="/usr/share/cursor/cursor"
declare -x VSCODE_GIT_IPC_AUTH_TOKEN="7feaa9d6ab83e94416a9d22c9101a766fca98a1452fd8d5a2db51fc84b89aee8"
declare -x VSCODE_GIT_IPC_HANDLE="/run/user/1000/vscode-git-591ae7fe13.sock"
declare -x WAYLAND_DISPLAY="wayland-0"
declare -x XAUTHORITY="/run/user/1000/.mutter-Xwaylandauth.ME29O3"
declare -x XDG_CONFIG_DIRS="/etc/xdg/xdg-ubuntu:/etc/xdg"
declare -x XDG_CURRENT_DESKTOP="ubuntu:GNOME"
declare -x XDG_DATA_DIRS="/usr/share/ubuntu:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop"
declare -x XDG_MENU_PREFIX="gnome-"
declare -x XDG_RUNTIME_DIR="/run/user/1000"
declare -x XDG_SESSION_CLASS="user"
declare -x XDG_SESSION_DESKTOP="ubuntu"
declare -x XDG_SESSION_TYPE="wayland"
declare -x XMODIFIERS="@im=ibus"
declare -- _="./parametars.sh"
declare -- allocated_storage="20"
declare -- allocation_id="eipalloc-02a23c90695f8f769"
declare -- app="pixlize"
declare -- app_back_config_arn="arn:aws:ssm:eu-west-3:595923192190:parameter/pixlize-prod-app-back-config"
declare -- app_back_config_name="pixlize-prod-app-back-config"
declare -- app_back_config_value="ENV=
DB_HOST=mysql
DB_PORT=3306
DB_USER=<<DB_USER>>
DB_PASS=<<DB_PASS>>
DB_NAME=pixlize

JWT_SECRET=<<JWT_SECRET>>

AWS_REGION=eu-west-3
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_ENDPOINT=http://localstack:4566

S3_BUCKET_NAME=pixlize-images
SQS_QUEUE_URL=http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/pixlize-jobs
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:pixlize-notifications
SNS_WEBHOOK_URL=http://backend:3000/webhooks/sns

NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173"
declare -- app_front_config_arn="arn:aws:ssm:eu-west-3:595923192190:parameter/pixlize-prod-app-front-config"
declare -- app_front_config_name="pixlize-prod-app-front-config"
declare -- app_front_config_value="ENV=
VITE_API_URL=http://localhost:3000
VITE_WS_URL=http://localhost:3000"
declare -- arn="arn:aws:ssm:eu-west-3:595923192190:parameter/pixlize-prod-app-back-config"
declare -- attached_vpc_id="None"
declare -- az1="eu-west-3a"
declare -- az2="eu-west-3b"
declare -- check_exists="
aws: [ERROR]: An error occurred (DBInstanceNotFound) when calling the DescribeDBInstances operation: DBInstance pixlize-prod-db not found."
declare -a current_rules=()
declare -- db="{
    \"DBInstanceIdentifier\": \"pixlize-prod-db\",
    \"DBInstanceClass\": \"db.t3.micro\",
    \"Engine\": \"mysql\",
    \"DBInstanceStatus\": \"creating\",
    \"MasterUsername\": \"admin\",
    \"AllocatedStorage\": 20,
    \"PreferredBackupWindow\": \"12:28-12:58\",
    \"BackupRetentionPeriod\": 1,
    \"DBSecurityGroups\": [],
    \"VpcSecurityGroups\": [
        {
            \"VpcSecurityGroupId\": \"sg-0be1eaefeb168a786\",
            \"Status\": \"active\"
        }
    ],
    \"DBParameterGroups\": [
        {
            \"DBParameterGroupName\": \"default.mysql8.4\",
            \"ParameterApplyStatus\": \"in-sync\"
        }
    ],
    \"DBSubnetGroup\": {
        \"DBSubnetGroupName\": \"pixlize-prod-db-subnet-group\",
        \"DBSubnetGroupDescription\": \"pixlize-prod-db-subnet-group\",
        \"VpcId\": \"vpc-050330ce0808835d4\",
        \"SubnetGroupStatus\": \"Complete\",
        \"Subnets\": [
            {
                \"SubnetIdentifier\": \"subnet-05b998a9aa4544e91\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3b\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            },
            {
                \"SubnetIdentifier\": \"subnet-03d0693a97845ca3d\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3a\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            }
        ]
    },
    \"PreferredMaintenanceWindow\": \"sun:02:23-sun:02:53\",
    \"UpgradeRolloutOrder\": \"second\",
    \"PendingModifiedValues\": {},
    \"MultiAZ\": false,
    \"EngineVersion\": \"8.4.8\",
    \"AutoMinorVersionUpgrade\": true,
    \"ReadReplicaDBInstanceIdentifiers\": [],
    \"LicenseModel\": \"general-public-license\",
    \"Iops\": 3000,
    \"StorageThroughput\": 125,
    \"OptionGroupMemberships\": [
        {
            \"OptionGroupName\": \"default:mysql-8-4\",
            \"Status\": \"in-sync\"
        }
    ],
    \"PubliclyAccessible\": false,
    \"StorageType\": \"gp3\",
    \"DbInstancePort\": 0,
    \"StorageEncrypted\": false,
    \"DbiResourceId\": \"db-OINOWMZKVJOH3YPR6WAQYU4VDU\",
    \"CACertificateIdentifier\": \"rds-ca-rsa2048-g1\",
    \"DomainMemberships\": [],
    \"CopyTagsToSnapshot\": false,
    \"MonitoringInterval\": 0,
    \"DBInstanceArn\": \"arn:aws:rds:eu-west-3:595923192190:db:pixlize-prod-db\",
    \"IAMDatabaseAuthenticationEnabled\": false,
    \"DatabaseInsightsMode\": \"standard\",
    \"PerformanceInsightsEnabled\": false,
    \"DeletionProtection\": false,
    \"AssociatedRoles\": [],
    \"TagList\": [],
    \"CustomerOwnedIpEnabled\": false,
    \"NetworkType\": \"IPV4\",
    \"BackupTarget\": \"region\",
    \"CertificateDetails\": {
        \"CAIdentifier\": \"rds-ca-rsa2048-g1\"
    },
    \"MasterUserSecret\": {
        \"SecretArn\": \"arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-479c6fae-9f09-4f20-bbab-291d9bb6cf58-HbnHUi\",
        \"SecretStatus\": \"creating\",
        \"KmsKeyId\": \"arn:aws:kms:eu-west-3:595923192190:key/baac58b4-b86a-4841-bf94-ffc30742008e\"
    },
    \"DedicatedLogVolume\": false,
    \"EngineLifecycleSupport\": \"open-source-rds-extended-support\"
}"
declare -- db_instance_class="db.t3.micro"
declare -- db_master_user_secret_arn="arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-479c6fae-9f09-4f20-bbab-291d9bb6cf58-HbnHUi"
declare -- db_name="pixlize-prod-db"
declare -- db_subnet_group_name="pixlize-prod-db-subnet-group"
declare -- engine="mysql"
declare -- env="prod"
declare -- github_private_key_secret_arn="arn:aws:secretsmanager:eu-west-3:595923192190:secret:github-private-key-PyzdaS"
declare -- igw_id="igw-0a09d82399f2d40e5"
declare -- igw_name="pixlize-prod-igw"
declare -- keys_dir="/home/alkady/Desktop/key_pairs"
declare -- master_username="admin"
declare -- nat_id="nat-0cff60afe1e7b1797"
declare -- nat_name="pixlize-prod-nat"
declare -- output="{
    \"Version\": 1,
    \"Tier\": \"Standard\"
}"
declare -- prefix="pixlize-prod"
declare -- region="eu-west-3"
declare -n route_table="route_table_private"
declare -- route_table_name="route_table_public"
declare -A route_table_private=([id]="rtb-0801fc42bf5135c43" [internet]="none" [name]="pixlize-prod-private-route-table" )
declare -A route_table_private_nat=([id]="rtb-014a2cacb1bcfc90c" [internet]="nat" [name]="pixlize-prod-private-nat-route-table" )
declare -A route_table_public=([id]="rtb-05bb38368c3d9fba2" [internet]="igw" [name]="pixlize-prod-public-route-table" )
declare -a route_tables=([0]="route_table_private" [1]="route_table_private_nat" [2]="route_table_public")
declare -- rt="arn:aws:ssm:eu-west-3:595923192190:parameter/pixlize-prod-app-back-config"
declare -- rt_id="rtb-05bb38368c3d9fba2"
declare -a rules=([0]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]")
declare -n sg="sg_db"
declare -A sg_app_back_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-0824db0fef4816e3a" [name]="pixlize-prod-app-back-end" )
declare -A sg_app_front_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-0a2d13cd476e30af4" [name]="pixlize-prod-app-front-end" )
declare -A sg_db=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-0be1eaefeb168a786" [name]="pixlize-prod-db" )
declare -- sg_id="sg-0be1eaefeb168a786"
declare -A sg_load_balancer_back_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-0dbf3521b5f19d7c0" [name]="pixlize-prod-load-balancer-back-end" )
declare -A sg_load_balancer_front_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-08276775d4047c7df" [name]="pixlize-prod-load-balancer-front-end" )
declare -- sg_name="sg_db"
declare -a sgs=([0]="sg_app_front_end" [1]="sg_app_back_end" [2]="sg_load_balancer_front_end" [3]="sg_load_balancer_back_end" [4]="sg_db")
declare -- storage_type="gp3"
declare -n subnet="subnet_private_4"
declare -- subnet_id="subnet-05b998a9aa4544e91"
declare -a subnet_ids=([0]="subnet-03d0693a97845ca3d" [1]="subnet-05b998a9aa4544e91")
declare -- subnet_name="subnet_private_4"
declare -A subnet_private_1=([type]="private" [id]="subnet-0d6ec333506d9d8ee" [cidr]="10.0.2.0/24" [az]="eu-west-3a" [name]="pixlize-prod-private-1" [route_table]="route_table_private_nat" )
declare -A subnet_private_2=([type]="private" [id]="subnet-05ba41c4746ba5e26" [cidr]="10.0.3.0/24" [az]="eu-west-3b" [name]="pixlize-prod-private-2" [route_table]="route_table_private_nat" )
declare -A subnet_private_3=([type]="private" [id]="subnet-03d0693a97845ca3d" [cidr]="10.0.4.0/24" [az]="eu-west-3a" [name]="pixlize-prod-private-3" [route_table]="route_table_private" )
declare -A subnet_private_4=([type]="private" [id]="subnet-05b998a9aa4544e91" [cidr]="10.0.5.0/24" [az]="eu-west-3b" [name]="pixlize-prod-private-4" [route_table]="route_table_private" )
declare -A subnet_public_1=([type]="public" [id]="subnet-0e1564c90e3cd0e36" [cidr]="10.0.1.0/24" [az]="eu-west-3a" [name]="pixlize-prod-public-1" [route_table]="route_table_public" )
declare -a subnets=([0]="subnet_public_1" [1]="subnet_private_1" [2]="subnet_private_2" [3]="subnet_private_3" [4]="subnet_private_4")
declare -- vpc_cidr="10.0.0.0/16"
declare -- vpc_id="vpc-050330ce0808835d4"
declare -- vpc_name="pixlize-prod-vpc"


function print_sperator(){
    echo "-----------------------------------------------------------------------"
}