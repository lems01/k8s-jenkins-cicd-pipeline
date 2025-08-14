# 🚀 CI/CD Pipeline Deployment on Kubernetes Cluster using Jenkins

This project demonstrates a complete DevOps pipeline where code changes made by developers are automatically built, tested, and deployed to a Kubernetes cluster using Jenkins, Docker, Ansible, and GitHub integrations.

---

## 📌 Pipeline Flow

The following steps outline the CI/CD process:

1. **Developer 💻**  
   A developer pushes code changes to a GitHub repository.

2. **GitHub 🐙**  
   The push event triggers a **webhook** that notifies Jenkins of the change.

3. **Jenkins ⚙️**  
   Jenkins serves as the CI/CD orchestrator. It:
   - Pulls the latest code.
   - Builds a Docker image.
   - Runs tests (if any).
   - Pushes the image to **Docker Hub**.

4. **Docker Hub 🐳**  
   The Docker image repository stores the latest image, ready for deployment.

5. **Ansible ⚙️**  
   Ansible pulls the updated image from Docker Hub and automates the deployment tasks.

6. **Kubernetes Cluster ☸️**  
   Finally, the Kubernetes cluster deploys the updated container image using rolling updates or another deployment strategy.

---

## 🔁 End-to-End Workflow Diagram

```text
Developer 💻
     ↓
GitHub 🐙 (Webhook Trigger)
     ↓
Jenkins ⚙️ (CI/CD Automation)
     ↓
Docker Hub 🐳 (Image Storage)
     ↓
Ansible ⚙️ (Automation Tool)
     ↓
Kubernetes Cluster ☸️ (Container Orchestration)
```

---

## 🧱 Infrastructure Setup

This project is deployed on **AWS EC2** using **three Ubuntu instances**:

| Instance Type | Role(s)                   | Description                             |
|---------------|----------------------------|-----------------------------------------|
| `t2.micro`    | Jenkins, Ansible           | Orchestrates CI/CD and automation tasks |
| `t3.medium`   | Kubernetes Nodes (Master/Worker) | Hosts the containerized workloads       |

> ✅ `t2.micro` is used for lightweight services like Jenkins and Ansible.  
> 💪 `t3.medium` provides the necessary compute for running the Kubernetes cluster efficiently.

---

## 🧰 Tools & Technologies

| Tool          | Role                               |
|---------------|------------------------------------|
| GitHub        | Source code repository              |
| Jenkins       | Continuous Integration & Deployment |
| Docker        | Containerization                    |
| Docker Hub    | Image registry                      |
| Ansible       | Deployment automation               |
| Kubernetes    | Container orchestration             |

---

## 📦 Features

- Fully automated build and deployment pipeline.
- Dockerized application architecture.
- Scalable deployment via Kubernetes.
- Declarative infrastructure with Ansible playbooks.
- GitHub-driven workflow with webhook triggers.

---

## 🚀 Getting Started

> **Prerequisites**:
- Kubernetes cluster (Minikube, EKS, GKE, etc.)
- Jenkins server (installed on VM or Kubernetes)
- Docker Hub account
- GitHub repository with application source code


### 1. Setting up Jenkins, Ansible, DOcker and Minikube
- installing Jenkins on the first instance
   - Append the Debian package repository address to the server’s sources.list
   ```bash
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   ```
   - Jenkins needs Java to run, install Java if not available on the machine
   ```bash
   sudo apt install openjdk-17-jdk -y
   ```
   - Update repository and install Jenkins
   ```bash
   sudo apt update
   sudo apt install jenkins
   ```
   - start Jenkins service
   ```bash
   sudo systemctl start jenkins
   ```
- Opening the firewall
```bash
sudo ufw allow 8080
sudo ufw allow OpenSSH
sudo ufw enable
```
- Setting up Jenkins
To set up your installation, visit Jenkins on its default port, 8080, using your server domain name or IP address: http://your_server_ip_or_domain:8080
You should receive the Unlock Jenkins screen, which displays the location of the initial password: 

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

