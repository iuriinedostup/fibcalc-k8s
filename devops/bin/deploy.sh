#!/usr/bin/env bash

set -e
set -x

if [[ -z ${CLUSTER_REGION} ]] || [[ -z ${CI_COMMIT_SHORT_SHA} ]] || [[ -z ${CLUSTER_NAME} ]]; then
    echo -e "\033[31mERROR\033[m: Expected CLUSTER_NAME and CLUSTER_REGION to be set!" >&2
    exit 1
fi


if [[ -z ${SEVER_IMAGE} ]] || [[ -z ${CLIENT_IMAGE} ]] || [[ -z ${WORKER_IMAGE} ]]; then
    echo -e "\033[31mERROR\033[m: Expected SEVER_IMAGE, CLIENT_IMAGE and WORKER_IMAGE to be set!" >&2
    exit 1
fi


source $(dirname "$0")/utils.sh

SHA=$SHA:-$(git rev-parse --short HEAD)

aws eks update-kubeconfig --region $CLUSTER_REGION --name $CLUSTER_NAME
export KUBECONFIG=kubeconfig

msg.task 'Applyting kubernetes configs'
kubectl apply -f ./devops/k8s/
msg.done


msg.task 'Updating kubernetes deployments'
kubectl set image deployments/server-deployment server=$SEVER_IMAGE
kubectl set image deployments/client-deployment client=$CLIENT_IMAGE
kubectl set image deployments/worker-deployment worker=$WORKER_IMAGE
msg.task 'Done'

kubectl get pods
echo "Deploy succeded"
