sudo apt update -y
sudo apt install default-jdk-headless -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install jenkins unzip -y
sudo wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
mkdir /home/ubuntu/localBin
sudo unzip ./terraform_0.12.19_linux_amd64.zip -d /home/ubuntu/localBin/
echo "export PATH=$PATH:/home/ubuntu/localBin/" >> .profile