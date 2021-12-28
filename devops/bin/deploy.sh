#!/usr/bin/env bash

set -e

source $(dirname "$0")/utils.sh

SHA=$SHA:-$(git rev-parse --short HEAD)

aws eks update-kubeconfig --region $CLUSTER_REGION --name $CLUSTER_NAME
export KUBECONFIG=kubeconfig

msg.task 'Applyting kubernetes configs'
kubectl apply -f ./devops/k8s/
msg.done


msg.task 'Updating kubernetes deployments'
kubectl set image deployments/server-deployment server=iuriinedostup/fibcalc-k8s-server:$SHA
kubectl set image deployments/server-deployment server=iuriinedostup/fibcalc-k8s-client:$SHA
kubectl set image deployments/server-deployment server=iuriinedostup/fibcalc-k8s-worker:$SHA
msg.task 'Done'

kubectl get pods
echo "Deploy succeded"
