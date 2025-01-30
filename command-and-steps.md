## Create 3 ec2 instance with at least t3-micro and 15Gi
# jenkins master
# Jenkins agent
install jenkins docker
    1  sudo vi /etc/hostname ## to change the hostname to jenkins agent
    2  sudo reboot
    3  sudo apt update
    4  sudo apt install fontconfig openjdk-17-jre
    5  docker --version
    6  sudo apt install docker.io
    7  sudo usermod -aG docker $USER ## to give root access to docker user
    Go to /etc/ssh/sshd_config and uncomment on Jenkins agent and jenkins master
        PubkeyAuthentication yes 
        AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
    sudo service ssh reload ## to relaod the ssh service
    in the jenkins master, do ssh-keygen to generate a key. copy the .pub key to the jenkins-agent at .ssh/authorized_keys
 use the jenkins master ip:8080 to open the jenkins and add jenkins agent to the node
 # Integrate Maven to Jenkins
 # Add Github credentials to Jenkins

# sonarque
# TO change the hostname
echo "NEW_HOSTNAME" | sudo tee /etc/hostname
sudo sed -i "s/^127\.0\.0\.1.*/127.0.0.1 localhost Jenkins-master/" /etc/hosts
sudo reboot
 ### install java and Jenkins

 sudo apt update
sudo apt install fontconfig openjdk-17-jre


 sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
