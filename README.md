Create a Kubernetes Cluster And Deploy Jenkins, Using Elastic Kubernetes Service(EKS) :

EC2 Control Node Instance Type:
t3.small
AMI: Ubuntu.

Security Group Settings:    

Ports to Open:

22 for SSH

80 for HTTP

443 for HTTPS

![ec2 instance(configure)](Images/ec2_instance(configure).png)
![ec2 instance(secGroup)](Images/ec2_instance(secGroup).png)

SSH into EC2 Instance
ssh -i "your-key.pem" ubuntu@<EC2_PUBLIC_IP>

Change Host Name(Optional for comfort)
sudo hostnamectl set-hostname k8s-master
echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts
(close the current SSH session and open a new one. 
The changes should take effect)

Update Packages
sudo apt-get update

Install AWS CLI
sudo apt install awscli -y

Install python3-pip
sudo apt install python3-pip
pip install --upgrade awscli

Configure AWS CLI
Run the “aws configure” command(Here you'll be prompted to enter details such as):
AWS Access Key ID: Your AWS Access Key.
AWS Secret Access Key: Your AWS Secret Access Key.
Default region name: The region where you want to create the EKS cluster. 
Default output format: You can leave this as ‘None’

Install EKSCTL
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

*verify the installation
eksctl version

Install Kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

Create an EKS Cluster
eksctl create cluster \
--name “cluster-name” \
--region “your-region” \
--nodes 1 \
--nodegroup-name “group-name” \
--node-type “instance-type” (e..g t2/t3.medium) \
--managed(simplifies node management.)
![Cluster Creation](Images/Cluster_Creation.png)
the output should be EKS cluster "cluster-name" in "region name" region is ready.

Confirm the cluster creation
eksctl get cluster --name ‘cluster-name --region “your region”
![Checking Cluster](Images/Checking_Cluster.png)

Verify that kubectl is properly communicating with your new cluster
kubectl version 
![Checking kubectl](Images/Checking_kubectl.png)

Create ‘devops’ namespace
kubectl create namespace devops

Allocating An Elastic IP 
Navigate to EC2 -> Elastic IP’s->Allocate Elastic IP Address -> Allocate ->
Choose the New IP, Actions, Associate elastic ip address ->Choose “Network Interface”, The Instance Network Interface, His Private IP-> Associate
![Elastic ip(1)](Images/Elastic_ip(1).png)
![Elastic ip(2)](Images/Elastic_ip(2).png)
![Elastic ip(3)](Images/Elastic_ip(3).png)
![Elastic ip(4)](Images/Elastic_ip(4).png)

Create a Jenkins Dockerfile With necessary installations
![Jenkins Dockerfile](Images/Jenkins_Dockerfile.png)

Build the Image: Navigate to the directory where the Dockerfile is located, then build the Docker image:
docker build -t <jenkins-image> .
docker tag  <jenkins-image> <username>/<repo-name:<tag>
docker push <username>/<repo-name:<tag>
![Jenkins Dockerfile Build](Images/Jenkins_Dockerfile_Build.png)

Create a Jenkins persistent volume  YAML File
change values : to your “node name”
![persistent volume YAML File](Images/persistent_volume_YAML_File.png)

kubectl apply -f persistent-volume.yaml

Create a Jenkins persistent volume claim  YAML File

![Jenkins persistent volume claim YAML File](Images/Jenkins_persistent_volume_claim_YAML_File.png)

kubectl apply -f persistent-volume-claim.yaml

Create a Jenkins persistent local-storage YAML File

![persistent local-storage YAML File](Images/persistent_local-storage_YAML_File.png)

kubectl apply -f local-storage.yaml							

Expose the Jenkins Service

A NodePort service will open a specific port on all the cluster nodes, allowing external
  traffic to reach the service. (we specified 30000)


![Expose the Jenkins Service](Images/Expose_the_Jenkins_Service.png)

Apply the Service
kubectl apply -f jenkins-service.yaml
  the output should be : “service/jenkins created”

Create a Jenkins Deployment YAML File


![Jenkins Deployment YAML File](Images/Jenkins_Deployment_YAML_File.png)

Apply the Deployment
kubectl apply -f jenkins-deployment.yaml
 the output should be : “deployment.apps/jenkins created”

Verify The Exist Of the mountPath 
![Verify The Exist Of the mountPath](Images/Verify_The_Exist_Of_the_mountPath.png)


sh-4.2$ /bin/bash
[ssm-user@ip-192-168-39-114 bin]$ sudo mkdir -p /var/jenkins-data
sudo chmod -R 777 /var/jenkins-data

Allow Traffic on Port 30000
Navigate to: EC2 -> Instances -> Click on Instance ID (worker node) ->   Security ->  Security groups -> Inbound rules -> -> Edit inbound rules ->
Add rule (custom TCP, Port Range - 30000, CIDR - 0.0.0.0/0) -> Save rules
![Allow Traffic on Port 30000(1)](Images/Allow Traffic_on_Port_30000(1).png)
![Allow Traffic on Port 30000(2)](Images/Allow Traffic_on_Port_30000(2).png)

Access the Jenkins Website (nodeIP:NodePort)
to find the nodeIP use : kubectl get nodes -o wide
copy the EXTERNAL-IP


![Access the Jenkins Website (nodeIP:NodePort)](Images/Access_the_Jenkins_Website_(nodeIP:NodePort).png)


now reach the jenkins website through : EXTERNAL-IP:30000

Retrieve Jenkins Unlock Key
kubectl exec -it $(kubectl get pod -n devops -l app=jenkins -o jsonpath="{.items[0].metadata.name}") -n devops -- cat /var/jenkins_home/secrets/initialAdminPassword


![Retrieve Jenkins Unlock Key](Images/Retrieve_Jenkins_Unlock_Key.png)


copy the output and press ‘continue’ 

Install plugins
you can always install additional plugins later.


![Install plugins(1)](Images/Install_plugins(1).png)


![Install plugins(2)](Images/Install_plugins(2).png)

Create Admin user
fill the fields :

![Create Admin user](Images/Create_Admin_user.png)


enter the public ip here http://”public-ip”:30000/


![enter the public ip here](Images/enter_the_public_ip_here.png)


![Jenkins Ready](Images/Jenkins_Ready.png)


Configure jenkins to work with GitHub :
Create GitHub Account
go to : https://github.com
Click on “Sign Up”


![Create GitHub Account](Images/Create_GitHub_Account.png)

Fill the Fields: 


![fill the fields](Images/fill_the_fields.png)

Copy The Password that sent to your email


![Copy The Password that sent to your email](Images/Copy_The_Password_that_sent_to_your_email.png)

Create Personal Access Token (PAT) on GitHub:
Click on profile picture at top-right and choose “Settings”.


![Create Personal Access Token (PAT) on GitHub:(1)](Images/Create_Personal_Access_Token_(PAT)_on_GitHub:(1).png)

Scroll Down And choose “Developer Settings”


![Create Personal Access Token (PAT) on GitHub:(2)](Images/Create_Personal_Access_Token_(PAT)_on_GitHub:(2).png)

Click on "Personal access tokens" from the left sidebar, then click on "Generate new token.


![Create Personal Access Token (PAT) on GitHub:(3)](Images/Create_Personal_Access_Token_(PAT)_on_GitHub:(3).png)

Name the token and give it the necessary scopes (permissions)


![Create Personal Access Token (PAT) on GitHub:(4)](Images/Create_Personal_Access_Token_(PAT)_on_GitHub:(4).png)

Click "Generate token" at the bottom

Copy the generated token somewhere safe; you won't be able to see it again.
(its cut for safety reasons)


![Create Personal Access Token (PAT) on GitHub:(5)](Images/Create_Personal_Access_Token_(PAT)_on_GitHub:(5).png)

Add GitHub Configuration In Jenkins :
Open Jenkins in your browser, then navigate to "Manage Jenkins" -> " System."


![Add GitHub Configuration In Jenkins :(1)](Images/Add_GitHub_Configuration_In_Jenkins_:(1).png)

Scroll down until you find the GitHub section
Click on "Add GitHub Server" and fill in the details.
Name: Can be any name to identify this GitHub configuration.
API URL: Usually this is https://api.github.com for GitHub.com


![Add GitHub Configuration In Jenkins :(2)](Images/Add_GitHub_Configuration_In_Jenkins_:(2).png)


For "Credentials," click the "Add" button next to the dropdown.
Kind: Choose "Secret text."
Secret: Paste your GitHub Personal Access Token here.
ID: Can be any name to identify this secret.
Description: Optional, but helps you remember what this secret is for.


![Add GitHub Configuration In Jenkins :(3)](Images/Add_GitHub_Configuration_In_Jenkins_:(3).png)

choose the new created credentials and press “Test connection”


![Add GitHub Configuration In Jenkins :(4)](Images/Add_GitHub_Configuration_In_Jenkins_:(4).png)


the output should be something like “Credentials verified for user orioElias, rate limit:4999”
press “Save”

Create a GitHub Repository 
log in GitHub, you'll see a "+" icon in the upper-right corner next to your profile picture. Click on it and select "New repository."


![Create a GitHub Repository (1)](Images/Create_a_GitHub_Repository_(1).png)

Fill your repository details, then Click “Create repository”


![Create a GitHub Repository (2)](Images/Create_a_GitHub_Repository_(2).png)


Connect the New GitHub Repository To Jenkins:
Open your Jenkins interface, Click on "New Item" on the Jenkins dashboard, select "Pipeline," and then proceed.


![Connect the New GitHub Repository To Jenkins:(1)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(1).png)


In the pipeline configuration, Check "GitHub hook trigger for GITScm polling". Additionally you'll need to specify the source as your GitHub repository.
Source: Git
Repository URL: The URL of the GitHub repository you just created
Credentials: Create a new set of credentials in Jenkins using the same GitHub Personal Access Token (PAT) you generated earlier.


![Connect the New GitHub Repository To Jenkins:(2)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(2).png)


In the "Credentials" dropdown, click on the "Add" button and Jenkins.
For the “Kind” field, choose “Username with password.”
Enter your GitHub username in the “Username” field.
Paste your GitHub Personal Access Token in the “Password” field.
Add an ID and Description to identify these credentials.


![Connect the New GitHub Repository To Jenkins:(3)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(3).png)


Now, choose the New Credentials, Change “Branch Specifier (blank for 'any')”
From: “*/master” To  “*/main” And Click “SAVE”


![Connect the New GitHub Repository To Jenkins:(4)](Images/Connect_the_New_GitHub_Repository_To_Jenkins:(4).png)


Add GitHub Webhook to Trigger Jenkins Pipeline
GitHub Repository Settings: Navigate to "Settings" on your GitHub repository.


![Add GitHub Webhook to Trigger Jenkins Pipeline(1)](Images/Add_GitHub_Webhook_to_Trigger_Jenkins_Pipeline(1).png)


Webhooks: Go to the "Webhooks" tab and click on "Add webhook."


![Add GitHub Webhook to Trigger Jenkins Pipeline(2)](Images/Add_GitHub_Webhook_to_Trigger_Jenkins_Pipeline(2).png)


Use your Jenkins URL followed by /github-webhook/. For example, http://’your-public-ip:30000/github-webhook/
Content type: Choose application/json
Secret: Leave this blank if you haven’t set up a secret in Jenkins for webhook validation.
Choose "Just the push event" if you want the pipeline to run only when new commits are pushed.
Active: Make sure this checkbox is checked.
Click: “Add webhook”


![Add GitHub Webhook to Trigger Jenkins Pipeline(3)](Images/Add_GitHub_Webhook_to_Trigger_Jenkins_Pipeline(3).png)


Allow Traffic on Port 80 (For the Webhook, Same as we did Before)
Here's how to add a rule for port 80 in your AWS Security Group:
Navigate to: EC2 -> Instances -> Click on Instance ID (worker node) ->   Security ->  Security groups -> Inbound rules -> -> Edit inbound rules -> Add rule (HTTP, CIDR - 0.0.0.0/0) -> Save rules


![Allow Traffic on Port 80 (For the Webhook, Same as we did Before)](Images/Allow_Traffic_on_Port_80_(For_the_Webhook,_Same_as_we_did_Before).png)


Clone the repository to your local machine && Checking the Webhook: 

run in the terminal (in the directory that you want to clone your repo)
git clone https://github.com/<your-username>/<directory-name>.git
this will create a new directory that contains your GitHub repository.


![Clone the repository to your local machine && Checking the Webhook](Images/Clone_the_repository_to_your_local_machine&&Checking_the_Webhook.png)



cd <directory-name>
Make some changes to the existing files or add new files to the directory.
git add <filename>
git commit -m "Your commit message here"
git config --global credential.helper 'cache --timeout=3600' (optional) 

git push origin main
username: <your-username>
password: <Personal Access Token>
After you push the commit, your GitHub webhook should trigger your Jenkins pipeline if it's configured correctly.

Download an ASP.NET Core web application.
Download from Official Samples: Microsoft offers various sample projects that you can download directly. You can find these on the official ASP.NET Core samples page.

Creating Docker Hub credentials

Create a Docker Access Token:
Log in to Docker Hub.
Go to your account settings.
Navigate to the "Security" section.
Click on "New Access Token", provide a name for the token, and choose the level of access you want to grant.
Copy the generated token and keep it safe; you won't be able to see it again.

Configure Docker Credentials in Jenkins:
Go to Jenkins and navigate to "Manage Jenkins" -> "Manage Credentials".
Under "(global)" domain, click "Add Credentials".
Select "Username with password" from the "Kind" dropdown menu.
In the "Username" field, enter your Docker Hub username.
In the "Password" field, paste the Docker access token you generated.
Provide a unique ID (e.g., 'docker-hub-token') and a description for the credentials.


![Creating Docker Hub credentials](Images/Creating_Docker_Hub_credentials.png)

Docker-outside-of-Docker (DooD)
Launch a new t2.micro EC2 instance with Ubuntu AMI
SSH into Docker-Host
sudo apt-get update && sudo apt-get upgrade -y

Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

Configure Docker Daemon
sudo nano /etc/docker/daemon.json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}
save.

