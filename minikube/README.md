# Learn Kubernetes with minikube

# Get Started

```bash
$ minikube start
$ minikube dashboard
```

### Create a deployment and service

```bash
$ kubectl apply -f helloworld_deployment.yml
$ kubectl apply -f helloworld_service.yml
```

### Make it accessible outside k8s

```bash
$ minikube service helloworld-service
```

### Clean up

```bash
$ kubectl delete service helloworld-service
$ kubectl delete deployment helloworld-deployment
```
