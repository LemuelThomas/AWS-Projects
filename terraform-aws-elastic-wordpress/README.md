# Automating Elastic Wordpress Project Using Terraform
This is my work for automating the creation of launch template, parameter store parameters, and auto scaling group

## Getting Started
### Install AWS CLI:
Make sure you have the AWS CLI installed on your machine. You can download and install it from the official AWS CLI download page.

### Open a Terminal or Command Prompt:
Open your terminal or command prompt application on your computer.

### Run the aws configure Command:
In the terminal or command prompt, type the following command and press Enter:
```
aws configure
```
This command will prompt you to enter your AWS Access Key ID, Secret Access Key, default region name, and default output format.

### Enter Your AWS Access Key ID:
Enter your AWS Access Key ID when prompted. This key is associated with your AWS account and is used to authenticate your requests.

### Enter Your Secret Access Key:
Enter your AWS Secret Access Key when prompted. This key is used along with the Access Key ID for authentication.

### Enter Default Region Name:
Enter the default region name for your AWS resources. This is the AWS region code (e.g., us-east-1, eu-west-1). You can find a list of AWS regions here.

### Enter Default Output Format:
Choose a default output format for the AWS CLI. The default is usually json.

### Clone Github Repo using HTTPS:
Clone the repo using this command in your terminal
```
git clone https://github.com/LemuelThomas/AWS-Projects.git
```

### Terraform Commands
1. Run `terraform init` in your terminal to install the necessary dependencies
2. Run `terraform plan` to see what resources is being created
3. Run `terraform apply` to create the resources that was described in the terraform plan
