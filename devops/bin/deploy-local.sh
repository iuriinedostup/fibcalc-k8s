#!/usr/bin/env bash

set -e

source $(dirname "$0")/utils.sh

SHA=$SHA:-$(git rev-parse --short HEAD)

msg.task 'Buidling docker images'
docker build -t iuriinedostup/multi-client:latest -t iuriinedostup/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t iuriinedostup/multi-server:latest -t iuriinedostup/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t iuriinedostup/multi-worker:latest -t iuriinedostup/multi-worker:$SHA -f ./worker/Dockerfile ./worker
msg.done

msg.task 'Pushing docker images'
docker push iuriinedostup/multi-client:latest
docker push iuriinedostup/multi-server:latest
docker push iuriinedostup/multi-worker:latest
docker push iuriinedostup/multi-client:$SHA
docker push iuriinedostup/multi-server:$SHA
docker push iuriinedostup/multi-worker:$SHA
msg.done

aws eks update-kubeconfig --region $CLUSTER_REGION --name $CLUSTER_NAME
export KUBECONFIG=kubeconfig

msg.task 'Applyting kubernetes configs'
kubectl apply -f ./devops/k8s/
msg.done


msg.task 'Updating kubernetes deployments'
kubectl set image deployments/server-deployment server=iuriinedostup/multi-server:$SHA
kubectl set image deployments/server-deployment server=iuriinedostup/multi-client:$SHA
kubectl set image deployments/server-deployment server=iuriinedostup/multi-worker:$SHA
msg.task 'Done'

kubectl get pods
echo "Deploy succeded"

