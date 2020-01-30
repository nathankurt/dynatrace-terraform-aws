# Terraform DT Managed Lab

## Purpose

In this lab, The goal is to use [Terraform](https://www.terraform.io/) to spin up an instance of Dynatrace Managed and deploy both a cluster and environment active gates on other EC2 Instances. This will help get you familiar with both the concept of [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code) as well as basic AWS usage, security practices, and working in a sealed environment. 

### Pre Requisites
* Side Note: I highly recommend installing WSL since it will allow you to use things like the [terminal from VS Code when you press `Ctrl + ~`](https://dev.to/micahshute/setting-up-windows-subsytem-for-linux-3b7n)
  * I have my WSL Set up using [hyper and zsh](https://medium.com/@ssharizal/hyper-js-oh-my-zsh-as-ubuntu-on-windows-wsl-terminal-8bf577cdbd97) with the [powerlevel10k theme](https://github.com/romkatv/powerlevel10k)(it's crazy fast, would use) Also I use [this neovim setup](https://github.com/Optixal/neovim-init.vim) and I like it a lot. 


## Installing Terraform

* In your linux VM or Windows Subsystem For Linux (My preferred route), go ahead and run `wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip` or `brew install terraform` if you have linuxbrew set up in your vm. 
* If you went the wget route, make sure to unzip the file and move the terraform file to `/bin` to add it to your path
  



## Registering Your AWS Account

* If you haven't already, Create an AWS Account
* Make sure your region is set to N. Virginia (us-east-1)
* Go into IAM and create a group, name it `admin` and then attach the policy `AdministratorAccess` to it.
  * Then create a user
    * Select programmatic Access absolutely and also AWS management console access (if you want) 
    * Add it to the admin group you just made. 
  * Click on the user you just made and go to the security credentials tab. 
    * Click on create access keys and note those down since you won't be able to see the private key again. 
* go into EBS -> key pairs and create a key pair. Download it to your machine as a .pem file and save it. 
  * You have to give your keys not very much permissions so go ahead and `chmod 400` the pem file

## Create a License 

So the nice thing about terraform is that if you mess up, you can just run a `terraform destroy` to destroy all your instances, then run a `terraform apply` to recreate everything again. The downside to this is that with the trial environment is that you're gonna have to make a new license each time you destroy an environment. 

Create your Dynatrace Managed License [Here](https://mc-dev.internal.dynatracelabs.com/index.jsp#accounts)
You may have to make an account first in that tab before you can create a license though. 




## Editing the Files
* Go into your Terraform folder and run `terraform init` inside of your terraform folder to get everything ready to go with what you have. 
* The next step is to go and change your [vars.tf file](terraform/vars.tf)
  * Change the variables you need with the values that you've been given
  * If you use the default values for things, just make sure to keep those files out of verison control because then someone could access your entire AWS environment and run lots and lots of paid instances on your dollar. 
* Then `terraform plan`
* Make sure you have no errors
* `terraform apply`
* look at the bottom of the files and make sure that you can access that URL and ssh into those EC2 Instances.


**NOTE**
* When you set this up, make sure you have the `dynatrace-monitored = "true"` tag set up for each VM. this will come into play for setting up AWS deep monitoring later down the line. 


## Configuring the Dynatrace Environment
Now the goal is to use that terraform environment that's been spun up for you and configure it. you can initially access it via the link that's outputted in the terminal at the end of the successful creation. You can log in with the username as `admin` and the password as whatever you set in the initial password form.

**BIG BIG BIG NOTE:**
* As of when this lab was created (1/29/2020), The dynatrace managed trial environment doesn't like to play nice and the agent version it gives you to set up is straight up bad. It's about 8 versions behind the server version that installs so you can't actually install the oneagent anywhere. The way around this I've found is to go into mission control, clusters -> cluster details. look for your license and cluster. Then set the release group from `early-access` to `stable` Then wait until the link you get for your oneagent/activegate install changes from `1.79 -> 1.85` or whatever the newest stable version is. **IF YOU SKIP THIS STEP, STUFF WILL BREAK**  

![Agent License Version](/images/stable-mode-or-bust.png) If your version isn't set to stable or doesn't have a close version to your server, you're gonna have a bad time. 


### Access the Dynatrace Environment from the URL they give you(instead of the AWS URL)

Get this set up by clicking Node 1 in the DT Managed Home and changing the Web UI IP Address to whatever the Dynatrace Managed VM Public IP is.



### Install Cluster Active Gate
* Install the cluster active gate on the cluster active gate VM and show it in your hosts menu
  * Note: When you are downloading these files, the wget won't work unless you add a `--no-check-certificate` flag to the end just because the Cert that the trial license gives you isn't verified

### Install Environment Active Gate 
* Install the enviro
* nment active gate on the Test-EC2 VM Then show your active gate in your 

### Install The OneAgent
* Install The OneAgent on each of the three VMs and show them working in the hosts tab





## Enable AWS Deep Monitoring Using Role Based Authentication (NOT YOUR ACCESS KEY) 

When you set this up, make sure you use Role Based Authentication, not Key based authentication since that's best practice. If you follow the documentation for it, it should work like a charm. 

Also make sure to set it up with the dynatrace tags option enabled and set to `dynatrace-monitored` (for the key) and `true` (as the value) so it doesn't grab every single thing you've ever done from AWS and charge you money. 


[Full AWS Monitoring Documentation](https://www.dynatrace.com/support/help/technology-support/cloud-platforms/amazon-web-services/installation/aws-monitoring-with-dynatrace-managed/)

After you finish, you should be able to access the AWS tab on the left and have all the ec2 instances show up as being deeply monitored. 

![aws-deep-monitoring](/images/aws-deep-monitoring.png)

**KERCHOW** Now you're done