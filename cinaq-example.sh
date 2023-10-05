existing_cluster="$(kind get clusters | grep "${LOW_OPS_ENV}-foundation" || true)"
if [ "$existing_cluster" != "" ]; then
    echo "foundation cluster already exists"
else
    echo "foundation cluster not found"
    kind create cluster --name "${LOW_OPS_ENV}-foundation" --config installer/kind-config.yaml \
        --image "kindest/node:${KIND_CLUSTER_VERSION}" -v 1
fi

docker ps

kubectl config set-context "kind-${LOW_OPS_ENV}-foundation"

if which ip ; then
    API_SERVER_IP="$(ip a | grep inet | tail -n1 | awk '{print $2}' | sed -e 's|/[0-9]*||g')"
else
    API_SERVER_IP="172.17.0.2"
fi
echo ">>> API_SERVER_IP: $API_SERVER_IP"

docker network list
docker network inspect kind

if [ "$LOW_OPS_ENV" = "ci" ]; then
    apk add python3
    API_SERVER="kubernetes"
    echo "$API_SERVER_IP $API_SERVER" >> /etc/hosts
    sed -i "s|0.0.0.0|$API_SERVER|g" ~/.kube/config
fi

kubectl cluster-info 
kubectl get nodes
kubectl get pods -A
kubectl get jobs -A

# basic load balancer service
helm repo add "bitnami" "https://charts.bitnami.com/bitnami"
helm repo update
NETWORK=$(docker network inspect -f '{{.IPAM.Config}}' kind | awk '{print $1}' | sed 's|/16||g' | sed 's/[^0-9.]//g')
if [ "$NETWORK" != "172.19.0.0" ]; then
    echo "ERROR: Kind network is not good. Found $NETWORK but expected 172.19.0.0"
    exit 1
fi
START_NETWORK=${NETWORK//0.0/255.200}
END_NETWORK=${NETWORK//0.0/255.250}
helm upgrade -i -n metallb --create-namespace metallb bitnami/metallb \
    --version 3.0.12 \
    --set "configInline.address-pools[0].name=default" \
    --set "configInline.address-pools[0].protocol=layer2" \
    --set "configInline.address-pools[0].addresses[0]=${START_NETWORK}-${END_NETWORK}" \
    --set "speaker.secretValue=stronk-key"

# that is how we set up the kind and metallb
# pool address has to be in the same range as docker network
# then just nginx-ingress, cert-manager, harbor via helm
# to expose to external ip using hpello-proxy as above





# 2:22
# harbor-ingress          nginx   harbor.low-ops.com                  172.19.255.200   80, 443   42d
# domain based routing for ingresses