# azure-sql-mi-devops

---

| Page Type | Languages    | Key Services               | Tools                         |
| --------- | ------------ | -------------------------- | ----------------------------- |
| Sample    | SQL <br> HCL | Azure SQL Managed Instance | Terraform <br> GitHub Actions |

---

# Deploying an Azure SQL Managed Instance with Terraform and GitHub Actions

This sample codebase demonstrates how to...

## Prerequisites

- [An Azure Subscription](https://azure.microsoft.com/en-us/free/) - for hosting cloud infrastructure
- [A GitHub Account](https://github.com/join) - for deploying code via GitHub Actions

## Running this sample

### _*Setting Up the Cloud Infrastructure and Repository*_

#### App Registration

- [Register a new application](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Create a new client secret](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret)

#### Storage Account for Managing Remote Terraform State

- [Azure Storage will be used for storing Terraform state](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli). In the Azure Portal, create a common resource group, and then create a storage account within it ([doc](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal)).
- After the Storage Account is created, create a container within it to store the Terraform state files ([doc](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container)).

#### GitHub Actions Secrets & Variables (for automated deployments)

- To deploy to Azure using GitHub Actions, a handful of credentials are required for connection and configuration.

##### Secrets:

- The following credential is used to authenticate to Azure.

1.  `AZURE_SP_CREDENTIALS`:

    - A JSON object that looks like the following will need to be populated with 4 values:

    ```
    {
       "clientId": "<GUID>",
       "clientSecret": "<STRING>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>"
    }
    ```

    - You can find more details on creating this secret [here](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret).
    - For clientId, run: `az ad sp list --display-name <service principal name> --query '[].[appId][]' --out tsv`
    - For tenantId, run: `az ad sp show --id <clientID> --query 'appOwnerOrganizationId' --out tsv`
    - For subscriptionId, run: `az account show --query id --output tsv`
    - For clientSecret: This is the client secret created alongside the App Registration above

- The following credentials are used to set up the Azure SQL Managed Instance.

2.  `SQL_ADMIN_USER` - Username you want to use for the SQL Server
3.  `SQL_ADMIN_PASSWORD` - Password you want to use for the SQL Server

    Note: All other SQL MI variables are defined in `infra/terraform/modules/module-azure-sql-mi/variables.tf`

##### Variables:

- The following credentials are used to authenticate with the storage account that stores the remote Terraform state.

1.  `TF_REGION` - Region of the Storage Account for managing Terraform state
2.  `TF_RESOURCE_GROUP` - Name of the resource group containing the Storage Account
3.  `TF_STORAGE_ACCOUNT` - Name of the Storage Account for managing Terraform state
4.  `TF_CONTAINER_NAME` - Name of the Storage Account container for managing Terraform state

### _*Deploying to the Cloud Infrastructure*_

TODO

## Architecture & Workflow

TODO

## Potential Use Cases

TODO

## Additional Resources

- [Azure SQLPackage GitHub Action](https://github.com/Azure/run-sqlpackage-action)
