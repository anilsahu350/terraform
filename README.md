
## Step - 1 : Create EKS Management Host in AWS ##

1) Launch new Ubuntu VM using AWS Ec2 ( t2.micro )	  
2) Connect to machine and install kubectl using below commands  
```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
```
3) Install AWS CLI latest version using below commands 
```
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

4) Install eksctl using below commands
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```
## Step - 2 : Update kubeconfig for the EKS Cluster
```
aws eks --region ap-south-1 update-kubeconfig --name anil-cluster
```
## Step - 3 : Associate IAM OIDC Provider
```
eksctl utils associate-iam-oidc-provider --region ap-south-1 --cluster anil-cluster --approve
```
## Step - 4 : Create IAM Role for Service Account
```
eksctl create iamserviceaccount \
  --region ap-south-1 \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster anil-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --override-existing-serviceaccounts
```
## Step - 5 : Install EBS CSI Driver
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.11"
```
## Step - 6 : Verify EBS CSI Driver Installation
```
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```
## step-7:	Verify that the service account is created:
```
kubectl get serviceaccount ebs-csi-controller-sa -n kube-system
```
## Step - 8 :Verify that the kubeconfig is updated and the cluster is accessible:
``` 
kubectl get nodes
```

## if u have terraform installed, you can use the below command to delete the cluster
``` 
terraform destroy -auto-approve 
```