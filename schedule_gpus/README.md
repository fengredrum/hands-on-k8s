```shell
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

```shell
sudo apt-get update && \
sudo apt-get install -y nvidia-docker2
```

```shell
vim /etc/docker/daemon.json
```

```json
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}

```

```shell
sudo systemctl restart docker
```

```shell
docker run --rm nvidia/cuda:11.0-base nvidia-smi
```

```shell
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.9.0/nvidia-device-plugin.yml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-example
spec:
  restartPolicy: Never
  containers:
    - name: gpu-example
      image: nvidia/cuda:11.0-base
      imagePullPolicy: IfNotPresent
      command: ["nvidia-smi"]
      resources:
        limits:
          nvidia.com/gpu: 1
```