- Install Plugins
Go to settings -> Plugins -> available Plugins
Search for ssh agent and install, after installation, click on restart then login


- SSH into the Ansible Server using the public IP and run the commands to install Ansible
```bash
sudo apt update
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y
sudo apt install ansible -y
```

Run the version command to see if ansible is properly installed
```bash
ansible --version
```

- SSH into the thrid instance which is the web server. Install Minikube and Docker following the script
* Docker

```bash
# Update your existing list of packages
sudo apt update

# Next, install a few prerequisite packages which let apt use packages over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add the GPG key for the official Docker repository to your system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

#Make sure you are about to install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce

# Finally, install Docker
sudo apt install docker-ce

# Check that it’s running
sudo systemctl status docker

# Executing the Docker Command Without Sudo
sudo usermod -aG docker ${USER}

# Login to Docker and enter your password
docker login -u <username>

# 

# Download the latest Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install it to /usr/local/bin
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube with Docker as the driver
minikube start --driver=docker


# Verify installation
docker --version
minikube version
minikube status

```

### 2. Set up a Jenkins job, initialize a GitHub repo, and configure a webhook for automatic code pulls
- Create a DOckerfile *Content of this DockerFile will be explained later in the image building*

```Dockerfile
# Install Apache, unzip, Python3 (for gdown)
RUN apt-get update && \
    apt-get install -y apache2 unzip python3-pip curl && \
    pip3 install gdown && \
    rm -rf /var/lib/apt/lists/*

# Set working directory to Apache's web root
WORKDIR /var/www/html

# Download file from Google Drive using gdown
# Replace FILE_ID with your file's ID
RUN gdown "https://drive.google.com/uc?id=1I-dT98YWe-hVguQxbQEKGTBnJwS8Xdhg"

# Unzip and set up website
RUN unzip wix.zip && \
    cp -rvf wix/* . && \
    rm -rf wix wix.zip

# Expose HTTP port
EXPOSE 80

# Start Apache in foreground
CMD ["apachectl", "-D", "FOREGROUND"]
```

- Create a Pipeline job in Jenkins
   - Open your Jenkins web interface, login with your credentials
   - Create a New Pipeline Job
      1. Click "New Item" from the dashboard.
      2. Enter a name for your job.
      3. Select "Pipeline" and click OK.
      4. In triggers, select `GitHub hook trigger for GITScm polling`
      5. In pipeline, select Pipeline script
      6. Tick Use Groovy Sandbox
      7. To add script you can either enter it in the box or use the pipeline syntax. if using the Pipeline syntax script
         - Select Git.
         - Add the GitHub repository URL.
         - Add credentials (if private).
         - Specify the branch (master) then Click on `Generate Pipeline Script`
         - Copy and paste the link in the Pipeline 

            ```Groovy
            node {
               
               stage('Git checkout'){
                  git 'https://github.com/lems01/k8s-jenkins-cicd-pipeline.git'
               }
            }
            ```
      8. Click on Apply then Save
      9. Click on Build to test, check the console to see the output

- Configure Webhook
   1. Goto `Settings` in your repository and select webhooks. Click on `Add webhook`
   2. Paste the address of your jenkins in the payload url `<public-ip/8080/github-webhook>`
   3. Content type, select `application/json`
   4. Go to credentials in Jenkins to generate API token copy the token and past in `Secret`. `Click on Add webhook`
   5. Reload the page to get a green tick 

- Test if the Webhook is working. Edit the Dockerfile, expose it on port 22 alo, them push to your respository. Goto jenkins and confirm if the job was triggered.