Edit the Docker Service File:
sudo nano /lib/systemd/system/docker.service
Find the line that begins with ExecStart= and remove the part -H fd://
Save.
sudo systemctl daemon-reload
sudo systemctl restart docker

you can check the status by running :
sudo systemctl status docker

Open port 2375 for Inbound rule


![Open port 2375 for Inbound rule](Images/Open_port_2375_for_Inbound_rule.png)


Update Jenkins Deployment Configuration:
Update the containers  section to include the DOCKER_HOST environment variable with the IP address of your Docker-Host EC2 instance and port 2375:


![Update Jenkins Deployment Configuration:](Images/Update_Jenkins_Deployment_Configuration:.png)


Apply Updated Jenkins Configuration:
kubectl apply -f jenkins-deployment.yaml

Create a Jenkinsfile 

![Create a Jenkinsfile (1)](Images/Create_a_Jenkinsfile_(1).png)


![Create a Jenkinsfile (2)](Images/Create_a_Jenkinsfile_(2).png)


Create Dockerfile


![Create Dockerfile](Images/Create_Dockerfile.png)


Create deployment-web-app.yaml
![Create deployment-web-app.yaml](Images/Create deployment-web-app.yaml.png)

Create a service To Access this WEB APP


![Create a service To Access this WEB APP](Images/Create_a_service_To_Access_this_WEB_APP.png)


Open port 30080 also in the security group

Create Cluster Role Files
jenkins-cluster-role-binding.yaml


![jenkins-cluster-role-binding](Images/jenkins-cluster-role-binding.png)


kubectl apply -f jenkins-cluster-role-binding.yaml

jenkins-cluster-role.yaml


![jenkins-cluster-role.yaml](Images/jenkins-cluster-role.yaml.png)


kubectl apply -f jenkins-cluster-role.yaml

Now you can push the new Files to the repository and See the pipeline runs :


![See the pipeline runs](Images/See_the_pipeline_runs.png)
