#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

CLUSTER_NAME="todo-lab"

# 1. Create kind cluster if needed
if ! kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config cluster.yml
fi

kubectl config use-context "kind-$CLUSTER_NAME"

# 2. Create namespaces
kubectl create namespace mysql \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace todoapp \
  --dry-run=client -o yaml | kubectl apply -f -

# 3. Read required credentials
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${DJANGO_SECRET_KEY:?DJANGO_SECRET_KEY is required}"

MYSQL_USER="${MYSQL_USER:-todoapp}"

# 4. Create MySQL Secret
kubectl create secret generic mysql-secret \
  --namespace=mysql \
  --from-literal=MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  --from-literal=MYSQL_USER="$MYSQL_USER" \
  --from-literal=MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

# 5. Create Django application Secret
kubectl create secret generic app-secret \
  --namespace=todoapp \
  --from-literal=SECRET_KEY="$DJANGO_SECRET_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

# 6. Create Django database connection Secret
kubectl create secret generic app-db-secret \
  --namespace=todoapp \
  --from-literal=NAME="todoapp" \
  --from-literal=USER="$MYSQL_USER" \
  --from-literal=PASSWORD="$MYSQL_PASSWORD" \
  --from-literal=HOST="mysql-0.mysql.mysql.svc.cluster.local" \
  --dry-run=client -o yaml | kubectl apply -f -

# 7. Create ConfigMap with init.sql
kubectl create configmap mysql-init \
  --namespace=mysql \
  --from-file=init.sql=.infrastructure/init.sql \
  --dry-run=client -o yaml | kubectl apply -f -

# 8. Deploy MySQL headless Service
kubectl apply -f .infrastructure/mysqlService.yml

# 9. Deploy MySQL StatefulSet
kubectl apply -f .infrastructure/statefulSet.yml

# 10. Deploy Django ConfigMap
kubectl apply -f .infrastructure/configMap.yml


# 11. Deploy Django
kubectl apply -f .infrastructure/deployment.yml

# 12. Display final status
kubectl get nodes
kubectl get statefulsets -n mysql
kubectl get pods -n mysql
kubectl get pvc -n mysql
kubectl get pods -n todoapp
