if [ -z ${CONTEXT+x} ]; then
    kubectl="kubectl"
else
    kubectl="kubectl --context $CONTEXT"
fi

if [ -z ${NAMESPACES+x} ]; then 
    NAMESPACES=$(kubectl get namespaces | awk '{ print $1 }' | tail -n +2)
fi

if [ -z ${ACTIONS+x} ]; then
    ACTIONS="list get watch create update patch delete"
fi

ITER=0
for namespace in $NAMESPACES; do
  echo "Namespace: $namespace"
  for resource in $($kubectl api-resources --verbs=list --namespaced -o name); do
    if [ $((ITER % 20)) -eq 0 ]; then
        printf "\n%-50s" ""
        for action in $ACTIONS; do
          printf "%-10s" "$action"
        done
        printf "\n"
    fi
    printf "%-50s" "$resource"
    for action in $ACTIONS; do
      printf "%-10s" $($kubectl auth can-i "$action" "$resource" --namespace="$namespace")
    done
    printf "\n"
    ((ITER++))
  done
  printf "\n"
  ITER=0
done
