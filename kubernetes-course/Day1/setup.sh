#!/bin/bash

# Kubernetes Day 1 Setup Script
# This script configures kubectl to connect to your Kubernetes cluster

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default cluster IP
CLUSTER_IP="${1:-10.128.0.2}"
CLUSTER_PORT="${2:-6443}"
CONTEXT_NAME="day1-cluster"

echo -e "${BLUE}=== Kubernetes Day 1 Setup ===${NC}"
echo -e "${BLUE}Cluster IP: ${CLUSTER_IP}${NC}"
echo -e "${BLUE}Cluster Port: ${CLUSTER_PORT}${NC}"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed!${NC}"
    echo "Please install kubectl first: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo -e "${GREEN}✓ kubectl found${NC}"

# Check current kubeconfig
if [ -z "$KUBECONFIG" ]; then
    KUBECONFIG="$HOME/.kube/config"
fi

echo -e "${YELLOW}Using kubeconfig: $KUBECONFIG${NC}"

# Add cluster configuration
echo -e "${BLUE}Configuring cluster...${NC}"
kubectl config set-cluster "$CONTEXT_NAME" \
    --server="https://${CLUSTER_IP}:${CLUSTER_PORT}" \
    --insecure-skip-tls-verify=true \
    2>/dev/null || true

# Set context
kubectl config set-context "$CONTEXT_NAME" \
    --cluster="$CONTEXT_NAME" \
    --user="$CONTEXT_NAME" \
    2>/dev/null || true

# Set credentials (basic auth - modify as needed)
kubectl config set-credentials "$CONTEXT_NAME" \
    --username=admin \
    --password=admin \
    2>/dev/null || true

# Use the context
kubectl config use-context "$CONTEXT_NAME"
echo -e "${GREEN}✓ Context configured${NC}"

# Verify cluster connectivity
echo -e "${BLUE}Verifying cluster connectivity...${NC}"

if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓ Successfully connected to cluster${NC}"
else
    echo -e "${YELLOW}⚠ Could not verify cluster. Checking details...${NC}"
fi

# Get cluster information
echo -e "${BLUE}\n--- Cluster Information ---${NC}"
if kubectl version --short 2>/dev/null; then
    echo -e "${GREEN}✓ Cluster is accessible${NC}"
else
    echo -e "${YELLOW}⚠ Cluster version check: Please verify cluster is running${NC}"
fi

# List nodes
echo -e "${BLUE}\n--- Nodes in Cluster ---${NC}"
if kubectl get nodes &> /dev/null; then
    kubectl get nodes -o wide
    echo -e "${GREEN}✓ Nodes retrieved successfully${NC}"
else
    echo -e "${YELLOW}⚠ Could not retrieve nodes. Cluster might not be ready.${NC}"
fi

# List namespaces
echo -e "${BLUE}\n--- Available Namespaces ---${NC}"
if kubectl get namespaces &> /dev/null; then
    kubectl get namespaces
    echo -e "${GREEN}✓ Namespaces retrieved successfully${NC}"
else
    echo -e "${YELLOW}⚠ Could not retrieve namespaces${NC}"
fi

# Summary
echo -e "${BLUE}\n=== Setup Summary ===${NC}"
echo -e "${GREEN}Context Name: $CONTEXT_NAME${NC}"
echo -e "${GREEN}Current Context: $(kubectl config current-context)${NC}"
echo -e "${BLUE}Kubeconfig Location: $KUBECONFIG${NC}"

echo -e "${BLUE}\n=== Quick Test Commands ===${NC}"
echo "Test cluster connectivity:"
echo "  kubectl cluster-info"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"

echo -e "\n${GREEN}Setup complete! You're ready to start Day 1 labs.${NC}"
