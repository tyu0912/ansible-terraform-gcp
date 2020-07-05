generate_new_stack () {

    if [[ ! -z $5 ]]
    then
        instance_counts="-var instance_count=$5"
    fi

    if [[ ! -z $6 ]]
    then
        project_region="-var region=$6"
    fi

    if [[ ! -z $7 ]]
    then
        project_zone="-var zone=$7"
    fi

    terraform apply -var username=$1 -var public_key=$2 -var credentials_file=$3 -var project=$4 $instance_counts $project_region $project_zone
}

generate_new_ansible_ini () {
    file=$3
    rm $file

    ips=$(terraform output -json ip)
    ips=${ips/[/""}
    ips=${ips/]/""}

    IFS=',' read -ra ADDR <<< "$ips"
    for i in "${ADDR[@]}"; do
        echo "$i ansible_user=$1 ansible_ssh_private_key_file=$2" >> $file
    done
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "This script is to use Terraform and Ansible to deploy a load-balanced API"
      echo " "
      echo "Example run: bash 1_run_terraform.sh [options]"
      echo " "
      echo "options:"
      echo "-h, --help                   show brief help"
      echo "-p, --public_key=PATH        path of the public key [REQUIRED]"
      echo "-q, --private_key=PATH       path of the private key [REQUIRED]"
      echo "-u, --username=STR           name of the account on instances [REQUIRED]"
      echo "-q, --credentials=PATH       gcp service account json file [REQUIRED]"
      echo "-i, --project_id=STR         string of the gcp project id [REQUIRED]"
      echo "-z, --project_zone=STR       string of the zone of the instances. Default=us-west1-b"
      echo "-r, --project_region=PATH    string of the region of the instances. Default=us-west1"
      echo "-n, --number_instances=INT   number of instances to use. Default=2"
      exit 0
      ;;
    -p|--public_key)
      shift
      if test $# -gt 0; then
        export PUBLICKEY=$1
      else
        echo "no public key location specified"
        exit 1
      fi
      shift
      ;;
    -q|--private_key)
      shift
      if test $# -gt 0; then
        export PRIVATEKEY=$1
      else
        echo "no private key location specified"
        exit 1
      fi
      shift
      ;;
    -u|--username)
      shift
      if test $# -gt 0; then
        export USERNAME=$1
      else
        echo "no username specified"
        exit 1
      fi
      shift
      ;;
    -c|--credentials)
      shift
      if test $# -gt 0; then
        export CREDENTIALS=$1
      else
        echo "no credential path specified"
        exit 1
      fi
      shift
      ;;
    -n|--number_instances)
      shift
      if test $# -gt 0; then
        export INST_COUNT=$1
      else
        export INST_COUNT=""
        echo "no instance count specified"
        exit 1
      fi
      shift
      ;;
    -i|--project_id)
      shift
      if test $# -gt 0; then
        export PROJECT_ID=$1
      else
        echo "no instance count specified"
        exit 1
      fi
      shift
      ;;
    -z|--project_zone)
      shift
      if test $# -gt 0; then
        export PROJECT_ZONE=$1
      else
        echo "no instance count specified"
        exit 1
      fi
      shift
      ;;
    -r|--project_region)
      shift
      if test $# -gt 0; then
        export PROJECT_REGION=$1
      else
        echo "no instance count specified"
        exit 1
      fi
      shift
      ;;
      esac
done

if [[ -z $USERNAME ]] ||  [[ -z $PUBLICKEY ]] || [[ -z $CREDENTIALS ]] || [[ -z $PRIVATEKEY ]] || [[ -z $PROJECT_ID ]]
then
    echo "A required variable seems to be missing. Run -h argument to see what is required"
    exit 1
fi

host_ini_file="ansible/hosts/hosts.ini"

generate_new_stack $USERNAME $PUBLICKEY $CREDENTIALS $PROJECT_ID $INST_COUNT $PROJECT_REGION $PROJECT_ZONE
generate_new_ansible_ini $USERNAME $PRIVATEKEY $host_ini_file