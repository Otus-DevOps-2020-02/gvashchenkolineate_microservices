# Kubectl Cheat Sheet

    kubectl get nodes
    kubectl get nodes -o wide

    kubectl config current-context
    kubectl config get-contexts

    kubectl apply -f <file>.yml
    kubectl apply -f <dir>

    kubectl get deployment
    kubectl get pods [--selector <label=value> ...]
    # Outputs only Nth pod name
    kubectl get pods -o=name | sed -n '<N> p'
    kubectl get pods --all-namespaces
    kubectl get pods -n <namespace>

    kubectl get namespace
    kubectl get ns

    kubectl port-forward <pod_name> <local_port>:<pod_port>
    kubectl port-forward $(kubectl get pods -o=name --selector component=ui | sed -n '3 p') 8080:9292

    kubectl describe service <service_name>
    kubectl describe service <service_name> -n <namespace> [| grep NodePort]

    kubectl exec -ti <pod_name> nslookup <service_name>

    kubectl logs <pod_name>
    kubectl logs $(kubectl get pods -o=name --selector component=post | sed -n '3 p')

    kubectl delete -f <file>.yml
    kubectl delete service <service_name>

    kubectl proxy
    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

    kubectl get secrets
    kubectl describe sercet <secret_name>

    kubectl get serviceaccounts --all-namespaces
    kubectl get roles --all-namespaces
    kubectl get clusterrole

# Minikube Cheat Sheet

    minikube start [--driver=virtualbox]
    minikube status
    minikube delete

    minikube service list
    minikube addons list

    minikube dashboard
    minikube service kubernetes-dashboard -n kube-system
