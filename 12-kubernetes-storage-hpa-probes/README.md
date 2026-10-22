# Kubernetes Storage, HPA, and Probes

This module contains three hands-on Kubernetes labs completed on Minikube. The
manifests are intentionally small so that each result can be explained and
verified from the terminal.

## Prerequisites

```bash
minikube start
kubectl cluster-info
kubectl get nodes
```

Run all commands from this module's directory:

```bash
cd 12-kubernetes-storage-hpa-probes
```

## Lab 1: Prove that data survives Pod recreation

Manifest: [`01-persistent-storage/storage.yaml`](01-persistent-storage/storage.yaml)

The manifest creates a namespace, a dynamically provisioned
`PersistentVolumeClaim`, and a BusyBox Pod that mounts the claim at `/data`.

```bash
kubectl apply -f 01-persistent-storage/storage.yaml
kubectl wait -n storage-lab --for=condition=Ready pod/storage-demo --timeout=120s

kubectl get storageclass
kubectl get pvc,pod -n storage-lab
kubectl exec -n storage-lab storage-demo -- \
  sh -c 'printf "Created before Pod recreation\n" > /data/proof.txt && cat /data/proof.txt'
```

Take **Screenshot 1** now. It must show the default StorageClass, the PVC in
`Bound` state, the Pod in `Running` state, and the text written to
`/data/proof.txt`. Save it as `evidence/01-pvc-bound-and-file.jpg`.

Delete only the Pod, create it again from the same manifest, and read the file
from the unchanged claim:

```bash
OLD_UID=$(kubectl get pod storage-demo -n storage-lab -o jsonpath='{.metadata.uid}')
echo "Old Pod UID: $OLD_UID"
kubectl delete pod storage-demo -n storage-lab --wait=true
kubectl apply -f 01-persistent-storage/storage.yaml
kubectl wait -n storage-lab --for=condition=Ready pod/storage-demo --timeout=120s
NEW_UID=$(kubectl get pod storage-demo -n storage-lab -o jsonpath='{.metadata.uid}')
echo "New Pod UID: $NEW_UID"
kubectl exec -n storage-lab storage-demo -- cat /data/proof.txt
kubectl get pvc,pod -n storage-lab
```

Take **Screenshot 2** now. It must show two different Pod UIDs, the original
text, and the PVC still `Bound`. Save it as
`evidence/02-file-after-pod-recreation.jpg`.

The Pod is disposable, while the claim represents storage with a lifecycle
independent of that Pod. Reusing the claim mounts the same data into the new
Pod.

## Lab 2: Observe readiness and liveness behavior

Manifest: [`02-probes/probe-demo.yaml`](02-probes/probe-demo.yaml)

The Nginx container creates two health files when it starts. The readiness
probe checks `/ready`; the liveness probe checks `/healthz`.

```bash
kubectl apply -f 02-probes/probe-demo.yaml
kubectl rollout status deployment/probe-demo -n probes-lab --timeout=120s
kubectl get deployment,pods -n probes-lab -o wide
```

First, remove only the readiness file:

```bash
POD=$(kubectl get pod -n probes-lab -l app=probe-demo \
  -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n probes-lab "$POD" -- rm /usr/share/nginx/html/ready
sleep 6
kubectl get pod -n probes-lab "$POD"
kubectl describe pod -n probes-lab "$POD" | \
  sed -n '/Conditions:/,/Volumes:/p'
```

Take **Screenshot 3** now. It must show `READY 0/1`, while `STATUS` remains
`Running`, plus the failed readiness condition. Save it as
`evidence/03-readiness-failure.jpg`.

A failed readiness probe removes a Pod from Service endpoints but does not
restart its container. Restore readiness, then trigger a liveness failure:

