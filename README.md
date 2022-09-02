# Purpose
Mapping pods to worker nodes and ESXi hosts on TKGI+vSphere platform.

# Prerequisites

1. Install jq
2. Authenticate with kubectl, bosh, govc CLIs

```
export KUBECONFIG=kubeconfig_file
export BOSH_CLIENT=client_id BOSH_CLIENT_SECRET=client_secret BOSH_CA_CERT=ca_file BOSH_ENVIRONMENT=bosh_ip
export GOVC_URL=vcenter_ip GOVC_USERNAME=administrator@vsphere.local GOVC_PASSWORD='password' GOVC_INSECURE=true
```

# Usage

```
Usage:
      mapping-pod-node-host.sh [-v|--verbose] [-h|--help]

Options:
      -h, --help              Print usage
      -v, --verbose           Print verbose log about prerequisites check
```

# Example output

```
$ ./mapping-pod-node-host.sh

Building the mapping of pod-node-host (it may take a few seconds) ...

Pod_Namespace  Pod_Name                                Pod_IP     Node_Name                             Node_IP   Node_VM_CID                              ESXi_Host
kube-system    coredns-67bd78c556-5kqld                40.0.4.4   e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
kube-system    coredns-67bd78c556-89mls                40.0.4.2   146f9484-3a2c-47f8-8c05-66d486a86537  30.1.0.6  vm-f2745dd7-56be-440e-aed8-cd9fdb473cbd  192.168.111.125
kube-system    coredns-67bd78c556-wf86r                40.0.4.3   f048b46c-86a5-4847-9c87-aac918f8ce54  30.1.0.5  vm-2d4c60a5-d023-4840-9b6e-447757c8f702  192.168.111.125
kube-system    metrics-server-66c5bff789-r9j65         40.0.4.5   e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     event-controller-795755d67-ppq5j        40.0.5.16  e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     fluent-bit-f5hrv                        40.0.5.3   f048b46c-86a5-4847-9c87-aac918f8ce54  30.1.0.5  vm-2d4c60a5-d023-4840-9b6e-447757c8f702  192.168.111.125
pks-system     fluent-bit-fvhqj                        40.0.5.4   146f9484-3a2c-47f8-8c05-66d486a86537  30.1.0.6  vm-f2745dd7-56be-440e-aed8-cd9fdb473cbd  192.168.111.125
pks-system     fluent-bit-w72h6                        40.0.5.22  e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     metric-controller-669f9bc57b-w897r      40.0.5.20  e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     observability-manager-64cbd6c45d-5xp82  40.0.5.7   e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     sink-controller-77c8c69d54-slljd        40.0.5.17  e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     telegraf-bn7dd                          30.1.0.6   146f9484-3a2c-47f8-8c05-66d486a86537  30.1.0.6  vm-f2745dd7-56be-440e-aed8-cd9fdb473cbd  192.168.111.125
pks-system     telegraf-d684k                          30.1.0.5   f048b46c-86a5-4847-9c87-aac918f8ce54  30.1.0.5  vm-2d4c60a5-d023-4840-9b6e-447757c8f702  192.168.111.125
pks-system     telegraf-st8pn                          30.1.0.3   e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
pks-system     telemetry-agent-6f6f75b47-4vm7c         40.0.5.2   f048b46c-86a5-4847-9c87-aac918f8ce54  30.1.0.5  vm-2d4c60a5-d023-4840-9b6e-447757c8f702  192.168.111.125
pks-system     validator-8567d4b66-5vr5f               40.0.5.21  e6d520ca-cdee-43da-a1d3-fc1e2b3154a6  30.1.0.3  vm-f10f4b1f-d1ea-41d6-b2b4-0315ffb9d459  192.168.111.24
```
