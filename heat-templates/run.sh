#!/bin/bash


usage() {
    cat <<__EOF__
Usage:
   run.sh [create|delete]

Options:
    create Deploy demo-tenant and the heat stack
    delete Remove demo-tenant and the heat stack

__EOF__
}


create() {
    . ../../keystonerc_admin
    openstack project create demo-tenant
    openstack user create developer --password redhat01
    user=$(openstack user show developer -f value -c id) 
    admin=$(openstack user show admin -f value -c id) 
    project=$(openstack project show demo-tenant -f value -c id)
    openstack role add --user $user --project $project _member_
    openstack role add --user $admin --project $project admin
    sed -i  "/default project id/{n;s/.*/    default: $project/}" ../heat-templates/stack-3tier.yaml
    cp ../../keystonerc_admin ~/demo-tenant-rc-v3
    sed -i -e 's/OS_USERNAME=\(.*\)/OS_USERNAME=developer/g' \
        -e 's/OS_PROJECT_NAME=\(.*\)/OS_PROJECT_NAME=demo-tenant/g' ~/demo-tenant-rc-v3


    sudo cp ~/heat-templates/lb-resource-stack-3tier.yaml /var/www/html/heat-templates/
    restorecon /var/www/html/heat-templates/lb-resource-stack-3tier.yaml
    . ~/demo-tenant-rc-v3
    openstack keypair create --public-key /root/.ssh/id_rsa.pub root-osp
    time openstack stack create --wait -t /root/rhosp_heat_stack/heat-templates/stack-3tier.yaml demo-tenant \
        2>&1 | tee /root/rhosp_heat_stack/heat-templates/stack-3tier-$(date +%d%m%Y-%H%M%S).log &
}


delete() {
    . ../../keystonerc_admin
    stackid=$(openstack stack list -f value | grep demo-tenant | awk {'print $1'})
    openstack stack delete $stackid --yes --wait
    openstack user delete developer
    openstack keypair delete root-osp
    openstack project delete demo-tenant
}


case $1 in
    create) create;;
    delete) delete;;
    *|-h|--help) usage;;
esac
