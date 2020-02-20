# Nate Kurt

# for further details about aws_instance available arguments 
# check out https://www.terraform.io/docs/providers/aws/r/instance.html
# for further details about Dynatrace Managed installation params 
# check out https://help.dynatrace.com/dynatrace-managed/dynatrace-server/can-i-install-dynatrace-server-using-custom-parameters/

#the following block creates a security group allowing SSH and HTTPS inbound traffic to access the node (ssh) and the UI.
#in the sample below the ingress blocks are allowed for ANY IP address. This is not the best practice when it comes to SSH, you
#should only specify the IP address of your machine or the one of your jumpbox.
resource "aws_security_group" "terraformsg" {
  name        = "terraformsg"
  description = "Allow SSH and HTTPS inbound traffic for Dynatrace Managed"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
	  from_port = 9999
	  to_port = 9999
	  protocol = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}




resource "aws_instance" "dynatracemanagednode" {
	
	#specify the security group we've just created in the previous block, passing the id of the newly created terraformsg
	vpc_security_group_ids = ["${aws_security_group.terraformsg.id}"]
	
	#enter the key pair name of the key pair you've previously created on AWS - the value is defined in the vars file 
	key_name = var.AWS_KEYPAIR_NAME

	#ami ID and instance type are defined in the vars file 
  	ami = lookup(var.AMIS, var.AWS_REGION)
  	instance_type = lookup(var.AWS_INSTANCE_TYPE, var.DYNATRACE_SIZING)
	
	#EC2 instance root volume size
	root_block_device {
        volume_size = var.ROOT_VOLUME_SIZE
   	}

	#specify a tag (optional) for the EC2 instance
	tags = {
		  Name = "Dynatrace Managed Server"
    	  DynatraceManagedNode = "SpunUpin5Minutes"
		  dynatrace-monitored = "true"
  	}

	
	#remote-exec block
	#these are the automation commands executed after the creation of the EC2 instance directly on the host
	#it basically downloads the Dynatrace Managed version from the Download URL defined in vars file
	#it executes the installation script using the --install-silent mode, passing the license key and the initial setup params defined
	#in the vars file 
	
	provisioner "remote-exec" {
    		inline = [
      			"sudo wget -O /tmp/dynatrace-managed.sh ${var.DYNATRACE_DOWNLOAD_URL}",
      			"cd /tmp/",
				"sudo /bin/sh dynatrace-managed.sh --install-silent --license ${var.DYNATRACE_LICENSE_KEY} --initial-environment ${var.DYNATRACE_INIT_ENV} --initial-first-name ${var.DYNATRACE_INIT_NAME} --initial-last-name ${var.DYNATRACE_INIT_LASTNAME} --initial-email ${var.DYNATRACE_INIT_EMAIL} --initial-pass ${var.DYNATRACE_INIT_PWD} --check-level 000000"
			]
	#the connection block defines the connection params to ssh into the newly created EC2 instance 
			connection {
				type = "ssh"
				user = "ubuntu"
				host = element(aws_instance.dynatracemanagednode.*.public_ip, 0)
				private_key = file(var.AWS_PRIVATE_KEY)
				timeout = "15m"
				agent = false
			}
  	}
}

# resource "aws_ebs_volume" "storage" {
# 	availability_zone = "us-east-1"v
# 	size = 60
# }

# resource "aws_volume_attachment" "ebs_att" {
# 	device_name = "/dev/sdh"
# 	volume_id = aws_ebs_volume.storage.id
# 	instance_id = aws_instance.dynatracemanagednode.id
# }

#The vm spun up to put the oneagent on. 


resource "aws_security_group" "outside_dtmanaged" {
  name        = "outside_dtmanaged"
  description = "Allow SSH and HTTPS inbound traffic for Dynatrace Managed"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
	  from_port = 9999
	  to_port = 9999
	  protocol = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#The AWS VM spun up to install the cluster active gate on. 
resource "aws_instance" "cluster-vm" {

	vpc_security_group_ids = ["${aws_security_group.terraformsg.id}"]

	key_name = var.AWS_KEYPAIR_NAME

	ami = lookup(var.AMIS, "us-east-1-16")
	instance_type = lookup(var.AWS_INSTANCE_TYPE, var.EC2_SIZING)

	root_block_device {
		volume_size = var.ROOT_VOLUME_SIZE
	}

	tags = {
		Name = "Cluster Active Gate EC2"
		dynatrace-monitored = "true"
	}



}




#The AWS 
resource "aws_instance" "test-vm" {

	vpc_security_group_ids = ["${aws_security_group.outside_dtmanaged.id}"]

	key_name = var.AWS_KEYPAIR_NAME

	ami = lookup(var.AMIS, var.AWS_REGION)
	instance_type = lookup(var.AWS_INSTANCE_TYPE, var.EC2_SIZING)

	root_block_device {
		volume_size = var.ROOT_VOLUME_SIZE
	}

	tags = {
		Name = "Test-EC2 VM"
		dynatrace-monitored = "true"
	}

}



#a little trick to show the complete url with the public_dns of the created node. Simply copy and paste it in your browser and you're done.
output "connect_to_dynatrace" {
  value = "https://${aws_instance.dynatracemanagednode.public_dns}"
}

output "connect_to_managed_vm_command" {
	value = "ssh -i ${var.AWS_PRIVATE_KEY} ubuntu@${element(aws_instance.dynatracemanagednode.*.public_ip, 0)}"
}

output "connect_to_test_vm_command" {
	value = "ssh -i ${var.AWS_PRIVATE_KEY} ubuntu@${element(aws_instance.test-vm.*.public_ip, 0)}"
}

output "connect_to_cluster_vm_command" {
	value = "ssh -i ${var.AWS_PRIVATE_KEY} ubuntu@${element(aws_instance.cluster-vm.*.public_ip, 0)}"
}


