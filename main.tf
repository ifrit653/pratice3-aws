terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    profile = "default"
    region  = "eu-north-1"
}
resource "aws_security_group" "minimal-conf" {
    name        = "allow-ssh"
    ingress {
        description = "SSH from everywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "asn-terra-practice"
    }
}

resource "aws_instance" "servers" {
    count               = 1
    ami                 = "ami-00680fd4e58e51542"
    instance_type       = "t3.micro"
    key_name            = "dell_figo_win"

    security_groups = [aws_security_group.minimal-conf.name]

    tags = {
        Name = "Server${count.index}"
    }
}
data "template_file" "hosts" {
    template = file("./hosts.tpl")
    vars = {
        instance_name = join(" ansible_user=ec2-user ansible_ssh_private_key_file=/home/figo/.ssh/dell_figo_win.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n", concat(aws_instance.servers.*.public_ip, [""]))
    }
}

resource "local_file" "hosts_file" {
    content  = data.template_file.hosts.rendered
    filename = "./ansible/hosts"
}