### 3. Send Dockerfile to Ansible using SSH Agent in Jenkins
1. Select the `Pipeline` job and click on `Configure`. Add another stage to the script you have before. *Note: All script must be well Indented*
```Groovy
stage('Send Dockerfile to the Ansible server using SSH Agent') {
}
```
2. Click on the Pipeline Syntax, select sshagent: SSH Agent, click on `Add` and select `Jenkins`
   - Under kind, select `SSH Username with private key`
   - Enter your username
   - In `Private Key` section, tick `Enter directly` and click on add, paste the private key and click on `Add`
   - Click on `Generate Pipeline Script` and copy the script generated and paste into the `Script`
   - Then add the following script
```
# Establish connection to the Ansible Server
sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address>'

# Copy Dockerfile to the Ansible Server
sh 'scp /var/lib/jenkins/workspace/pipeline/* ubuntu@<public ip address>:/home/ubuntu'
```

   - Your final ouput of your pipeline script should be similar to this
```Groovy
node {
    
    stage('Git checkout'){
        git 'https://github.com/lems01/k8s-jenkins-cicd-pipeline.git'
    }
    
    stage('Send Dockerfile to the Ansible server using SSH Agent') {
        sshagent(['2642dc45-1d87-4128-8fa7-4ed524734811']) {
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address>'
            sh 'scp /var/lib/jenkins/workspace/pipeline/* ubuntu@<public ip address>:/home/ubuntu'
        }
    }
}
```
   - Click on `Apply` then `Save`. Build again and check if it was successful. Login to the Ansible Server to confirm File has been copied.

### 4. Building and tagging docker images
- Copy and paste the script below in the pipeline script *(Same way you access it in step 3)*

```Groovy
   stage('Build and TagDocker Image') {
        sshagent(['2642dc45-1d87-4128-8fa7-4ed524734811']) {
            // SSH into remote Ubuntu server and change directory to the project folder
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> cd /home/ubuntu/'

            // Build a Docker image on the remote server with a version tag using Jenkins job name and build ID
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker image build -t $JOB_NAME:v1.$BUILD_ID .'

            // Tag the built image with a versioned tag for pushing to Docker Hub
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker tag $JOB_NAME:v1.$BUILD_ID lems01/$JOB_NAME:v1.$BUILD_ID'

            // Tag the same image as "latest" for Docker Hub
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker tag $JOB_NAME:v1.$BUILD_ID lems01/$JOB_NAME:latest'
        }
    }
```
- Build and check console logs. Verify the image on the Ansible Server using `docker images` on the Ansible Server

### 5. Pushing docker images to DockerHub

```Groovy
stage('Push docker images to docker hub') {
    // Use SSH Agent credentials to connect to the remote server
    sshagent(['2642dc45-1d87-4128-8fa7-4ed524734811']) {
        
        // Retrieve Docker Hub password from Jenkins credentials securely
        withCredentials([string(credentialsId: 'dockerhub_password', variable: 'dockerhub_password')]) {
            
            // Log in to Docker Hub from the remote server
            sh "ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker login -u lems01 -p ${dockerhub_password}"
            
            // Push the version-tagged image to Docker Hub
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker image push lems01/$JOB_NAME:v1.$BUILD_ID'
            
            // Push the latest tag of the image to Docker Hub
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@<public ip address> docker image push lems01/$JOB_NAME:latest'
        }
    }
}

```

***Creating and Using Docker Hub Password in Jenkins Pipeline (GUI Syntax)***

   #### 1. Add the Password to Jenkins
   1. Go to **Manage Jenkins → Credentials**.
   2. Select **(global)** scope.
   3. Click **Add Credentials**.
   4. **Kind**: `Secret text`.
   5. **Secret**: Enter your Docker Hub password.
   6. **ID**: `dockerhub_password`.
   7. Save.

   #### 2. Generate Pipeline Syntax
   1. Open your pipeline job.
   2. Click **Pipeline Syntax**.
   3. Choose **withCredentials: Bind credentials to variables**.
   4. **Binding type**: `Secret text`.
   5. **Credentials**: Select `dockerhub_password`.
   6. **Variable**: `dockerhub_password`.
   7. Click **Generate Pipeline Script**.

   #### 3. Example Output
   ```groovy
   withCredentials([string(credentialsId: 'dockerhub_password', variable: 'dockerhub_password')]) {
      // script
   }
   ```

