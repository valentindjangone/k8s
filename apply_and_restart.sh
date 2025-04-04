#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Loading images into Minikube..."
minikube image load nginx-gateway:latest
minikube image load shell:latest
minikube image load auth-frontend:latest
echo "Images loaded."

echo "Applying Kubernetes configurations..."

# Apply Nginx Gateway configs
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml

# Apply Shell configs
kubectl apply -f k8s/shell-deployment.yaml
kubectl apply -f k8s/shell-service.yaml

# Apply Auth Frontend configs
kubectl apply -f k8s/auth-frontend-deployment.yaml
kubectl apply -f k8s/auth-frontend-service.yaml

# Apply secrets if the file exists
if [ -f "k8s/auth-frontend-secrets.yaml" ]; then
  echo "Applying secrets..."
  kubectl apply -f k8s/auth-frontend-secrets.yaml
else
  echo "Warning: k8s/auth-frontend-secrets.yaml not found, skipping secret application."
fi

echo "Configurations applied."
echo "Performing rollout restarts..."

# Rollout restart deployments (ensure correct namespaces)
kubectl rollout restart deployment nginx-gateway -n nginx
kubectl rollout restart deployment shell -n shell
kubectl rollout restart deployment auth-frontend -n auth

echo "Rollout restarts initiated."

echo "Waiting for deployments to stabilize (optional)..."
sleep 5 # Give pods a moment to start rolling out

# Fetch access information
echo "Fetching access URL..."
MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get service nginx-gateway -n nginx -o jsonpath='{.spec.ports[0].nodePort}')

if [ -z "$MINIKUBE_IP" ] || [ -z "$NODE_PORT" ]; then
  echo "Error: Could not retrieve Minikube IP or NodePort."
  # Optionally exit here, or just show the warning
  echo "Warning: Could not determine application access URL."
else
  echo "-----------------------------------------------------"
  echo "Application should be accessible at (via NodePort):"
  echo "http://$MINIKUBE_IP:$NODE_PORT"
  echo "-----------------------------------------------------"
  echo "Alternatively, use port-forwarding:
kubectl port-forward -n nginx service/nginx-gateway 8080:80
Then access via http://localhost:8080"
  echo "-----------------------------------------------------"
fi

echo "Done." 