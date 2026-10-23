kubectl get statefulset mysql -n mysql
kubectl get pods -n mysql

Validate MySQL Secret

kubectl get secret mysql-secret -n mysql
kubectl describe statefulset mysql -n mysql

Validate MySQL Probes

kubectl describe pod mysql-0 -n mysql

Validate Resources

kubectl describe statefulset mysql -n mysql

Validate Init SQL

Verify the mounted SQL file:

kubectl exec -n mysql mysql-0 -- ls /docker-entrypoint-initdb.d

Validate PersistentVolumeClaims

kubectl get pvc -n mysql

Each PVC should have status Bound.

Validate Headless Service

kubectl get svc mysql -n mysql

Validate Django Deployment

kubectl get pods -n todoapp
kubectl rollout status deployment/todoapp -n todoapp

Verify the database connection Secret:

kubectl get secret app-db-secret -n todoapp

Verify environment variable references:

kubectl describe deployment todoapp -n todoapp
