# Create a Kubernetes Cluster And Deploy Jenkins Using Elastic Kubernetes Service (EKS)

## Table of Contents
1. EC2 Control Node Setup
2. SSH into EC2 Instance
3. Install Necessary Tools
4. Create an EKS Cluster
5. Configure Jenkins
6. Integrate with GitHub
7. Docker Configuration
8. Final Steps

---

### EC2 Control Node Setup

**Instance Type**: t3.small  
**AMI**: Ubuntu.

#### Security Group Settings
Ports to Open:
- 22 for SSH
- 80 for HTTP
- 443 for HTTPS

![ec2 instance(configure)](Images/ec2_instance(configure).png)
![ec2 instance(secGroup)](Images/ec2_instance(secGroup).png)

---

### SSH into EC2 Instance

\`\`\`bash
ssh -i "your-key.pem" ubuntu@<EC2_PUBLIC_IP>
\`\`\`

#### Change Host Name (Optional)
\`\`\`bash
sudo hostnamectl set-hostname k8s-master
echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts
\`\`\`

---

### Install Necessary Tools

#### Update Packages
\`\`\`bash
sudo apt-get update
\`\`\`

#### Install AWS CLI
\`\`\`bash
sudo apt install awscli -y
\`\`\`

#### Install python3-pip
\`\`\`bash
sudo apt install python3-pip
pip install --upgrade awscli
\`\`\`

#### Configure AWS CLI
\`\`\`bash
aws configure
\`\`\`

- AWS Access Key ID: Your AWS Access Key.
- AWS Secret Access Key: Your AWS Secret Access Key.
- Default region name: The region where you want to create the EKS cluster.
- Default output format: You can leave this as ‘None’.

---

### Install EKSCTL and Kubectl
\`\`\`bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
\`\`\`

#### Install Kubectl
\`\`\`bash
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
\`\`\`

---

### Create an EKS Cluster
\`\`\`bash
eksctl create cluster \
--name “cluster-name” \
--region “your-region” \
--nodes 1 \
--nodegroup-name “group-name” \
--node-type “instance-type” \
--managed
\`\`\`

![Cluster Creation](Images/Cluster_Creation.png)

---

### Confirm Cluster Creation and Setup
\`\`\`bash
eksctl get cluster --name ‘cluster-name --region “your region”
kubectl version
kubectl create namespace devops
\`\`\`

---

### Allocating An Elastic IP
![Elastic ip(1)](Images/Elastic_ip(1).png)
![Elastic ip(2)](Images/Elastic_ip(2).png)
![Elastic ip(3)](Images/Elastic_ip(3).png)
![Elastic ip(4)](Images/Elastic_ip(4).png)

---

### Configure Jenkins
![Jenkins Dockerfile](Images/Jenkins_Dockerfile.png)
![Jenkins Deployment YAML File](Images/Jenkins_Deployment_YAML_File.png)

\`\`\`bash
kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f local-storage.yaml
\`\`\`

#### Expose Jenkins Service
\`\`\`bash
kubectl apply -f jenkins-service.yaml
\`\`\`

![Expose the Jenkins Service](Images/Expose_the_Jenkins_Service.png)

---

### Integrate with GitHub
![Create GitHub Account](Images/Create_GitHub_Account.png)
![Create a GitHub Repository (1)](Images/Create_a_GitHub_Repository_(1).png)

#### Configure Jenkins to GitHub
![Add GitHub Configuration In Jenkins :(1)](Images/Add_GitHub_Configuration_In_Jenkins_:(1).png)
![Connect the New GitHub Repository To Jenkins:(1)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(1).png)

---

### Docker Configuration
![Creating Docker Hub credentials](Images/Creating_Docker_Hub_credentials.png)

---

### Final Steps
![See the pipeline runs](Images/See_the_pipeline_runs.png)
\`\`\`bash
kubectl apply -f jenkins-cluster-role-binding.yaml
kubectl apply -f jenkins-cluster-role.yaml
\`\`\`

