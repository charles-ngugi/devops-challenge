# Bird Application

This is the bird Application! It gives us birds!!!

The app is written in Golang and contains 2 APIs:
- the bird API
- the birdImage API

Technologies used: Docker, Kubernetes, MicroK8s, helm and Terraform.

### Infra creation on AWS
While in the infra directory
- `cp terraform.tfvars.example terraform.tfvars` then fill in the details.
- `terraform init`
- `terraform validate`
- `terraform fmt`
- `terraform plan`
- `terraform apply` 
The deployment includes installation of dependencies ie Docker, microk8s and helm.

## Installation & how to run it

#### Running the app
This can be run using docker containers or either utilizing kubernetes.
The two images used are public.

### Docker

`docker pull charlesngugi023/birdimageapi:latest & docker pull charlesngugi023/birdapi:latest`
create a network to be used by the two containers. eg `docker create network bird`

#### In the bird directory
`docker run -d --network bird -p 4201:4201 -it --name bird_api charlesngugi023/birdapi`

#### In the birdImage directory
`docker run -d --network bird -p 4200:4200 -it --name bird_image_api charlesngugi023/birdimageapi`

Access the app on http://localhost:4201

### Kubernetes
**prerequisites: Docker, kubernetes, microk8s/ minikube or a tool of your choice and helm.**

You can create an alias i.e `alias kubectl='microk8s kubectl'` 
To run the app:
- `kubectl create namespace bird-api`
- `kubectl create namespace monitoring`
- `kubectl apply -f k8s/` while in the root directory
- `microk8s helm3 install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --set prometheus.service.name=prometheus`
- `microk8s helm3 install grafana grafana/grafana --namespace monitoring --set service.name=grafana`
- `kubectl get all -n bird-api` to see deployments, services, replicasets, pods and HPAs.
-  `kubectl get ingress -n bird-api` to see the ingress used to serve the app
