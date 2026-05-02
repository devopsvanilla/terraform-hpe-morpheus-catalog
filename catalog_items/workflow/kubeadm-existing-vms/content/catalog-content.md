# Kubernetes Cluster Installation with kubeadm

Install a Kubernetes cluster on existing Morpheus VMs using kubeadm.

## Request fields

- Morpheus group
- Morpheus cloud
- Kubernetes version
- Cluster name
- Control Plane VM list
- Worker VM list
- Pod Network CIDR (optional)
- Add-on profile
- CNI
- CSI
- Ingress controller
- Observability add-ons
- Security add-ons
- GitOps add-ons

## Execution summary

1. Validate OS and prerequisites on selected nodes.
2. Initialize cluster on first control plane node.
3. Join additional control plane nodes.
4. Join worker nodes.
5. Install the selected cluster add-ons on the primary control plane node.

## Notes

- Targets must be Linux hosts.
- Target VMs should already be reachable by Morpheus task execution.
- Select a group first, then a cloud. VM selectors are filtered by the selected cloud.
- Add-on choices are limited to the components currently automated by this workflow.
- Validate network, DNS, time sync, and container runtime prerequisites before execution.
