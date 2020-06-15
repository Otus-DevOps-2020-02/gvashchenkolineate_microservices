# [Kubernetes: The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

Walkthrough for manual Kubernetes setup in GCP


#### [Prerequisites](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md)

   - Auth with AWS CLI
   - Install Tmux

#### [Installing the Client Tools](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-client-tools.md)

   - Install CFSSL
   - Install Kubectl

#### [Provisioning Compute Resources](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md)

  - Create:
     - VPC
     - Subnet
     - Firewall rules
     - Public IP Address for Kubernetes
     - Compute instances:
       - 2 controllers
       - 2 workers

       Note: GCP Free-Tier allows only 4
  - SSH access

    gcloud compute ssh kubernetes@controller-0 --ssh-key-file=~/.ssh/gcp_kubernetes
    gcloud compute ssh kubernetes@controller-1 --ssh-key-file=~/.ssh/gcp_kubernetes

#### [Provisioning a CA and Generating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md)

  - Create certificates for each Kubernetes component
  - Copy the certificates and private keys to workers:

        for instance in worker-0 worker-1 ; do
            gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem \
                kubernetes@${instance}:~/ --ssh-key-file=~/.ssh/gcp_kubernetes
        done

  - Copy the certificates and private keys to controllers:

        for instance in controller-0 controller-1; do
            gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem \
                kubernetes@${instance}:~/ --ssh-key-file=~/.ssh/gcp_kubernetes
        done

#### [Generating Kubernetes Configuration Files for Authentication](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md)

  - Generate Kubernetes configuration files
  - Copy the appropriate `kubelet` and `kube-proxy` kubeconfig files to each worker instance:

        for instance in worker-0 worker-1; do
            gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig \
                kubernetes@${instance}:~/ --ssh-key-file=~/.ssh/gcp_kubernetes
        done

  - Copy the appropriate `kube-controller-manager` and `kube-scheduler` kubeconfig files to each controller instance:

        for instance in controller-0 controller-1; do
            gcloud compute scp \
                admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig \
                kubernetes@${instance}:~/ --ssh-key-file=~/.ssh/gcp_kubernetes
        done

#### [Generating the Data Encryption Config and Key](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/06-data-encryption-keys.md)

  - Generate encryption config file
  - Copy the encryption-config.yaml encryption config file to each controller instance:

        for instance in controller-0 controller-1; do
            gcloud compute scp encryption-config.yaml \
                kubernetes@${instance}:~/ --ssh-key-file=~/.ssh/gcp_kubernetes
        done

#### [Bootstrapping the etcd Cluster](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/07-bootstrapping-etcd.md)

  - Using Tmux ssh to controllers
  - Install and configure etcd
    _(don't forger to remove `controller-2` from /etc/systemd/system/etcd.service)_
  - Start etcd and verify etcd cluster members
  - Verify:

        sudo ETCDCTL_API=3 etcdctl member list \
          --endpoints=https://127.0.0.1:2379 \
          --cacert=/etc/etcd/ca.pem \
          --cert=/etc/etcd/kubernetes.pem \
          --key=/etc/etcd/kubernetes-key.pem

#### [Bootstrapping the Kubernetes Control Plane](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md)

  - Using Tmux ssh to controllers

    - Install the Kubernetes Controller binaries, configure and start
       - the Kubernetes API Server
       - the Kubernetes Controller Manager
       - the Kubernetes Scheduler

    - To enable HTTP health checks (the network load balancer only supports)
      install nginx and start it as a proxy to health checks

    - Configure RBAC permissions allowing the Kubernetes API Server to access the Kubectl API on worker nodes

    - Setup a network Load Balancer for Kubernetes frontend

#### [Bootstrapping the Kubernetes Worker Nodes](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md)

  - Using Tmux ssh to workers

        gcloud compute ssh kubernetes@worker-0 --ssh-key-file=~/.ssh/gcp_kubernetes
        gcloud compute ssh kubernetes@worker-1 --ssh-key-file=~/.ssh/gcp_kubernetes

  - Install OS dependencies
  - Disable Swap
  - Install Worker binaries
  - Configure and start
    - CNI Networking
    - containerd
    - the Kubelet
    - the Kubernetes Proxy

  - Verify

        gcloud compute ssh kubernetes@worker-0 --ssh-key-file=~/.ssh/gcp_kubernetes \
           --command "kubectl get nodes --kubeconfig admin.kubeconfig"

#### [Configuring kubectl for Remote Access](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/10-configuring-kubectl.md)

  - Generate a kubeconfig file suitable for authenticating as the admin user
  - Verify:
    - Check the health of the remote Kubernetes cluster:

          kubectl get componentstatuses

    - List the nodes in the remote Kubernetes cluster:

          kubectl get nodes

#### [Provisioning Pod Network Routes](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/11-pod-network-routes.md)

  - Create network routes for each worker instance
    allowing pods to communicate with each other

#### [Deploying the DNS Cluster Add-on](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/12-dns-addon.md)

  - Deploy the `coredns` cluster add-on
  - Verify:
    - Create a `busybox` deployment
    - List the pod created
    - Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod

#### [Smoke Test](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md)

  - Create a generic secret and print a hexdump of it stored in etcd
  - Create a deployment for `nginx`
  - Establish port forwarding of `nginx` pod
  - Retrieve `nginx` pod logs
  - Execute a remote shell command in the `nginx` container
  - Expose a service and make an HTTP request using the external worker address and `nginx` node port

#### [Clean up](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/14-cleanup.md)

  Delete:
  - the controller and worker instances
  - load balancer resources
  - firewall rules
  - VPC
