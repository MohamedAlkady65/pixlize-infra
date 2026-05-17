#!/bin/bash

parametar_config_name='<<parametar_config_name>>'
port_in_host='<<port_in_host>>'

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

sudo -u ubuntu git clone --branch main git@github.com:MohamedAlkady65/pixlize-front.git app

cd ./app

##############################

echo "Building .ENV File"

parametar_config=$(aws ssm  get-parameter \
--name "$parametar_config_name" \
--query "Parameter.Value" \
--output text
)


echo "$parametar_config" > ".env"

##############################

echo "Start Service"

docker build -t app  .
docker container run -d --name app -p "$port_in_host:80" --env-file .env app