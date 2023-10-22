# azure-sql-mi-devops

---

| Page Type | Languages    | Key Services               | Tools                         |
| --------- | ------------ | -------------------------- | ----------------------------- |
| Sample    | SQL <br> HCL | Azure SQL Managed Instance | Terraform <br> GitHub Actions |

---

# Deploying an Azure SQL Managed Instance with Terraform and GitHub Actions

This sample codebase demonstrates how to deploy an Azure SQL Managed Instance with Terraform and GitHub Actions.
<br>
The motivation behind this guide is the observed lack of readily available open-source codebase examples using these technologies together.
<br>
The scenario presented in this codebase is simple and contrived - it is not intended for production use, and should be viewed as a foundation for modification and expansion into more complex applications.

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

#### GitHub Actions Secrets & Variables

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
  3.  `SQL_ADMIN_PASSWORD` - Password you want to use for the SQL Server. Note that the password must be at least 16 characters in length and contain uppercase, lowercase, and numeric characters, and non-numeric characters, and it cannot contain part of the admin username.

      Note: All other SQL MI variables are defined in `infra/terraform/modules/module-azure-sql-mi/variables.tf`

##### Variables:

- The following credentials are used to authenticate with the storage account that stores the remote Terraform state.

  1.  `TF_REGION` - Region of the Storage Account for managing Terraform state
  2.  `TF_RESOURCE_GROUP` - Name of the resource group containing the Storage Account
  3.  `TF_STORAGE_ACCOUNT` - Name of the Storage Account for managing Terraform state
  4.  `TF_CONTAINER_NAME` - Name of the Storage Account container for managing Terraform state
  5. `SQL_SERVER_NAME` - Name of the SQL Managed Instance
  6. `SQL_INITIAL_CATALOG` - Name of the database to be created on the SQL Managed Instance

#### GitHub Self-Hosted Runner

- A self-hosted runner is required because the agent must reside on the same virtual network as the SQL Managed Instance - you cannot deploy directly to a SQL Managed Instance from a GitHub-hosted runner.
- The self-hosted runner is required to run the `SQL-MI-CICD` GitHub Actions workflow. The runner can be hosted on a VM or container.
- For the purposes of this sample codebase, I have set up a self-hosted Windows VM runner by following the steps [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners). You may use more sophisticated infrastructure for your setup.
  - You should consider configuring the self-hosted runner application as a service to automatically start the runner application when the machine starts, which can be done by following the steps [here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=windows).
  - On this VM, you will need to set up the following tools:
    - [.NET 6.0](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) - add dotnet as a path variable
    - Add Nuget source: `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org`
    - [SqlPackage (dotnet package)](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver16#installation-cross-platform): `dotnet tool install -g microsoft.sqlpackage`
    - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

  - For testing, you may consider installing additional tools on the self-hosted runner like [Git](https://git-scm.com/downloads) and [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15).

- Running the self-hosted runner on the VM: Change directory to the directory containing the runner service, and start the service. For example:
  ```
  cd actions-runner
  .\run.cmd
  ```

### _*Deploying to the Cloud Infrastructure*_

1. Deploy the SQL Managed Instance with Terraform by running the `Terraform-Deploy-SQL-MI` GitHub Action. This action will take up to 30 minutes to run.
2. Once the SQL Managed Instance is deployed, you need to enable it to communicate with a self-hosted runner. You may do this either by creating a new runner in the newly created SQL MI virtual network, or by peering the SQL MI virtual network to an existing virtual network containing a self-hosted runner. A private endpoint needs to be created for the SQL MI and a virtual network link needs to be made to the self-hosted runner's virtual network.

   - To peer the virtual networks, follow the steps [here](https://docs.microsoft.com/en-us/azure/virtual-network/tutorial-connect-virtual-networks-portal) (Since both networks will already exist, you may begin at [this step](https://learn.microsoft.com/en-us/azure/virtual-network/tutorial-connect-virtual-networks-portal#create-virtual-network-peer), and you may skip the 'Create virtual machines' step). _The address space of your SQL MI may not overlap with the address space of your self-hosted runner's network_.

     Your peering may look something like this:
     ![Peering](./docs/images/peering.png)

  - From the VM, you can verify the connectivity over the peering by running the following PowerShell command: `Test-NetConnection -computer <private endpoint>.database.windows.net -port 1433`.
  - A script that can be run locally on the runner to test the connection and build/deploy steps prior to running the GitHub Action is in `etc/runner-build-test.ps1`.

3. After the virtual networks are peered, you may run the `SQL-MI-CICD` GitHub Action to deploy the sample database to the SQL Managed Instance.

## Architecture & Workflow

![Diagram](./docs/images/diagram.png)

## Potential Use Cases

- There are many use cases for Azure SQL Managed Instance; for example, you should consider using SQL Managed Instance when you need near 100% compatibility with the latest SQL Server database engine, want to lift and shift your applications to Azure Arc data services with minimal application and database changes, and maintain data sovereignty.

## Additional Resources

- [Azure SQLPackage GitHub Action](https://github.com/Azure/run-sqlpackage-action)
- [Spreading your SQL Server wings with Azure SQL Managed Instances - blog](https://www.kevinrchant.com/2023/05/06/spreading-your-sql-server-wings-with-azure-sql-managed-instances/)
- [Troubleshooting connection issues](https://www.techbrothersit.com/2021/09/connection-was-denied-since-deny-public.html?m=1)
