# Lab 07 – ARM Templates & Bicep

## Objectives
- Deploy resources using an ARM JSON template
- Convert/author the same deployment in Bicep
- Use parameters, variables, outputs, and what-if deployments
- Deploy at resource group scope and understand deployment modes

## Prerequisites
- Azure CLI with Bicep: `az bicep install`

## Estimated time
40 minutes

---

## Part 1 – Resource group

> Important: This lab uses Azure CLI — ensure `az` is installed and authenticated to your Azure subscription before proceeding.

```bash
az group create --name rg-az104-lab07 --location eastus
```

## Part 2 – Author a Bicep template

> Tip: Save your Bicep file in a directory with no spaces in the path to avoid CLI parsing issues.

Create `main.bicep`:
```bicep
@description('Name prefix for resources')
param namePrefix string = 'az104lab07'

@allowed(['Standard_LRS', 'Standard_GRS'])
param storageSku string = 'Standard_LRS'

var storageAccountName = toLower('${namePrefix}${uniqueString(resourceGroup().id)}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: '${namePrefix}-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.20.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.20.0.0/24'
        }
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output vnetId string = vnet.id
```

## Part 3 – Preview with what-if

> Important: Always run `what-if` before deploying to production. It shows exactly what changes will occur without modifying any resources.

```bash
az deployment group what-if \
  --resource-group rg-az104-lab07 \
  --template-file main.bicep
```
Review the predicted **Create** operations before applying.

## Part 4 – Deploy

```bash
az deployment group create \
  --resource-group rg-az104-lab07 \
  --template-file main.bicep \
  --parameters storageSku=Standard_LRS \
  --name lab07-deployment

az deployment group show -g rg-az104-lab07 -n lab07-deployment --query properties.outputs
```

## Part 5 – Equivalent ARM JSON (for recognition on the exam)

Decompile to compare:
```bash
az bicep decompile --file main.json   # if you have JSON, converts to bicep
# or build bicep -> json:
az bicep build --file main.bicep      # produces main.json
```
Open `main.json` and identify: `$schema`, `contentVersion`, `parameters`,
`variables`, `resources`, `outputs` — map each to its Bicep equivalent.

## Part 6 – Deployment modes & redeploy

> Warning: **Complete** mode deletes resources NOT in your template. Never use it in production unless you fully understand the consequences.

Modify `storageSku` to `Standard_GRS` and redeploy with **Incremental** mode (default):
```bash
az deployment group create -g rg-az104-lab07 --template-file main.bicep \
  --parameters storageSku=Standard_GRS --mode Incremental
```
Discuss (no need to execute): **Complete** mode would delete resources in the
RG that are *not* in the template — dangerous, used carefully.

## Part 7 – Deployment history & troubleshooting

```bash
az deployment group list -g rg-az104-lab07 -o table
az deployment operation group list -g rg-az104-lab07 -n lab07-deployment -o table
```

## Validation
- [ ] Storage account and VNet deployed via Bicep
- [ ] `what-if` output reviewed before deploying
- [ ] Outputs (`storageAccountName`, `vnetId`) returned correctly
- [ ] Can explain Incremental vs Complete deployment modes

## Cleanup
```bash
az group delete --name rg-az104-lab07 --yes --no-wait
```

## Exam Tips
- Bicep compiles down to ARM JSON — anything you can do in JSON you can do in Bicep, with cleaner syntax.
- `what-if` shows Create/Modify/Delete/NoChange without applying changes — use it before production deployments.
- **Incremental** (default): adds/updates resources in template, leaves others untouched. **Complete**: removes resources in the RG not defined in the template — exam loves to test this distinction.
- `uniqueString()` is commonly used to generate globally-unique names deterministically from the resource group ID.
