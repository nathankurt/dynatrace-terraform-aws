# Terraform DT Managed Lab


## Installing Terraform

* In your linux VM or Linux Subsystem for Windows(My preferred route), go ahead and run `wget https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip` or `brew install terraform` if you have linuxbrew set up in your vm. 
* If you went the wget route, make sure to unzip the file and move the terraform file to `/bin` to add it to your path



## Registering Your AWS Account

* If you haven't already, make an AWS account, go into EBS -> key pairs and create a key pair. Download it to your machine as a .pem file and save it. 
  * You have to give your keys not very much permissions so go ahead and `chmod 400` the pem file
* Go into IAM and create a user, give it admin rights. 
  * then create access keys -> security credentials 
  * Make sure your region is set to N. Virginia (us-east-1)

## Create a License 

So the nice thing about terraform is that if you mess up, you can just run a `terraform destroy` to destroy all your instances, then run a `terraform apply` to recreate everything again. The downside to this is that with the trial environment is that you're gonna have to make a new license for now. 

Create your Dynatrace Managed License [Here](https://mc-dev.internal.dynatracelabs.com/index.jsp#accounts)
You may have to make an account first before you can create a license though. 




## Editing the Files
* Go into your Terraform folder and run `terraform init` to get everything ready to go with what you have. 
* The next step is to go and change your [vars.tf file](terraform/vars.tf)
  * Change the variables you need with the values that you've been given
  * If you use the default values for things, just make sure to keep those files out of verison control because then someone could access your entire AWS environment and run lots and lots of paid instances on your dollar. 
* Run `terraform init`
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

**PUT IN SCREENSHOT HERE**

### Access the Dynatrace Environment from the URL they give you(instead of the AWS URL)
F
Get this set up by clicking Node 1 in the DT Managed Home and changing the Web UI IP Address to whatever the Dynatrace Managed Public IP is.



### Install Cluster Active Gate
* Install the cluster active gate on the cluster active gate VM and show it in your hosts menu

### Install Environment Active Gate 
* Install the enviro
* nment active gate on the Test-EC2 VM Then show your active gate in your 

### Install The OneAgent
* Install The OneAgent on each of the three VMs and show them working in the hosts tab





## Enable AWS Deep Monitoring Using Role Based Authentication (NOT YOUR ACCESS KEY) 

When you set this up, make sure you use Role Based Authentication, not Key based authentication since that's best practice. If you follow the documentation for it, it should work like a charm. 

Also make sure to set it up with dynatrace tags so it doesn't grab every single thing you've ever done from AWS and charge you money. 


[Full AWS Monitoring Documentation](https://www.dynatrace.com/support/help/technology-support/cloud-platforms/amazon-web-services/installation/aws-monitoring-with-dynatrace-managed/)

After you finish, you should be able to access the AWS tab on the left and have all the ec2 instances show up as being deeply monitored. 

![aws-deep-monitoring](/images/aws-deep-monitoring.png)

**KERCHOW** Now you're done