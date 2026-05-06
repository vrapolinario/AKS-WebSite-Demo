# ============================================================================
# AKS Demo Session Script
# Commands for demonstrating Docker and Kubernetes deployment
# Rename this file as session-script.ps1 and update placeholders before running
# ============================================================================

# ----------------------------------------------------------------------------
# SECTION 1: Local Docker Build and Test
# ----------------------------------------------------------------------------

# Navigate to the project directory
cd .\AksDemoWebsite

# Build the Docker image locally
# (Run from AksDemoWebsite directory, or use: docker build -t aksdemo:v1 -f AksDemoWebsite\dockerfile AksDemoWebsite)
docker build -t aksdemo:v1 -f dockerfile .

# List Docker images to verify the build
docker images

# Run the container locally on port 8080
docker run -d -p 8080:80 --name aksdemo-local -e SESSION_COUNT=400 aksdemo:v1

# Check running containers
docker ps -a

# Test the application locally
# Open browser to: http://localhost:8080
Start-Process "http://localhost:8080"

#Open Docker Desktop to verify the container is running and enter container

# Run additional container locally on port 8081
docker run -d -p 8081:80 --name aksdemo-local2 -e SESSION_COUNT=500 aksdemo:v1

# Test the application locally
# Open browser to: http://localhost:8081
Start-Process "http://localhost:8081"

# ----------------------------------------------------------------------------
# SECTION 2: Azure Container Registry (ACR)
# ----------------------------------------------------------------------------

# Set your ACR name (replace with your actual ACR name)
$ACR_NAME = "ACR_Name"  # Replace with your ACR name
$ACR_LOGIN_SERVER = "$ACR_NAME.azurecr.io"

# Login to Azure
$tenant_id="<your-tenant-id>"  # Replace with your tenant ID
az login --tenant $tenant_id

# Login to Azure Container Registry
az acr login --name $ACR_NAME

# Tag the image for ACR
docker tag aksdemo:v1 $ACR_LOGIN_SERVER/aksdemo:v1

# Push the image to ACR
docker push $ACR_LOGIN_SERVER/aksdemo:v1

# ----------------------------------------------------------------------------
# SECTION 3: Azure Kubernetes Service (AKS) Setup
# ----------------------------------------------------------------------------

# Set AKS cluster name and resource group
$RESOURCE_GROUP = "<your-resource-group>"  # Replace with your resource group
$AKS_CLUSTER_NAME = "<your-aks-cluster-name>"   # Replace with your AKS cluster name

# Get AKS credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME

# Verify kubectl connection
kubectl cluster-info
kubectl get nodes -o wide

# ----------------------------------------------------------------------------
# SECTION 4: Deploy to AKS with kubectl
# ----------------------------------------------------------------------------

# IMPORTANT: Update aks-demo.yaml with your ACR name before deploying
# Edit the file and replace <your-acr-name> with your actual ACR name

# Create the namespace
kubectl create namespace aks-demo

# Apply the deployment configuration
kubectl apply -f aks-demo.yaml

# ----------------------------------------------------------------------------
# SECTION 5: Update and Scale
# ----------------------------------------------------------------------------

# Update the ConfigMap

# Apply aks-demo.yaml to update the ConfigMap
kubectl apply -f aks-demo.yaml

# Restart pods to pick up ConfigMap changes
kubectl rollout restart deployment/aksdemo-deployment -n aks-demo

# Scale the deployment
kubectl scale deployment aksdemo-deployment -n aks-demo --replicas=2

# ----------------------------------------------------------------------------
# SECTION 6: Cleanup
# ----------------------------------------------------------------------------

# Delete the deployment and service
kubectl delete -f aks-demo.yaml

# Or delete the entire namespace
# kubectl delete namespace aks-demo

# Stop and remove local Docker container
# docker stop aksdemo-local
# docker rm aksdemo-local

# Remove local Docker image
# docker rmi aksdemo:v1
# docker rmi $ACR_LOGIN_SERVER/aksdemo:v1

# ============================================================================
# End of Session Script
# ============================================================================
