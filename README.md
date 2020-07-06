# Spinning up a Load Balanced API With Terraform and Ansible on GCP

This repo employs Terraform and Ansible to deploy an API onto GCP. Terraform is firstly used to set up the infrastructure. Ansible will then install Docker, pull an image of the API, then create a container for it. 

## Steps:

### Install Software:
1. Install Terraform and Ansible using Homebrew `brew install terraform ansible`

### Getting SSH Keys:
1. If you don't have any, you can use `ssh-keygen` to generate a public/private key pair. No password is required. Can just hit <enter> when it asks. 

### Configuring Google Cloud Platform (GCP)
1. Go to https://console.cloud.google.com/

2. If you don't have a project, please create one. If you do have one, it is recommended to create one anyways to start on a clean environment. Note that the project id is important for later steps. To do this, click on the project menu to the right of "Google Cloud Platform" in the header. Then click on "New Project" and follow the instructions. More details can be found here: https://cloud.google.com/resource-manager/docs/creating-managing-projects. 

3. Create a GCP service key json file and store it in an appropriate location. To do this, on the hamburger menu in the top left of the header, select "IAM & Accounts" then go to "Service Accounts" in the left menu. Once there, click on "Create  Service Account". On the second step, either a _Owner_ or _Editor_ role should suffice. The third step can be skipped. Once the account is created, please create the JSON key under the "Action" menu in the table. Note that the final file downloaded is important for next steps. More details can be found here: https://cloud.google.com/iam/docs/creating-managing-service-account-keys

4. If this is your first time, it will also be necessary to enable the Compute Engine API. Go to https://console.cloud.google.com/apis/library/compute.googleapis.com?q=Compute%20E&id=a08439d8-80d6-43f1-af2e-6878251f018d and click Enable

5. If this is your first time, you may also need to login and authorize google SDK <> terraform communication. To do this, install the Google SDK via the instructions here: https://cloud.google.com/sdk/docs/quickstart-macos and then login using this command: `gcloud auth application-default login`

### Running the Repo
1. Clone the repo and `cd` into the folder.

2. If this is your first time, run `terraform init` to download the load balancer module. If this works, you should see a new `.terraform` folder. Can check by running `ls -la`. No need to go into it. 

3. From the base directory of the repo, run a command similar to the below to deploy the infrastructure stack. Note that fields below are necessary and that -p, -q, -c and -i values were obtained in steps in prior sections. 

Cmd: `bash 1_run_terraform.sh -u <username> -p <public_key_path> -q <private_key_path> -c <service_account_credential_file> -i <project_id>`

Ex: `bash 1_run_terraform.sh -u tennisonyu -p ~/.ssh/id_rsa.pub -q ~/.ssh/id_rsa -c ansible-terraform-282015-f4561a76bd8d.json -i ansible-terraform-282015`

---
Parameters:
1) -u string of any username to use for the instances.
2) -p string of the path of the public key
3) -q string of the path of the private key
4) -c string of the path of json credentials file for the service account
5) -i string of the project id
6) -n integer of instances to make. Default = 2
7) -z string of the zone of the project. Default = us-west1-b
8) -r string of the region of the project. Default  = us-west1
---

Once complete, there should be IPs that are printed. You can verify that it matches the VMs created on GCP. You can also verify that a VM group and a Load Balancer are created on their respective pages. Also important to confirm is that the `ansible/hosts/hosts.ini` file has matching IP addresses. 


4. From the base directory of the repo, run the command below to deploy the API on each instance
`bash 2_run_ansible.sh`

5. After running last step, there should be a url provided you can use to test. Please run that url in your browser

6. If everything looks good, you can use the command below to tear down the infrastructure.

Cmd: `terraform destroy -var "credentials_file=<credential_file>"`

Ex: `terraform destroy -var "credentials_file=ansible-terraform-282015-f4561a76bd8d.json"`

## Troubleshooting

- It may be necessary to enable some GPC APIs. Ex: `Error: Error creating GlobalAddress: googleapi: Error 403: Compute Engine API has not been used`. In this case enable Compute Engine API: https://console.developers.google.com/apis/library/compute.googleapis.com?pli=1
- Running ansible might trigger host checking `Are you sure you want to continue connecting`. It has been rarely observed that this blocks the process. If so, stop the process, ssh into the instance separately and then try running the step again.
- Running ansible, also rarely observed error installing package ` FAILED! => {"changed": false, "cmd": "apt-get install --no-install-recommends python-apt...`. There are retries set but if this blocks, just rerun the step.
- May get error like `Error: google: could not find default credentials.`. If this happens, run this: `gcloud auth application-default login`

## Resources Used:
1. https://learn.hashicorp.com/terraform/gcp/build
2. https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform
3. https://www.youtube.com/watch?v=Wjp7O1zO-Ag
4. https://github.com/do-community/ansible-playbooks/tree/master/docker_ubuntu1804

