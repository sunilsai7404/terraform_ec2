provider "aws"{
    region = "us-east-2"
}

resource "aws_key_pair" "deployer"{
    key_name = "demo-key"
    public_key = file("~/.ssh/demo-key.pub")
}

resource "aws_security_group" "allow_ssh_http" {
    name_prefix="allow_ssh_http"   
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks=["0.0.0.0/0"]

    }
    ingress {
        from_port = 5000
        to_port = 5000
        protocol="tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
        from_port =0
        to_port =0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]

    }
}
resource "aws_instance" "app_server"{ 
    # "aws_instance" creates and EC2 virtual machine
    # "demo_ec2" is terraform's local name for this resource
    ami = "ami-019a63e66799737f9" # ubuntu 22.04 in eu-west-2, ami(amazon machine image)
    instance_type ="t3.micro" # chooses the size of the VM
    vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
    key_name = var.key_name # attaches the SSH key so you can connect securely
    
    user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 git
    cd/home/ec2-user
    git clone https://github.com/sunilsai7404/terraform_ec2.git
    cd team-infra/app
    python3 app.py &
    EOF

    tags={ # adda a label in AWS Console, so you can easily recognize the instance
        Name = "Terraform-demo-ec2" 
    }
}

output "ec2_public_ip" {
    value = aws_instance.app_server.public_ip
}

variable "key_name" {
    description = "The name of the SSH key pair"
    default     = "demo-key"
}
