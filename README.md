# Create a Kubernetes Cluster And Deploy Jenkins, Using Elastic Kubernetes Service(EKS)

## EC2 Control Node

**Instance Type**: t3.small  
**AMI**: Ubuntu.

### Security Group Settings

**Ports to Open**:

- 22 for SSH
- 80 for HTTP
- 443 for HTTPS

![ec2 instance(configure)](Images/ec2_instance(configure).png)
![ec2 instance(secGroup)](Images/ec2_instance(secGroup).png)

---

## SSH into EC2 Instance

\`\`\`bash
ssh -i "your-key.pem" ubuntu@<EC2_PUBLIC_IP>
\`\`\`

### Change Host Name (Optional for comfort)

\`\`\`bash
sudo hostnamectl set-hostname k8s-master
echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts
\`\`\`

(Close the current SSH session and open a new one. The changes should take effect)

---

## Update Packages

\`\`\`bash
sudo apt-get update
\`\`\`

---

## Install AWS CLI

\`\`\`bash
sudo apt install awscli -y
\`\`\`

---

## Install python3-pip

\`\`\`bash
sudo apt install python3-pip
\`\`\`

\`\`\`bash
pip install --upgrade awscli
\`\`\`

---

## Configure AWS CLI

Run the “aws configure” command (Here you'll be prompted to enter details such as):

- AWS Access Key ID: Your AWS Access Key.
- AWS Secret Access Key: Your AWS Secret Access Key.
- Default region name: The region where you want to create the EKS cluster.
- Default output format: You can leave this as ‘None’

---

## Install EKSCTL

\`\`\`bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
\`\`\`

**Verify the installation**

\`\`\`bash
eksctl version
\`\`\`

---

## Install Kubectl

\`\`\`bash
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
\`\`\`

---

## Create an EKS Cluster

\`\`\`bash
eksctl create cluster \\
--name “cluster-name” \\
--region “your-region” \\
--nodes 1 \\
--nodegroup-name “group-name” \\
--node-type “instance-type” (e.g. t2/t3.medium) \\
--managed (simplifies node management.)
\`\`\`

![Cluster Creation](Images/Cluster_Creation.png)

The output should be EKS cluster "cluster-name" in "region name" region is ready.

---

## Confirm the cluster creation

\`\`\`bash
eksctl get cluster --name ‘cluster-name --region “your region”
\`\`\`

![Checking Cluster](Images/Checking_Cluster.png)

---

## Verify that kubectl is properly communicating with your new cluster

\`\`\`bash
kubectl version
\`\`\`

![Checking kubectl](Images/Checking_kubectl.png)

---

## Create ‘devops’ namespace

\`\`\`bash
kubectl create namespace devops
\`\`\`

---

## Allocating An Elastic IP

Navigate to EC2 -> Elastic IP’s->Allocate Elastic IP Address -> Allocate ->  
Choose the New IP, Actions, Associate elastic ip address ->Choose “Network Interface”, The Instance Network Interface, His Private IP-> Associate

![Elastic ip(1)](Images/Elastic_ip(1).png)
![Elastic ip(2)](Images/Elastic_ip(2).png)
![Elastic ip(3)](Images/Elastic_ip(3).png)
![Elastic ip(4)](Images/Elastic_ip(4).png)

---

## Create a Jenkins Dockerfile With necessary installations

![Jenkins Dockerfile](Images/Jenkins_Dockerfile.png)

---

## Build the Image

Navigate to the directory where the Dockerfile is located, then build the Docker image:

\`\`\`bash
docker build -t <jenkins-image> .
docker tag  <jenkins-image> <username>/<repo-name:<tag>
docker push <username>/<repo-name:<tag>
\`\`\`

![Jenkins Dockerfile Build](Images/Jenkins_Dockerfile_Build.png)

---

## Create a Jenkins persistent volume  YAML File

Change values : to your “node name”

![persistent volume YAML File](Images/persistent_volume_YAML_File.png)

\`\`\`bash
kubectl apply -f persistent-volume.yaml
\`\`\`

---

## Create a Jenkins persistent volume claim  YAML File

![Jenkins persistent volume claim YAML File](Images/Jenkins_persistent_volume_claim_YAML_File.png)

\`\`\`bash
kubectl apply -f persistent-volume-claim.yaml
\`\`\`

---

## Create a Jenkins persistent local-storage YAML File

![persistent local-storage YAML File](Images/persistent_local-storage_YAML_File.png)

\`\`\`bash
kubectl apply -f local-storage.yaml
\`\`\`

---

## Expose the Jenkins Service

A NodePort service will open a specific port on all the cluster nodes, allowing external  
  traffic to reach the service. (we specified 30000)

![Expose the Jenkins Service](Images/Expose_the_Jenkins_Service.png)

---

## Apply the Service

\`\`\`bash
kubectl apply -f jenkins-service.yaml
\`\`\`

The output should be : “service/jenkins created”

---

## Create a Jenkins Deployment YAML File

![Jenkins Deployment YAML File](Images/Jenkins_Deployment_YAML_File.png)

---

## Apply the Deployment

\`\`\`bash
kubectl apply -f jenkins-deployment.yaml
\`\`\`

The output should be : “deployment.apps/jenkins created”

---

## Verify The Exist Of the mountPath

![Verify The Exist Of the mountPath](Images/Verify_The_Exist_Of_the_mountPath.png)

---

\`\`\`bash
sh-4.2$ /bin/bash
[ssm-user@ip-192-168-39-114 bin]$ sudo mkdir -p /var/jenkins-data
sudo chmod -R 777 /var/jenkins-data
\`\`\`
