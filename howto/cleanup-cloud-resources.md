(howto-cleanup-cloud-resources)=
# How to clean up cloud resources

This guide demonstrates how to clean up {ref}`a previously initialized cloud environment <howto-initialize-cloud-environment>`
and a deployed Charmed HPC cluster. This includes clean-up of both the machine cloud and the Kubernetes (K8s) cloud. All compute plane and
control plane applications hosted on these clouds will be destroyed.

:::{warning}
Clean-up may result in **permanent data loss**. Ensure all data you wish to preserve has been migrated to a safe location before proceeding.

Always clean up public cloud resources that are no longer necessary! Abandoned resources are tricky to detect and can become expensive over time.
:::

:::::{tab-set}

::::{tab-item} Microsoft Azure & AKS
:sync: azure

To clean up Microsoft Azure and Azure Kubernetes Service (AKS) resources, it is assumed you have:

* Bootstrapped a Juju controller on Azure
* Added AKS to the controller
* [Signed into the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively)

### Clean up Azure resources

List all controllers that have been registered to the local client with:

:::{code-block} shell
juju controllers
:::

To destroy the Juju controller and remove the Azure instance:

:::{code-block} shell
juju destroy-controller <controller name> --destroy-all-models --destroy-storage --force
:::

List current AKS instances with:

:::{code-block} shell
az aks list
:::

This will give JSON-formatted output representing the current AKS instances. Look for the values of `"name"` and `"resourceGroup"` in the output:

:::{code-block} shell
[
  {
    "aadProfile": null,
    [...]
    "name": "charmed-aks-cluster",
    [...]
    "resourceGroup": "aks",
    [...]
    },
  }
]
:::

Here `charmed-aks-cluster` and `aks`. Now delete both the instance and its resource group with the following commands (substituting in your AKS instance name for `charmed-aks-cluster` and your resource group for `aks`):

:::{code-block} shell
az aks delete -n charmed-aks-cluster -g aks
az group delete -n aks
:::

Destroying the controller or AKS instance may take a long time depending on the complexity of the deployment. Should the destroy process exceed 15 minutes or otherwise be seemingly stuck, you can proceed to delete resources manually [via the Azure web portal](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resources-portal) or [via the `az` CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resources-cli). To list any remaining Azure resources, use:

:::{code-block} shell
az resource list
:::

This command will return `[]` if no Azure resources remain. If there are `charmed-hpc` resources showing, repeat the above steps. If not, proceed to the steps for cleaning up your credentials below.

### Clean up credentials

List your Juju credentials with:

:::{terminal}
:input: juju credentials

Client Credentials:
Cloud        Credentials
azure        <your credential name>
:::

Remove Azure CLI credentials from Juju:

:::{code-block} shell
juju remove-credential azure <your credential name>
:::

After deleting the credential, the interactive process may not clean up its Azure role resource and assignment. Check the full list of role definitions with:

:::{code-block} shell
az role definition list
:::

Look for role definitions with `"roleType": "CustomRole"`. If a custom `<Azure role definition name>` was not specified when initially adding the credential, the `"roleName"` will be similar to `"Juju Role Definition"` or `"juju-controller-role"`, followed by an ID, otherwise it will be the custom name provided. These definitions should be removed if Juju is no longer in use.

To remove a role definition, first its assignments must be removed. To check whether a role assignment is bound to `<Azure role definition name>` run:

:::{code-block} shell
az role assignment list --role <Azure role definition name>
:::

The assignment and then the definition itself can be removed with:

:::{code-block} shell
az role assignment delete --role <Azure role definition name>
az role definition delete --name <Azure role definition name>
:::

To finish cleaning up, log out from Azure CLI:

:::{code-block} shell
az logout
:::

::::