### 6. Deploying the Image on the Kubernetes Cluster
- Set up an SSH connection between the Ansible Server and the Web Server. On the Web Server edit the **ssh_config** file using `sudo vi /etc/ssh/ssh_config`, add
```
    PermitRootLogin yes
    PasswordAuthentication yes
```
then restart the service `sudo systemctl restart ssh`
- On the Ansible Server generate a SSH key `ssh-keygen` then, copy the public key to the Web Server `ssh-copy-id -i root@<public_ip>`. After this SSH into the Web Server `SSH root@<public ip>`
- Add the  address of the Web Server to the host file in Ansible
`vi /etc/ansible/hosts` add
```hosts
[node]
<public IP address>
```
Test the connection using `ansible -m ping node`
- Add the script to the Jenkins pipeline to move the files to the Ansible Server also
```Groovy
stage('Copy files from Ansible to Web Server') {
        sshagent(['2642dc45-1d87-4128-8fa7-4ed524734811']) {
            sh 'ssh -o StrictHostKeyChecking=no ubuntu@3.83.141.56'
            sh 'scp /var/lib/jenkins/workspace/pipeline/* ubuntu@3.83.141.56:/home/ubuntu'
        }
    }
```

- Before you build, make sure you have all the yaml file in your working directory so that it can be pushed along to github. **ansible.yaml, Deployment.yaml, Service.yaml**, it will be provided in the github for you to copy and edit it the way you want it
note that for you to be able to run kubectl commands, you need to do the following.
1. copy the config file and certificates from the Web Server
```bash
scp ~/.kube/config ubuntu@<OTHER_SERVER_IP>:/home/ubuntu/minikube-config
scp ~/.minikube/ca.crt ubuntu@<OTHER_SERVER_IP>:/home/ubuntu/.minikube/ca.crt
scp ~/.minikube/profiles/minikube/client.crt ubuntu@<OTHER_SERVER_IP>:/home/ubuntu/.minikube/profiles/minikube/client.crt
scp ~/.minikube/profiles/minikube/client.key ubuntu@<OTHER_SERVER_IP>:/home/ubuntu/.minikube/profiles/minikube/client.key
```
2. Create the directories if needed and edit the config and change the ip addrress tothe public ip address of the Web Server, then move it to the folder created 
```Bash
ssh ubuntu@<OTHER_SERVER_IP> "mkdir -p ~/.minikube/profiles/minikube"
```
`server: https://127.0.0.1:<port>`
`mv ~/minikube-config ~/.kube/config`

3. Open the API port in AWS
- Go to your Minikube server’s AWS Security Group.
- Add an Inbound Rule:
- Type: Custom TCP
- Port: (same as <port> in kubeconfig, usually 8443 or 6443)
- Source: Private IP of your other AWS server (or same security group if in same VPC).
4. Install `kubectl`
```Bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
5. Enable port forwarding, run this on the Web Server
```Bash
# Check if iptables is installed
sudo iptables -L

# Run these commands on the Minikube server (where Minikube is running):
sudo iptables -t nat -A PREROUTING -p tcp --dport 8443 -j DNAT --to-destination 192.168.49.2:8443
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# To make the rules persistent across reboots, you’ll want to save them. On Ubuntu:
sudo apt install iptables-persistent
sudo netfilter-persistent save
```
6. Once, that is done run your ansible playbook `ansible-playbook ansible.yaml --check` to check if it's okay to run. 

### 7. Build on Jenkins, once it is successful. Use your public IP to access your website.
**All scripts and imgaes used in this porject will be shared**
---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙌 Acknowledgements

- [Jenkins](https://www.jenkins.io/)
- [Docker](https://www.docker.com/)
- [Kubernetes](https://kubernetes.io/)
- [Ansible](https://www.ansible.com/)
- [GitHub](https://github.com/)
