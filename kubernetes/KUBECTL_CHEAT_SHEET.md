# Kubectl Cheat Sheet

    kubectl get nodes

    kubectl config current-context
    kubectl config get-contexts

    kubectl apply -f <file>.yml
    kubectl apply -f <dir>

    kubectl get deployment
    kubectl get pods [--selector <label=value> ...]
    # Outputs only Nth pod name
    kubectl get pods -o=name | sed -n '<N> p'

    kubectl port-forward <pod_name> <local_port>:<pod_port>
    kubectl port-forward $(kubectl get pods -o=name --selector component=ui | sed -n '3 p') 8080:9292

    kubectl describe service <service_name>

    kubectl exec -ti <pod_name> nslookup <service_name>

    kubectl logs <pod_name>
    kubectl logs $(kubectl get pods -o=name --selector component=post | sed -n '3 p')
