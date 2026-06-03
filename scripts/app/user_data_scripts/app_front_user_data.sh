#!/bin/bash

parametar_config_name='<<parametar_config_name>>'
port_in_host='<<port_in_host>>'
port_in_container='<<port_in_container>>'

echo "Chandge Dir to /home/ubuntu"
cd /home/ubuntu

##############################

echo "APT update"
sudo apt update

##############################

echo "Install required packages"
sudo apt install -y git jq unzip ruby-full wget equivs

##############################

echo "Install AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install

rm -r aws awscliv2.zip


##############################

echo "aws CodeDeploy agent"

mkdir ./codedeploy
cd ./codedeploy


wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

chmod +x ./install

cat > ruby3.2-dummy.control << 'EOF'
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: ruby3.2
Version: 3.2.99
Description: Dummy ruby3.2 to satisfy codedeploy dependency
EOF

equivs-build ruby3.2-dummy.control
sudo dpkg -i ruby3.2_3.2.99_all.deb

ln -s /usr/bin/ruby /usr/bin/ruby3.2

sudo ./install auto

sudo service codedeploy-agent start

cd ..
rm -r ./codedeploy

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

echo "Building .ENV File"

mkdir ./app
cd ./app

parametar_config=$(aws ssm  get-parameter \
--name "$parametar_config_name" \
--query "Parameter.Value" \
--output text
)


echo "$parametar_config" > ".env"

chown ubuntu:ubuntu .env

##################################

echo "Save Variable Needed For Code Deploy"

cat > ./codedeploy-env <<EOF

port_in_host=$port_in_host
port_in_container=$port_in_container
image_name=app-image
container_name=app-container
EOF

chown ubuntu:ubuntu ./codedeploy-env


#################################

touch "/home/ubuntu/user_data_script_done"
chown ubuntu:ubuntu "/home/ubuntu/user_data_script_done"