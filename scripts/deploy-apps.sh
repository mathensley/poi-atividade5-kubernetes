#!/usr/bin/env bash
set -euo pipefail
# Executar na VM com o contexto minikube.
cd "$(dirname "$0")/.."
if [[ $(kubectl config current-context) != minikube ]]; then
  echo 'O contexto Kubernetes precisa ser minikube.' >&2
  exit 1
fi
kubectl apply --dry-run=server -f k8s/
kubectl apply -f k8s/
for app in cpu memory io; do
  kubectl rollout status "deployment/poi-$app" --timeout=300s
done
kubectl get deployments
kubectl get pods -o wide
kubectl get services
kubectl get endpointslices