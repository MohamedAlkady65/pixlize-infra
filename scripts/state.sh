declare -- BASH="/bin/bash"
declare -r BASHOPTS="checkwinsize:cmdhist:complete_fullquote:extquote:force_fignore:globasciiranges:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath"
declare -i BASHPID
declare -A BASH_ALIASES=()
declare -a BASH_ARGC=([0]="1" [1]="1" [2]="0")
declare -a BASH_ARGV=([0]="./app/launch_template.sh" [1]="./app/app.sh")
declare -- BASH_ARGV0
declare -A BASH_CMDS=()
declare -- BASH_COMMAND
declare -a BASH_LINENO=([0]="1" [1]="15" [2]="0")
declare -a BASH_SOURCE=([0]="./app/launch_template.sh" [1]="./app/app.sh" [2]="./deploy.sh")
declare -- BASH_SUBSHELL
declare -ar BASH_VERSINFO=([0]="5" [1]="1" [2]="16" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")
declare -- BASH_VERSION="5.1.16(1)-release"
declare -x BUNDLED_DEBUGPY_PATH="/home/alkady/.cursor/extensions/ms-python.debugpy-2026.6.0-linux-x64/bundled/libs/debugpy"
declare -x CHROME_DESKTOP="cursor.desktop"
declare -x COLORTERM="truecolor"
declare -- COMP_WORDBREAKS
declare -x DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
declare -x DESKTOP_SESSION="ubuntu"
declare -a DIRSTACK=()
declare -x DISPLAY=":0"
declare -- EPOCHREALTIME
declare -- EPOCHSECONDS
declare -ir EUID="1000"
declare -x FC_FONTATIONS="1"
declare -a FUNCNAME
declare -x GDK_BACKEND="wayland"
declare -x GDMSESSION="ubuntu"
declare -x GIO_LAUNCHED_DESKTOP_FILE="/usr/share/applications/cursor.desktop"
declare -x GIO_LAUNCHED_DESKTOP_FILE_PID="4607"
declare -x GIT_ASKPASS="/usr/share/cursor/resources/app/extensions/git/dist/askpass.sh"
declare -x GJS_DEBUG_OUTPUT="stderr"
declare -x GJS_DEBUG_TOPICS="JS ERROR;JS LOG"
declare -x GK_GL_ADDR="http://127.0.0.1:40363"
declare -x GK_GL_PATH="/tmp/gitkraken/gitlens/gitlens-ipc-server-4607-40363.json"
declare -x GNOME_DESKTOP_SESSION_ID="this-is-deprecated"
declare -x GNOME_SETUP_DISPLAY=":1"
declare -x GNOME_SHELL_SESSION_MODE="ubuntu"
declare -a GROUPS=()
declare -x GTK_MODULES="gail:atk-bridge"
declare -i HISTCMD
declare -x HOME="/home/alkady"
declare -- HOSTNAME="alkady-machine"
declare -- HOSTTYPE="x86_64"
declare -- IFS=" 	
"
declare -x IM_CONFIG_CHECK_ENV="1"
declare -x IM_CONFIG_PHASE="1"
declare -x INVOCATION_ID="333f0010326d4f3f97ad457334869d46"
declare -x JOURNAL_STREAM="8:25360"
declare -x LANG="en_GB.UTF-8"
declare -x LANGUAGE="en_GB:en"
declare -x LC_ADDRESS="en_US.UTF-8"
declare -x LC_IDENTIFICATION="en_US.UTF-8"
declare -x LC_MEASUREMENT="en_US.UTF-8"
declare -x LC_MONETARY="en_US.UTF-8"
declare -x LC_NAME="en_US.UTF-8"
declare -x LC_NUMERIC="en_US.UTF-8"
declare -x LC_PAPER="en_US.UTF-8"
declare -x LC_TELEPHONE="en_US.UTF-8"
declare -x LC_TIME="en_US.UTF-8"
declare -x LESSCLOSE="/usr/bin/lesspipe %s %s"
declare -x LESSOPEN="| /usr/bin/lesspipe %s"
declare -- LINENO
declare -x LOGNAME="alkady"
declare -x LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"
declare -- MACHTYPE="x86_64-pc-linux-gnu"
declare -x MANAGERPID="1136"
declare -x OLDPWD="/home/alkady/Desktop/pixlize"
declare -- OPTERR="1"
declare -i OPTIND="1"
declare -- OSTYPE="linux-gnu"
declare -x PAPERSIZE="letter"
declare -x PATH="/home/alkady/.local/bin:/home/alkady/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:/usr/local/go/bin:/home/alkady/.cursor/extensions/ms-python.debugpy-2026.6.0-linux-x64/bundled/scripts/noConfigScripts:/usr/local/go/bin"
declare -a PIPESTATUS=([0]="0")
declare -ir PPID="5864"
declare -- PS4="+ "
declare -x PWD="/home/alkady/Desktop/pixlize/infra/scripts"
declare -x PYDEVD_DISABLE_FILE_VALIDATION="1"
declare -x QT_ACCESSIBILITY="1"
declare -x QT_IM_MODULE="ibus"
declare -i RANDOM
declare -- SECONDS
declare -x SESSION_MANAGER="local/alkady-machine:@/tmp/.ICE-unix/1299,unix/alkady-machine:/tmp/.ICE-unix/1299"
declare -x SHELL="/bin/bash"
declare -r SHELLOPTS="braceexpand:hashall:interactive-comments"
declare -x SHLVL="2"
declare -i SRANDOM
declare -x SSH_AGENT_LAUNCHER="gnome-keyring"
declare -x SSH_AUTH_SOCK="/run/user/1000/keyring/ssh"
declare -x SYSTEMD_EXEC_PID="1332"
declare -x TERM="xterm-256color"
declare -x TERM_PROGRAM="vscode"
declare -x TERM_PROGRAM_VERSION="3.3.27"
declare -ir UID="1000"
declare -x USER="alkady"
declare -x USERNAME="alkady"
declare -x VSCODE_DEBUGPY_ADAPTER_ENDPOINTS="/home/alkady/.cursor/extensions/ms-python.debugpy-2026.6.0-linux-x64/.noConfigDebugAdapterEndpoints/endpoint-b0a266f3a22a0132.txt"
declare -x VSCODE_GIT_ASKPASS_EXTRA_ARGS=""
declare -x VSCODE_GIT_ASKPASS_MAIN="/usr/share/cursor/resources/app/extensions/git/dist/askpass-main.js"
declare -x VSCODE_GIT_ASKPASS_NODE="/usr/share/cursor/cursor"
declare -x VSCODE_GIT_IPC_AUTH_TOKEN="c140d7547b7db27f4c06b53232dd041d2bfedb863e05d5558e84d00b3325b77d"
declare -x VSCODE_GIT_IPC_HANDLE="/run/user/1000/vscode-git-591ae7fe13.sock"
declare -x WAYLAND_DISPLAY="wayland-0"
declare -x XAUTHORITY="/run/user/1000/.mutter-Xwaylandauth.26ZMP3"
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
declare -- app="pixlize"
declare -- app_back_config_name="pixlize-prod-app-back-config"
declare -- app_back_config_value="DB_HOST=mysql
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
declare -- app_front_config_name="pixlize-prod-app-front-config"
declare -- app_front_config_value="VITE_API_URL=http://localhost:3000
VITE_WS_URL=http://localhost:3000"
declare -- attached_vpc_id="vpc-04d14a1f73e62b6bb"
declare -- az1="eu-west-3a"
declare -- az2="eu-west-3b"
declare -- check_exists="{
    \"DBInstanceIdentifier\": \"pixlize-prod-db\",
    \"DBInstanceClass\": \"db.t3.micro\",
    \"Engine\": \"mysql\",
    \"DBInstanceStatus\": \"backing-up\",
    \"MasterUsername\": \"admin\",
    \"Endpoint\": {
        \"Address\": \"pixlize-prod-db.cxuiym4ikyl0.eu-west-3.rds.amazonaws.com\",
        \"Port\": 3306,
        \"HostedZoneId\": \"ZMESEXB7ZGGQ3\"
    },
    \"AllocatedStorage\": 20,
    \"InstanceCreateTime\": \"2026-05-13T16:52:43.804000+00:00\",
    \"PreferredBackupWindow\": \"13:34-14:04\",
    \"BackupRetentionPeriod\": 1,
    \"DBSecurityGroups\": [],
    \"VpcSecurityGroups\": [
        {
            \"VpcSecurityGroupId\": \"sg-03e91f0ae838c8809\",
            \"Status\": \"active\"
        }
    ],
    \"DBParameterGroups\": [
        {
            \"DBParameterGroupName\": \"default.mysql8.4\",
            \"ParameterApplyStatus\": \"in-sync\"
        }
    ],
    \"AvailabilityZone\": \"eu-west-3a\",
    \"DBSubnetGroup\": {
        \"DBSubnetGroupName\": \"pixlize-prod-db-subnet-group\",
        \"DBSubnetGroupDescription\": \"pixlize-prod-db-subnet-group\",
        \"VpcId\": \"vpc-04d14a1f73e62b6bb\",
        \"SubnetGroupStatus\": \"Complete\",
        \"Subnets\": [
            {
                \"SubnetIdentifier\": \"subnet-0cfc9b4a2138d4d24\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3a\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            },
            {
                \"SubnetIdentifier\": \"subnet-030280d286f96bbb8\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3b\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            }
        ]
    },
    \"PreferredMaintenanceWindow\": \"fri:03:30-fri:04:00\",
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
    \"DbiResourceId\": \"db-GD2THON4GYOQ4K3IYEXDKP6OL4\",
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
    \"ActivityStreamStatus\": \"stopped\",
    \"BackupTarget\": \"region\",
    \"CertificateDetails\": {
        \"CAIdentifier\": \"rds-ca-rsa2048-g1\",
        \"ValidTill\": \"2027-05-13T16:51:19+00:00\"
    },
    \"MasterUserSecret\": {
        \"SecretArn\": \"arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-743e09f3-53cb-477c-803d-340dee1dc76b-U9MfCK\",
        \"SecretStatus\": \"active\",
        \"KmsKeyId\": \"arn:aws:kms:eu-west-3:595923192190:key/baac58b4-b86a-4841-bf94-ffc30742008e\"
    },
    \"DedicatedLogVolume\": false,
    \"IsStorageConfigUpgradeAvailable\": false,
    \"EngineLifecycleSupport\": \"open-source-rds-extended-support\"
}"
declare -a current_rules=([0]="sgr-0824c2f3f3cca393c")
declare -- db="{
    \"DBInstanceIdentifier\": \"pixlize-prod-db\",
    \"DBInstanceClass\": \"db.t3.micro\",
    \"Engine\": \"mysql\",
    \"DBInstanceStatus\": \"backing-up\",
    \"MasterUsername\": \"admin\",
    \"Endpoint\": {
        \"Address\": \"pixlize-prod-db.cxuiym4ikyl0.eu-west-3.rds.amazonaws.com\",
        \"Port\": 3306,
        \"HostedZoneId\": \"ZMESEXB7ZGGQ3\"
    },
    \"AllocatedStorage\": 20,
    \"InstanceCreateTime\": \"2026-05-13T16:52:43.804000+00:00\",
    \"PreferredBackupWindow\": \"13:34-14:04\",
    \"BackupRetentionPeriod\": 1,
    \"DBSecurityGroups\": [],
    \"VpcSecurityGroups\": [
        {
            \"VpcSecurityGroupId\": \"sg-03e91f0ae838c8809\",
            \"Status\": \"active\"
        }
    ],
    \"DBParameterGroups\": [
        {
            \"DBParameterGroupName\": \"default.mysql8.4\",
            \"ParameterApplyStatus\": \"in-sync\"
        }
    ],
    \"AvailabilityZone\": \"eu-west-3a\",
    \"DBSubnetGroup\": {
        \"DBSubnetGroupName\": \"pixlize-prod-db-subnet-group\",
        \"DBSubnetGroupDescription\": \"pixlize-prod-db-subnet-group\",
        \"VpcId\": \"vpc-04d14a1f73e62b6bb\",
        \"SubnetGroupStatus\": \"Complete\",
        \"Subnets\": [
            {
                \"SubnetIdentifier\": \"subnet-0cfc9b4a2138d4d24\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3a\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            },
            {
                \"SubnetIdentifier\": \"subnet-030280d286f96bbb8\",
                \"SubnetAvailabilityZone\": {
                    \"Name\": \"eu-west-3b\"
                },
                \"SubnetOutpost\": {},
                \"SubnetStatus\": \"Active\"
            }
        ]
    },
    \"PreferredMaintenanceWindow\": \"fri:03:30-fri:04:00\",
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
    \"DbiResourceId\": \"db-GD2THON4GYOQ4K3IYEXDKP6OL4\",
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
    \"ActivityStreamStatus\": \"stopped\",
    \"BackupTarget\": \"region\",
    \"CertificateDetails\": {
        \"CAIdentifier\": \"rds-ca-rsa2048-g1\",
        \"ValidTill\": \"2027-05-13T16:51:19+00:00\"
    },
    \"MasterUserSecret\": {
        \"SecretArn\": \"arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-743e09f3-53cb-477c-803d-340dee1dc76b-U9MfCK\",
        \"SecretStatus\": \"active\",
        \"KmsKeyId\": \"arn:aws:kms:eu-west-3:595923192190:key/baac58b4-b86a-4841-bf94-ffc30742008e\"
    },
    \"DedicatedLogVolume\": false,
    \"IsStorageConfigUpgradeAvailable\": false,
    \"EngineLifecycleSupport\": \"open-source-rds-extended-support\"
}"
declare -- db_instance_class="db.t3.micro"
declare -- db_master_user_secret="arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-743e09f3-53cb-477c-803d-340dee1dc76b-U9MfCK"
declare -- db_name="pixlize-prod-db"
declare -- db_subnet_group_name="pixlize-prod-db-subnet-group"
declare -- engine="mysql"
declare -- env="prod"
declare -- igw_id="igw-08183498420d4a75f"
declare -- igw_name="pixlize-prod-igw"
declare -- keys_dir="/home/alkady/Desktop/key_pairs"
declare -- master_username="admin"
declare -- nat_id="nat-088cddca123a88e5a"
declare -- nat_name="pixlize-prod-nat"
declare -- output="{
    \"Version\": 1,
    \"Tier\": \"Standard\"
}"
declare -- prefix="pixlize-prod"
declare -- region="eu-west-3"
declare -n route_table="route_table_private"
declare -- route_table_name="route_table_public"
declare -A route_table_private=([id]="rtb-0bb44f9a2b4270e91" [internet]="none" [name]="pixlize-prod-private-route-table" )
declare -A route_table_private_nat=([id]="rtb-079ce9aeeb6c09374" [internet]="nat" [name]="pixlize-prod-private-nat-route-table" )
declare -A route_table_public=([id]="rtb-02116b254d942be85" [internet]="igw" [name]="pixlize-prod-public-route-table" )
declare -a route_tables=([0]="route_table_private" [1]="route_table_private_nat" [2]="route_table_public")
declare -- rt="arn:aws:secretsmanager:eu-west-3:595923192190:secret:rds!db-743e09f3-53cb-477c-803d-340dee1dc76b-U9MfCK"
declare -- rt_id="rtb-02116b254d942be85"
declare -a rules=([0]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]")
declare -n sg="sg_db"
declare -A sg_app_back_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-079ad5088f488ce15" [name]="pixlize-prod-app-back-end" )
declare -A sg_app_front_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-07541e7eead478bd1" [name]="pixlize-prod-app-front-end" )
declare -A sg_db=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-03e91f0ae838c8809" [name]="pixlize-prod-db" )
declare -- sg_id="sg-03e91f0ae838c8809"
declare -A sg_load_balancer_back_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-07cdb7af639e2916b" [name]="pixlize-prod-load-balancer-back-end" )
declare -A sg_load_balancer_front_end=([inrules]="IpProtocol=all,IpRanges=[{CidrIp=0.0.0.0/0}]" [id]="sg-0861318b7190f9248" [name]="pixlize-prod-load-balancer-front-end" )
declare -- sg_name="sg_db"
declare -a sgs=([0]="sg_app_front_end" [1]="sg_app_back_end" [2]="sg_load_balancer_front_end" [3]="sg_load_balancer_back_end" [4]="sg_db")
declare -- storage_type="gp3"
declare -n subnet="subnet_private_4"
declare -- subnet_id="subnet-030280d286f96bbb8"
declare -a subnet_ids=([0]="subnet-0cfc9b4a2138d4d24" [1]="subnet-030280d286f96bbb8")
declare -- subnet_name="subnet_private_4"
declare -A subnet_private_1=([type]="private" [id]="subnet-0dae8bb3860d65412" [cidr]="10.0.2.0/24" [az]="eu-west-3a" [name]="pixlize-prod-private-1" [route_table]="route_table_private_nat" )
declare -A subnet_private_2=([type]="private" [id]="subnet-06f89d186bc370a33" [cidr]="10.0.3.0/24" [az]="eu-west-3b" [name]="pixlize-prod-private-2" [route_table]="route_table_private_nat" )
declare -A subnet_private_3=([type]="private" [id]="subnet-0cfc9b4a2138d4d24" [cidr]="10.0.4.0/24" [az]="eu-west-3a" [name]="pixlize-prod-private-3" [route_table]="route_table_private" )
declare -A subnet_private_4=([type]="private" [id]="subnet-030280d286f96bbb8" [cidr]="10.0.5.0/24" [az]="eu-west-3b" [name]="pixlize-prod-private-4" [route_table]="route_table_private" )
declare -A subnet_public_1=([type]="public" [id]="subnet-0052c4965b3561e8e" [cidr]="10.0.1.0/24" [az]="eu-west-3a" [name]="pixlize-prod-public-1" [route_table]="route_table_public" )
declare -a subnets=([0]="subnet_public_1" [1]="subnet_private_1" [2]="subnet_private_2" [3]="subnet_private_3" [4]="subnet_private_4")
declare -- vpc_cidr="10.0.0.0/16"
declare -- vpc_id="vpc-04d14a1f73e62b6bb"
declare -- vpc_name="pixlize-prod-vpc"
