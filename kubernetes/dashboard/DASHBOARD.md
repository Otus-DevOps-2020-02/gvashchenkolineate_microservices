# Kubernetes Dashboard in GKE

_According to [this](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md):_

  - Enable the dashboard addon in GKE
  - Create a service account and bind `cluster-admin` role to it

        kubectl apply -f .

  - Get a Bearer Token from output of

        kubectl -n kube-system describe secret \
            $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

  - Start proxying a dashbord to localhost:

        kubectl proxy

  - Go to the URL below and authenticate with the token
    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
