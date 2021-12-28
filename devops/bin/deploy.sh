#!/usr/bin/env bash

set -e
set -x

if [[ -z ${CLUSTER_REGION} ]] || [[ -z ${CLUSTER_NAME} ]]; then
    echo -e "\033[31mERROR\033[m: Expected CLUSTER_NAME and CLUSTER_REGION to be set!" >&2
    exit 1
fi


if [[ -z ${SERVER_IMAGE} ]] || [[ -z ${CLIENT_IMAGE} ]] || [[ -z ${WORKER_IMAGE} ]]; then
    echo -e "\033[31mERROR\033[m: Expected SERVER_IMAGE, CLIENT_IMAGE and WORKER_IMAGE to be set!" >&2
    exit 1
fi


source $(dirname "$0")/utils.sh

SHA=$SHA:-$(git rev-parse --short HEAD)

aws eks update-kubeconfig --region $CLUSTER_REGION --name $CLUSTER_NAME --kubeconfig kubeconfig
export KUBECONFIG=kubeconfig

msg.task 'Applying kubernetes configs'
kubectl apply -f ./devops/k8s/
msg.done


msg.task 'Updating kubernetes deployments'
kubectl set image deployments/server-deployment server=$SERVER_IMAGE
kubectl set image deployments/client-deployment client=$CLIENT_IMAGE
kubectl set image deployments/worker-deployment worker=$WORKER_IMAGE
msg.task 'Done'

kubectl get pods
echo "Deploy succeded"
