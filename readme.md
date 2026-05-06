# AKS Website Demo

A sample ASP.NET Core web application designed to help IT/Operations professionals learn Azure Kubernetes Service (AKS) deployment and management fundamentals.

## Overview

This repository contains a simple ASP.NET Core Razor Pages web application built for **Windows containers**, demonstrating the complete workflow of containerizing an application and deploying it to Azure Kubernetes Service (AKS). The project is specifically designed as a learning resource for IT/Ops teams who want to understand how AKS works from an operational perspective.

## What's Included

- **ASP.NET Core 8.0 Web Application** - A simple Razor Pages website that serves as the deployment target
- **Dockerfile** - Windows Server Core-based container configuration
- **Kubernetes Manifests** - Deployment, Service, ConfigMap, and Namespace definitions
- **PowerShell Scripts** - Step-by-step session scripts for hands-on learning
- **Azure Integration** - Ready for Azure Container Registry (ACR) and AKS deployment

## Learning Objectives

This demo helps you understand:

- **Container Basics**: Building Docker images and running containers locally
- **Azure Container Registry (ACR)**: Pushing images to a private container registry
- **AKS Cluster Management**: Creating and configuring an AKS cluster with Windows node pools
- **Kubernetes Concepts**: Deployments, Services, ConfigMaps, Namespaces, and node selectors
- **CI/CD Workflow**: The complete path from code to production deployment
- **Troubleshooting**: Common kubectl commands and debugging techniques

## Prerequisites

Before starting, ensure you have:

- **Docker Desktop** (with Windows containers enabled)
- **.NET 8.0 SDK**
- **Azure CLI** (`az`)
- **kubectl** (Kubernetes command-line tool)
- **Azure Subscription** with contributor access
- **PowerShell** (Windows PowerShell or PowerShell Core)

## Project Structure

```
AKS-WebSite-Demo/
├── AksDemoWebsite/              # Web application source code
│   ├── Pages/                   # Razor Pages
│   ├── wwwroot/                 # Static files (CSS, JS)
│   ├── dockerfile               # Windows container definition
│   ├── aks-demo-template.yaml   # Kubernetes manifest template
│   └── AksDemoWebsite.csproj    # Project file
├── session-script-template.ps1  # PowerShell walkthrough script
└── readme.md                    # This file
```

## Quick Start Guide

### Step 1: Local Docker Build and Test

Navigate to the project directory and build the Docker image:

```powershell
cd .\AksDemoWebsite
docker build -t aksdemo:v1 -f dockerfile .
```

Run the container locally:

```powershell
docker run -d -p 8080:80 --name aksdemo-local -e SESSION_COUNT=400 aksdemo:v1
```

Test the application by opening your browser to `http://localhost:8080`

### Step 2: Azure Container Registry Setup

Login to Azure:

```powershell
az login
```

Create or use an existing ACR:

```powershell
$ACR_NAME = "your-acr-name"  # Replace with your ACR name
$RESOURCE_GROUP = "your-resource-group"
$LOCATION = "eastus"

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $LOCATION
```

Tag and push the image:

```powershell
docker tag aksdemo:v1 $ACR_NAME.azurecr.io/aksdemo:v1
az acr login --name $ACR_NAME
docker push $ACR_NAME.azurecr.io/aksdemo:v1
```

### Step 3: AKS Cluster Deployment

Create an AKS cluster with both Linux and Windows node pools:

```powershell
az aks create `
  --resource-group $RESOURCE_GROUP `
  --name myAKSCluster `
  --node-count 1 `
  --enable-managed-identity `
  --network-plugin azure `
  --windows-admin-username azureuser `
  --windows-admin-password "YourPassword123!" `
  --attach-acr $ACR_NAME
```

Add a Windows node pool (required for this application):

```powershell
az aks nodepool add `
  --resource-group $RESOURCE_GROUP `
  --cluster-name myAKSCluster `
  --os-type Windows `
  --name npwin `
  --node-count 1
```

Get cluster credentials:

```powershell
az aks get-credentials --resource-group $RESOURCE_GROUP --name myAKSCluster
```

### Step 4: Deploy to Kubernetes

Update the Kubernetes manifest:

1. Copy `aks-demo-template.yaml` to `aks-demo.yaml`
2. Replace `<your-acr-name>` with your actual ACR name
3. Apply the configuration:

```powershell
kubectl apply -f aks-demo.yaml
```

Monitor the deployment:

```powershell
kubectl get pods -n aks-demo --watch
kubectl get services -n aks-demo
```

Access your application using the external IP assigned by the Azure Load Balancer.

## Key Kubernetes Concepts Demonstrated

### Namespaces
Logical isolation for resources - the demo uses the `aks-demo` namespace.

### Deployments
Manages pod replicas and rolling updates with defined resource limits and requests.

### Services
Exposes the application via Azure Load Balancer with a public IP.

### ConfigMaps
Stores configuration data (e.g., `SESSION_COUNT`) that can be injected as environment variables.

### Node Selectors
Ensures pods run on Windows nodes using `kubernetes.io/os: windows`.

## Useful kubectl Commands

```powershell
# View all resources in the namespace
kubectl get all -n aks-demo

# View pod logs
kubectl logs -n aks-demo <pod-name>

# Describe a pod (for troubleshooting)
kubectl describe pod -n aks-demo <pod-name>

# Execute commands inside a container
kubectl exec -it -n aks-demo <pod-name> -- cmd

# Scale the deployment
kubectl scale deployment aksdemo-deployment -n aks-demo --replicas=3

# View ConfigMaps
kubectl get configmap -n aks-demo

# Delete resources
kubectl delete -f aks-demo.yaml
```

## Troubleshooting

### Pods stuck in "ImagePullBackOff"
- Verify ACR integration: `az aks check-acr --resource-group $RESOURCE_GROUP --name myAKSCluster --acr $ACR_NAME.azurecr.io`
- Ensure the image name in the YAML matches your ACR

### Pods pending
- Check if Windows nodes are ready: `kubectl get nodes`
- Verify node selector configuration

### Can't access the service
- Ensure the LoadBalancer service has an external IP: `kubectl get svc -n aks-demo`
- Check Azure NSG rules if using custom networking

## Learning Path

1. **Start Local**: Build and run the Docker container on your machine
2. **Push to ACR**: Understand private container registries
3. **Deploy to AKS**: Apply Kubernetes manifests and observe resource creation
4. **Experiment**: Try scaling, updating, and rolling back deployments
5. **Monitor**: Use kubectl commands to inspect cluster state
6. **Clean Up**: Practice deleting resources properly

## Additional Resources

- [Azure Kubernetes Service Documentation](https://learn.microsoft.com/azure/aks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Docker Documentation](https://docs.docker.com/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)

## Clean Up

To avoid Azure charges, delete resources when done:

```powershell
# Delete Kubernetes resources
kubectl delete namespace aks-demo

# Delete AKS cluster
az aks delete --resource-group $RESOURCE_GROUP --name myAKSCluster --yes --no-wait

# Delete ACR (optional)
az acr delete --resource-group $RESOURCE_GROUP --name $ACR_NAME --yes

# Delete resource group (if no longer needed)
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

## License

This project is provided as-is for educational purposes.

## Contributing

This is a learning resource. Feel free to fork and adapt it for your training needs.
