#!/bin/bash

jwt_secret_name="<<jwt_secret_name>>"
db_secret_name="<<db_secret_name>>"
parametar_config_name="<<parametar_config_name>>"


echo "Chandge Dir to /home/ubuntu"
cd /home/ubuntu

##############################

echo "APT update"
sudo apt update

##############################

echo "Install required packages"
sudo apt install -y git jq unzip

##############################

echo "Install AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

rm -r aws awscliv2.zip


##############################

echo "Get github private key"

aws secretsmanager get-secret-value \
--secret-id github-private-key \
--query SecretString \
--output text  \
| jq -r '.Key' \
> /home/ubuntu/.ssh/id_ed25519

sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519 

chmod 600 /home/ubuntu/.ssh/id_ed25519

##############################


echo "ssh keyscan github"

sudo -u ubuntu touch /home/ubuntu/.ssh/known_hosts

sudo -u ubuntu ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts


##############################

echo "Preparing APT to install Docker"


# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

##############################

echo "Installing Docker"

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker

##############################

echo "Allow ubuntu user to use docker"

sudo usermod -aG docker ubuntu

##############################

echo "Cloning Repo"

sudo -u ubuntu git clone --branch main git@github.com:MohamedAlkady65/pixlize-back.git app

cd ./app

##############################

echo "Building .ENV File"


jwt_secret=$(aws secretsmanager get-secret-value \
--secret-id "$jwt_secret_name" \
--query SecretString \
--output text  \
| jq -r '.Secret')


db_secret=$(aws secretsmanager get-secret-value \
--secret-id "$db_secret_name" \
--query SecretString \
--output text)

db_user=$(echo "$db_secret" | jq -r ".username")
db_password=$(echo "$db_secret" | jq -r ".password")


parametar_config=$(aws ssm  get-parameter \
--name "$parametar_config_name" \
--query "Parameter.Value" \
--output text
)


keys_to_replace=("<<DB_USER>>" "<<DB_PASS>>" "<<JWT_SECRET>>")
values_to_replace=("$db_user" "$db_password" "$jwt_secret")


for i in "${!keys_to_replace[@]}"; do
    parametar_config=$(echo "${parametar_config//${keys_to_replace[$i]}/${values_to_replace[$i]}}")
done


echo "$parametar_config" > ".env"

##############################

echo "Start Service"