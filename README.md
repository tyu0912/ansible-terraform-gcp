# Spinning up a Load Balanced API With Terraform and Ansible on GCP

This repo employs Terraform and Ansible to deploy an API onto GCP. Terraform is firstly used to set up the infrastructure. Ansible will then install Docker, pull an image of the API, then create a container for it. 

## Steps:

1. Install Terraform and Ansible using Homebrew `brew install terraform ansible`

2. Create a GCP service key json file and store it in an appropriate location. You can follow these steps: https://cloud.google.com/iam/docs/creating-managing-service-account-keys

3. Run the command below to deploy the infrastructure stack:
`bash 1_run_terraform.sh -u tennisonyu -p ~/.ssh/id_rsa.pub -q ~/.ssh/id_rsa -c "ansible-terraform-282015-f4561a76bd8d.json" -i 3`

Parameters:
1) -u string of the username to use for the instances
2) -p string of the path of the public key
3) -q string of the path of the private key
4) -c string of the path of json file in step 2
5) -i optional parameter of the number of instances to make

4. Run the command below to deploy the API on each instance
`bash 2_run_ansible.sh `

## Troubleshooting

- It may be necessary to enable some GPC APIs. For example: Enable Computer Engine API: https://console.developers.google.com/apis/library/compute.googleapis.com?pli=1
- Running ansible might trigger host checking `Are you sure you want to continue connecting`. It has been rarely observed that this blocks the process. If so, stop the process, ssh into the instance separately and then try running step 4 above again.
- Running ansible, also rarely observed error installing package ` FAILED! => {"changed": false, "cmd": "apt-get install --no-install-recommends python-apt...`. There are retries set but if this blocks, just rerun the step.

## Resources Used:
1. https://learn.hashicorp.com/terraform/gcp/build
2. https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform
3. https://www.youtube.com/watch?v=Wjp7O1zO-Ag
4. https://github.com/do-community/ansible-playbooks/tree/master/docker_ubuntu1804