```bash
kubectl exec -n probes-lab "$POD" -- \
  sh -c 'printf "ready\n" > /usr/share/nginx/html/ready'
kubectl wait -n probes-lab --for=condition=Ready pod/"$POD" --timeout=60s

BEFORE=$(kubectl get pod -n probes-lab "$POD" \
  -o jsonpath='{.status.containerStatuses[0].restartCount}')
kubectl exec -n probes-lab "$POD" -- rm /usr/share/nginx/html/healthz
sleep 15
AFTER=$(kubectl get pod -n probes-lab "$POD" \
  -o jsonpath='{.status.containerStatuses[0].restartCount}')
echo "Restart count before liveness failure: $BEFORE"
echo "Restart count after liveness failure:  $AFTER"
kubectl get pod -n probes-lab "$POD"
kubectl get events -n probes-lab --sort-by=.lastTimestamp | tail -8
```

Take **Screenshot 4** now. It must show a higher restart count and a liveness
probe failure/restart event. Save it as `evidence/04-liveness-restart.jpg`.

The same Pod object remains, but kubelet restarts its unhealthy container. The
container startup command recreates both health files, allowing it to recover.

## Lab 3: Scale a Deployment using CPU utilization

Manifests:

- [`03-hpa/application.yaml`](03-hpa/application.yaml)
- [`03-hpa/load-generator.yaml`](03-hpa/load-generator.yaml)

HPA requires CPU metrics. On Minikube, enable and verify `metrics-server`:

```bash
minikube addons enable metrics-server
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
kubectl top nodes
```

Deploy the application and wait for its first metric sample:

```bash
kubectl apply -f 03-hpa/application.yaml
kubectl rollout status deployment/php-apache -n autoscale-lab --timeout=180s
kubectl get deployment,service,hpa -n autoscale-lab
kubectl top pods -n autoscale-lab
```

Take **Screenshot 5** now. It must show one ready application replica, the HPA
target, and CPU metrics. Save it as `evidence/05-hpa-before-load.jpg`.

Generate traffic and watch the HPA. Metrics and scaling normally take one or
two minutes to appear:

```bash
kubectl apply -f 03-hpa/load-generator.yaml
kubectl wait -n autoscale-lab --for=condition=Ready pod/load-generator --timeout=120s
kubectl get hpa,pods -n autoscale-lab -w
```

When `REPLICAS` is greater than `1`, press **Control+C**, then run:

```bash
kubectl get hpa -n autoscale-lab
kubectl get deployment,pods -n autoscale-lab -o wide
kubectl top pods -n autoscale-lab
```

Take **Screenshot 6** now. It must show CPU above the target and more than one
application replica. Save it as `evidence/06-hpa-scaled-up.jpg`.

Stop the load and observe scale-down. The manifest shortens the scale-down
stabilization window to 60 seconds for this lab, but metric updates can still
take a few minutes.

```bash
kubectl delete -f 03-hpa/load-generator.yaml
kubectl get hpa,pods -n autoscale-lab -w
```

When the deployment returns to one replica, press **Control+C** and take
**Screenshot 7**. It must show the HPA and the single remaining application
Pod. Save it as `evidence/07-hpa-scaled-down.jpg`.

The Deployment defines a CPU request because HPA calculates utilization as a
percentage of the requested CPU. Under sustained load it increases replicas;
after demand disappears it reduces them within the configured bounds.

## Cleanup

```bash
kubectl delete namespace storage-lab probes-lab autoscale-lab
```

Deleting `storage-lab` also deletes its namespaced PVC. On Minikube's default
dynamic provisioner, the associated volume normally uses a `Delete` reclaim
policy and is removed as well.

## What I learned

- A PVC requests storage, while a PV represents the cluster storage resource
  bound to that request.
- Pod recreation does not remove data kept on an unchanged persistent volume.
- Readiness controls whether a Pod should receive traffic; liveness controls
  whether kubelet should restart its container.
- HPA needs resource requests and a working metrics pipeline to make CPU-based
  scaling decisions.
- Kubernetes scaling and health decisions are asynchronous, so verification
  should include both resource status and recent events.

## References

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Configure liveness, readiness and startup probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
