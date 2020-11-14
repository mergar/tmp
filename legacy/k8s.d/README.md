Accessing to dashboard:
#kubectl proxy
kubectl proxy --address='0.0.0.0' --accept-hosts='^*$'
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
kubectl get secrets $( kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}"  | base64 --decode

# Another way

kubectl apply -f https://raw.githubusercontent.com/alexandreroman/k8s-dashboard-loadbalancer/master/k8s-dashboard-loadbalancer.yml

CFG:
---
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-lb
  namespace: kube-system
spec:
  type: LoadBalancer
  ports:
    - port: 443
      protocol: TCP
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
