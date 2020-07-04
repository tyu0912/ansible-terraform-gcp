deploy_api_on_ansible () {
    (ansible-playbook ansible/playbook.yml -i $1)
}

get_load_balancer_ip () {
    ip=$(terraform show | grep ip_address | cut -d '"' -f 2)
    echo "Finished. Try http://$ip/ in your browser"
}

host_ini_file="ansible/hosts/hosts.ini"
export ANSIBLE_HOST_KEY_CHECKING=false

deploy_api_on_ansible $host_ini_file
get_load_balancer_ip

export ANSIBLE_HOST_KEY_CHECKING=true