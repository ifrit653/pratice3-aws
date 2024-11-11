## Description

what this code do:

1. launch an instance EC2 on AWS via terraform
2. install git and nginx on the ec2 instance freshly created via ansible
3. and the a script file to launch automatically those action

## Explaination

compulsory

### in the main.tf file:

creating the ec2 instance:

```terraform
resource "aws_instance" "servers" {
    ami                 = "ami-00680fd4e58e51542"
    instance_type       = "t3.micro"
    key_name            = "<your key name here>"

    security_groups = [aws_security_group.minimal-conf.name]

    tags = {
        Name = "Terraformed"
    }
}
```

creating a security group that allow ssh

```terraform
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
```

Generate automatically the hosts file which ansible will use:

```terraform
data "template_file" "hosts" {
    template = file("./hosts.tpl")
    vars = {
        instance_name = join(" ansible_user=<the username of the instance> ansible_ssh_private_key_file=<path to your key here> ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n", concat(aws_instance.servers.*.public_ip, [""]))
    }
}

resource "local_file" "hosts_file" {
    content  = data.template_file.hosts.rendered
    filename = "./ansible/hosts"
}
```

### in the ansible playbook

this is compulsory for amazone linux, by default there is no nignx package in amazone linux, we need to enable amazone linux extras first

```ansible
    - name: Enable Nginx in Amazon Linux Extras
      command: amazon-linux-extras enable nginx1
      when: ansible_os_family == "RedHat"
```
