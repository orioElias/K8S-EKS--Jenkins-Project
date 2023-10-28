# Create a Kubernetes Cluster And Deploy Jenkins Using Elastic Kubernetes Service (EKS)

## Table of Contents
1. [EC2 Control Node Setup](#ec2-control-node-setup)
2. [SSH into EC2 Instance](#ssh-into-ec2-instance)
3. [Install Necessary Tools](#install-necessary-tools)
4. [Create an EKS Cluster](#create-an-eks-cluster)
5. [Configure Jenkins](#configure-jenkins)
6. [Integrate with GitHub](#integrate-with-github)
7. [Docker Configuration](#docker-configuration)
8. [Final Steps](#final-steps)

---

### EC2 Control Node Setup
<a id="ec2-control-node-setup"></a>

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
<a id="ssh-into-ec2-instance"></a>

\`\`\`
ssh -i "your-key.pem" ubuntu@<EC2_PUBLIC_IP>
\`\`\`

#### Change Host Name (Optional)
\`\`\`
sudo hostnamectl set-hostname k8s-master
echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts
\`\`\`

---

### Install Necessary Tools
<a id="install-necessary-tools"></a>

#### Update Packages
\`\`\`
sudo apt-get update
\`\`\`

#### Install AWS CLI
\`\`\`
sudo apt install awscli -y
\`\`\`

#### Install python3-pip
\`\`\`
sudo apt install python3-pip
pip install --upgrade awscli
\`\`\`

#### Configure AWS CLI
\`\`\`
aws configure
\`\`\`

- AWS Access Key ID: Your AWS Access Key.
- AWS Secret Access Key: Your AWS Secret Access Key.
- Default region name: The region where you want to create the EKS cluster.
- Default output format: You can leave this as ‘None’.

---

### Create an EKS Cluster
<a id="create-an-eks-cluster"></a>

\`\`\`
eksctl create cluster --name “cluster-name” --region “your-region” --nodes 1 --nodegroup-name “group-name” --node-type “instance-type” --managed
\`\`\`

![Cluster Creation](Images/Cluster_Creation.png)

---

### Confirm Cluster Creation and Setup
<a id="confirm-cluster-creation-and-setup"></a>

\`\`\`
eksctl get cluster --name ‘cluster-name --region “your region”
kubectl version
kubectl create namespace devops
\`\`\`

---

### Allocating An Elastic IP
<a id="allocating-an-elastic-ip"></a>
![Elastic ip(1)](Images/Elastic_ip(1).png)
![Elastic ip(2)](Images/Elastic_ip(2).png)
![Elastic ip(3)](Images/Elastic_ip(3).png)
![Elastic ip(4)](Images/Elastic_ip(4).png)

---

### Configure Jenkins
<a id="configure-jenkins"></a>
![Jenkins Dockerfile](Images/Jenkins_Dockerfile.png)
![Jenkins Deployment YAML File](Images/Jenkins_Deployment_YAML_File.png)

\`\`\`
kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml
kubectl apply -f local-storage.yaml
\`\`\`

#### Expose Jenkins Service
\`\`\`
kubectl apply -f jenkins-service.yaml
\`\`\`

![Expose the Jenkins Service](Images/Expose_the_Jenkins_Service.png)

---

### Integrate with GitHub
<a id="integrate-with-github"></a>
![Create GitHub Account](Images/Create_GitHub_Account.png)
![Create a GitHub Repository (1)](Images/Create_a_GitHub_Repository_(1).png)

#### Configure Jenkins to GitHub
![Add GitHub Configuration In Jenkins :(1)](Images/Add_GitHub_Configuration_In_Jenkins_:(1).png)
![Connect the New GitHub Repository To Jenkins:(1)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(1).png)

---

### Docker Configuration
<a id="docker-configuration"></a>
![Creating Docker Hub credentials](Images/Creating_Docker_Hub_credentials.png)

---

### Final Steps
<a id="final-steps"></a>
![See the pipeline runs](Images/See_the_pipeline_runs.png)

\`\`\`
kubectl apply -f jenkins-cluster-role-binding.yaml
kubectl apply -f jenkins-cluster-role.yaml
\`\`\`
