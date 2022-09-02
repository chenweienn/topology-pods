#!/bin/bash

set -uo pipefail

# set -x

SCRIPT_NAME=$(basename $0)

usage() {
    echo "Print the mapping between pods, worker nodes, and ESXi hosts on TKGI+vSphere platform."
    echo ""
    echo "Usage:"
    echo "      $SCRIPT_NAME [-v|--verbose] [-h|--help]"
    echo ""
    echo "Options:"
    echo "      -h, --help              Print usage"
    echo "      -v, --verbose           Print verbose log about prerequisites check"
    echo ""
    echo "Prerequisites:"
    echo "      1. Install jq"
    echo "      2. Authenticate with kubectl, bosh, govc CLIs"
    echo "         Examples:"
    echo "           export KUBECONFIG=kubeconfig_file"
    echo "           export BOSH_CLIENT=client_id BOSH_CLIENT_SECRET=client_secret BOSH_CA_CERT=ca_file BOSH_ENVIRONMENT=bosh_ip"
    echo "           export GOVC_URL=vcenter_ip GOVC_USERNAME=administrator@vsphere.local GOVC_PASSWORD='password' GOVC_INSECURE=true"
}

# processing args

VERBOSE=false

while [[ $# -gt 0 ]]
do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "[error] unrecognized option: $1"
            usage
            exit 0
            ;;
    esac
done

check_prerequisites() {
    if $VERBOSE; then
        echo "[info]  Checking prerequisites (jq, kubectl, bosh, govc)"

        echo -e "[info]  Checking if jq is installed ... \n"
        echo "\$ jq --version"
        if ! (jq --version); then
            echo -e "\n[error] Please install jq first. Use --help to see usage.\n"
            exit 1
        fi
        echo -e "\n[info]  Passed jq installation check"

        echo -e "[info]  Checking govc auth via \"govc about\" ... \n"
        echo "\$ govc about"
        if ! (govc about); then
            echo -e "\n[error] Failed govc auth check. Use --help to see usage.\n"
            exit 1
        fi
        echo -e "\n[info]  Passed govc auth check"
        
        echo -e "[info]  Checking bosh auth via \"bosh env\" ... \n"
        echo "\$ bosh env"
        if ! (bosh env); then
            echo -e "\n[error] Failed bosh auth check. Use --help to see usage.\n"
            exit 1
        fi
        echo -e "\n[info]  Passed bosh auth check"
        
        echo -e "[info]  Checking kubectl auth via \"kubectl auth can-i list pods -A\" ... \n"
        echo "\$ kubectl auth can-i list pods -A"
        if ! (kubectl auth can-i list pods -A); then
            echo -e "\n[error] Failed kubectl auth check. Use --help to see usage.\n"
            exit 1
        fi
        echo -e "\n[info]  Passed kubectl auth check"

        echo "[info]  Passed all prerequisites check"
    else
        if ! (jq --version > /dev/null); then
            echo -e "\n[error] Please install jq first. Use --help to see usage.\n"
            exit 1
        fi

        if ! (govc about > /dev/null); then
            echo -e "\n[error] Failed govc auth check via \"govc about\". Use --help to see usage.\n"
            exit 1
        fi

        if ! (bosh env > /dev/null); then
            echo -e "\n[error] Failed bosh auth check via \"bosh env\". Use --help to see usage.\n"
            exit 1
        fi

        if ! (kubectl auth can-i list pods -A > /dev/null); then
            echo -e "\n[error] Failed kubectl auth check via \"kubectl auth can-i list pods -A\". Use --help to see usage.\n"
            exit 1
        fi
    fi
}

main() {
    # check prerequisites jq, kubectl, bosh, govc
    check_prerequisites
   
    # create a temp file
    TEMP_FILE="temp-file-$(date -u +%y-%m-%dT%H:%M:%S)"
    if $VERBOSE; then
        echo -e "[info]  Creating temp file $TEMP_FILE to store the mapping of pod-node-host ..."    
    fi
    echo "Pod_Namespace Pod_Name Pod_IP Node_Name Node_IP Node_VM_CID ESXi_Host" > $TEMP_FILE

    echo -e "\nBuilding the mapping of pod-node-host (it may take a few seconds) ...\n"    

    kubectl get pods -A -o json | jq -c '.items[] | {"Pod_Namespace": .metadata.namespace, "Pod_Name":.metadata.name, "Pod_IP":.status.podIP, "Node_Name":.spec.nodeName}' | \
        while read line; do
            POD_NAMESPACE=$(echo "$line" | jq '.Pod_Namespace' -r)
            POD_NAME=$(echo "$line" | jq '.Pod_Name' -r)
            POD_IP=$(echo "$line" | jq '.Pod_IP' -r)
            NODE_NAME=$(echo "$line" | jq '.Node_Name' -r)
            NODE_BOSH_ID=$(kubectl get node $NODE_NAME -o json | jq -r '.metadata.labels."bosh.id"')
            BOSH_DEPLOYMENT=$(kubectl get node $NODE_NAME -o json | jq -r '.metadata.labels."pks-system/cluster.uuid"')
            # NODE_VM_CID=$(bosh -d $BOSH_DEPLOYMENT vms --json | jq --arg INSTANCE_ID $NODE_BOSH_ID -r '.Tables[].Rows[] | select(.instance | contains($INSTANCE_ID)) | .vm_cid')
            NODE_BOSH_INFO=$(bosh -d $BOSH_DEPLOYMENT vms --json | jq --arg INSTANCE_ID $NODE_BOSH_ID -c '.Tables[].Rows[] | select(.instance | contains($INSTANCE_ID))')
            NODE_BOSH_VM_CID=$(echo $NODE_BOSH_INFO | jq -r '.vm_cid')
            NODE_BOSH_IP=$(echo $NODE_BOSH_INFO | jq -r '.ips')
            NODE_ESXI_HOST=$(govc vm.info $NODE_BOSH_VM_CID | grep "Host:" | awk '{print $2}')
            echo "$POD_NAMESPACE $POD_NAME $POD_IP $NODE_NAME $NODE_BOSH_IP $NODE_BOSH_VM_CID $NODE_ESXI_HOST" >> $TEMP_FILE
        done
    
    cat $TEMP_FILE | column -t
    echo ""
    
    if $VERBOSE; then
        echo -e "[info]  Deleting temp file $TEMP_FILE ..."
    fi
    rm $TEMP_FILE
    if $VERBOSE; then
        echo "[info]  Done"
    fi
}

main
