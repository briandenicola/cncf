# Overview

This repository is a demonstration of KubeVela in Azure on AKS. It is currently a work in progress

* [KubeVela](https://kubevela.io/docs/) is a modern software delivery control plane that strides to make deploying and operating applications across today's multi-cloud environments easier, faster and more reliable.  
* [Crossplane with Kubevela](https://kubevela.io/docs/platform-engineers/crossplane/)

---

# Prerequisites 
* Azure Subscription
* [Azure Cli](https://github.com/briandenicola/tooling/blob/main/azure-cli.sh)
* [Terraform](https://github.com/briandenicola/tooling/blob/main/terraform.sh)
* [Task](https://github.com/briandenicola/tooling/blob/main/task.sh)
* [Vela Cli](https://github.com/briandenicola/tooling/blob/main/kubevela.sh)

# Quicksteps
```bash
    az login --scope https://graph.microsoft.com/.default
    task up
```

# Sample KubeVela Commands and Configurations
``` bash
    # Add Addons to Deployment
    vela addon registry add experimental --type=helm --endpoint=https://addons.kubevela.net/experimental/
    vela addon enable fluxcd
    vela addon enable helm
    vela addon enable vela-workflow
    #vela addon enable terraform-azure
    #vela addon enable crossplane

    # UI 
    vela addon enable velaux
    vela port-forward addon-velaux -n vela-system

    # Add additional clusters
    vela cluster join <your kubeconfig path>
    vela cluster list

    # Deploy applications 
    vela env init prod --namespace prod
    vela up -f https://kubevela.net/example/applications/first-app.yaml
    vela status first-vela-app
    vela port-forward first-vela-app 8000:8000
    vela workflow resume first-vela-app
```

# Additional References
## Kubevela
* https://kubevela.io/docs/platform-engineers/traits/customize-trait/
* https://kubevela.io/docs/getting-started/core-concept
* https://github.com/kubevela/terraform-controller
## Other
* https://gist.github.com/vfarcic/6d40ff0847a41f1d1607f4df73cd5bad
* https://open-cluster-management.io/
* https://cuelang.org/
* https://www.youtube.com/watch?v=Ii-lpLuzPxw

# Backlog
- [ ] Learn KubeVela