#!/bin/bash
echo "Sysdig Agent/Clustershield Manual Delete"
echo "-----------------------------------------"

read -p "Enter namespace name where sysdig is installed: " namespace

# Run the kubectl command to get the list of resources matching "sysdig"
resources=$(kubectl get configmaps,secrets,deployments,pods,services,replicasets,daemonsets,ingresses,statefulsets,validatingwebhookconfigurations,mutatingwebhookconfigurations,customresourcedefinitions,clusterrole,clusterrolebinding,role,rolebindings,serviceaccount --all-namespaces -o name | grep sysdig)

# Check if any resources were found
if [ -z "$resources" ]; then
  echo "No resources matching 'sysdig' found."
  exit 0
fi

# Loop through each resource and parse its type, name, and namespace
IFS=$'\n' # Set internal field separator to newline so we can loop over each line correctly
for resource in $resources; do
  # Extract the resource kind and name
  kind=$(echo "$resource" | cut -d'/' -f1)
  name=$(echo "$resource" | cut -d'/' -f2)

  # Prompt the user to confirm if they want to echo the command
  read -p "Do you want to delete $kind/$name? (Y/N): " response

  # If the user enters Y (yes), echo the kubectl delete command
  if [[ "$response" == "Y" || "$response" == "y" ]]; then
    kubectl delete $kind $name -n $namespace
    echo 
  else
    echo "Skipping $kind/$name"
    echo
  fi

done
