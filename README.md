# Cohere Take-Home

- terraform

  - single-node GKE cluster into a VPC
  - artifact registry as a container registry

- frontend

  - containerized next.js app to display the Cohere logo
  - also displays a paginated list of quotes from authors (dummy data)

- postgres

  - containerized postgres
  - hardcoded data in initdb scripts (see TODO.txt)
  - local development with docker compose

- k8s

  - uses kustomize to generate secrets from .env
  - statefulset for postgres
  - dynamically-provisioned PV from PVC https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes for postgres
  - deployment for frontend
  - single replica for everything
  - Google Cloud Application Load Balancer dynamically provisioned from Ingress kubernetes resource https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer

# Deploy

```sh
cd terraform
terraform apply

# Manually build and push images, then fix up image tags in manifests
# See TODO.txt about kbld

cd ../k8s
# Create a .env.secrets file from .env.secret.local
kubectl apply -k .

# Wait a bit and get ingress's external IP
kubectl get ingress ingress -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"
```
