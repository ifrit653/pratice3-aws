#!/bin/bash

set -e

terraform init
terraform validate
terraform plan
terraform apply

ansible-playbook ansible/myansibleplaybook.yml -i ansible/hosts