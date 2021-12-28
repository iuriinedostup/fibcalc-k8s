#!/usr/bin/env bash

set -e

source $(dirname "$0")/utils.sh

SHA=$SHA:-$(git rev-parse --short HEAD)

msg.task 'Buidling docker images'
docker build -t iuriinedostup/fibcalc-k8s-client:latest -t iuriinedostup/fibcalc-k8s-client:$SHA -f ./client/Dockerfile ./client
docker build -t iuriinedostup/fibcalc-k8s-server:latest -t iuriinedostup/fibcalc-k8s-server:$SHA -f ./server/Dockerfile ./server
docker build -t iuriinedostup/fibcalc-k8s-worker:latest -t iuriinedostup/fibcalc-k8s-worker:$SHA -f ./worker/Dockerfile ./worker
msg.done

msg.task 'Pushing docker images'
docker push iuriinedostup/fibcalc-k8s-client:latest
docker push iuriinedostup/fibcalc-k8s-server:latest
docker push iuriinedostup/fibcalc-k8s-worker:latest
docker push iuriinedostup/fibcalc-k8s-client:$SHA
docker push iuriinedostup/fibcalc-k8s-server:$SHA
docker push iuriinedostup/fibcalc-k8s-worker:$SHA
msg.done

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

