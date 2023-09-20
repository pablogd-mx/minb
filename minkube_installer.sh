# Ask the user for the number of clusters to create
read -p "Enter the number of clusters to create: " num_clusters


# Create Minikube clusters with nginx ingress controller and local registry
for ((i=1; i<=num_clusters; i++)); do
  cluster_name="cluster$i"
  minikube start -p $cluster_name --driver=docker
  minikube addons enable ingress -p $cluster_name
  minikube addons enable registry -p $cluster_name
done

# Output cluster information
minikube status