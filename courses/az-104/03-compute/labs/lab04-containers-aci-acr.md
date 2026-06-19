# Lab 10 – Containers: Azure Container Registry & Container Instances

## Objectives
- Create an Azure Container Registry (ACR) and build/push an image
- Run a container with Azure Container Instances (ACI), pulling from ACR
- Configure ACI restart policies, environment variables, and Azure File volume mounts
- (Overview) Compare ACI/ACR with AKS for the exam

## Prerequisites
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
35 minutes

---

## Part 1 – Resource group and ACR

> Important: ACR registry names are globally unique across all Azure customers. If your first choice is taken, you'll need to add numbers/letters to make it unique.

1. Search for **Resource groups** > **Create**. Name: `rg-az104-lab10`,
   region: `East US`. **Review + create** > **Create**.
2. Search for **Container registries** > **Create**.
3. **Basics** tab:
   - **Resource group**: `rg-az104-lab10`
   - **Registry name**: `acraz104lab<unique>` (lowercase, globally unique)
   - **Location**: `East US`
   - **SKU**: **Basic**
   - **Admin user**: **Enable** (for ease of access in this lab)
4. **Review + create** > **Create**.

## Part 2 – Build and push an image using the Portal

1. Go to **acraz104lab<unique>** > **Tasks** (under **Services**) > **+ New task**.
   (Alternative: **Repositories** > **Tasks** > **+**.)
2. Or use the simpler **Build** option: **Tasks** > **Quick task**:
   - Provide your **Dockerfile** (inline or upload):
     ```dockerfile
     FROM nginx:alpine
     RUN echo "<h1>Hello from AZ-104 Lab 10</h1>" > /usr/share/nginx/html/index.html
     ```
   - **Image name**: `demo-app:v1`
   - **Build** (runs the image build in ACR)
3. Alternatively, **Repositories** > **Import image** if you have a source
   image URI.

### Verify the image
1. Go to **acraz104lab<unique>** > **Repositories** — confirm `demo-app` appears.
2. Select `demo-app` > confirm the tag `v1` is listed.

## Part 3 – Run the image with Azure Container Instances

1. Search for **Container instances** > **Create**.
2. **Basics** tab:
   - **Resource group**: `rg-az104-lab10`
   - **Container name**: `aci-demo`
   - **Region**: `East US`
   - **Image source**: **Azure Container Registry**
   - **Registry**: select `acraz104lab<unique>`
   - **Image**: select `demo-app`
   - **Tag**: select `v1`
   - **Image OS type**: **Linux**
   - **CPU**: 1
   - **Memory (GB)**: 1
3. **Networking** tab: **DNS name label**: `aci-demo-<unique>` (optional, for
   public DNS). **Ports**: 80.
4. **Advanced** tab: **Restart policy**: **OnFailure**.
5. **Review + create** > **Create**.

### Access the container
1. Go to **aci-demo** > **Overview** > copy the **FQDN** (e.g.,
   `aci-demo-<unique>.eastus.azurecontainers.io`).
2. Open `http://<fqdn>:80` in a browser — should show "Hello from AZ-104 Lab 10".

## Part 4 – Environment variables & secure variables

> Important: Always mark sensitive data (API keys, passwords, tokens) as **Secure** so they're masked in logs and Portal UI, preventing accidental exposure.

1. **Container instances** > **Create** again for `aci-env-demo`.
2. **Basics** tab: use a public image `mcr.microsoft.com/azuredocs/aci-helloworld`,
   CPU: 0.5, Memory: 0.5 GB.
3. **Advanced** tab: **Environment variables**:
   - **Name**: `APP_ENV`, **Value**: `lab`, **Secure**: unchecked
4. Repeat: **Name**: `API_KEY`, **Value**: `supersecret123`, **Secure**: checked
5. **Networking** tab: **Ports**: 80. **Review + create** > **Create**.
6. The secure variable is masked in logs/Portal display; the container can read
   it via environment variable.

## Part 5 – Mount an Azure file share into a container

1. (Prerequisite: have a file share from Lab 06, or create a new storage account
   and file share.)
   - Search for **Storage accounts** > **Create**, name `stoaz104lab10<unique>`.
   - Open it > **File shares** > **+ File share**, name `acishare`, quota 1 GiB.

2. Get the storage account key: storage account > **Access keys** > copy **Key 1**.

3. **Container instances** > **Create** for `aci-volume-demo`.
4. **Basics** tab: image `mcr.microsoft.com/azuredocs/aci-helloworld`,
   CPU: 0.5, Memory: 0.5 GB.
5. **Advanced** tab: **Volumes**:
   - **Volume name**: `azure-file-volume`
   - **Mount path**: `/mnt/azfiles`
   - **Storage account name**: `stoaz104lab10<unique>`
   - **Storage account key**: (paste from Access keys)
   - **File share name**: `acishare`
6. **Networking** tab: **Ports**: 80. **Review + create** > **Create**.
7. The container now has the file share mounted inside at `/mnt/azfiles`.

## Part 6 – Container groups (multi-container, conceptual)

Review (no need to deploy): a **container group** (via YAML/ARM) lets multiple
containers share a lifecycle, network namespace (localhost), and storage
volumes — e.g., an app container + a logging sidecar.

This is typically set up via **JSON/YAML** upload in the Portal's **Create**
flow, or via Templates, but is beyond the scope of this lab.

## Validation
- [ ] ACR created, image `demo-app:v1` built and pushed
- [ ] ACI `aci-demo` pulls the image from ACR and serves on port 80
- [ ] A container runs with both plain and secure environment variables
      (**aci-env-demo** > **Overview** shows the container state)
- [ ] A container has an Azure file share mounted (check container logs or
      exec into it if needed)

## Cleanup
1. **Resource groups** > select `rg-az104-lab10` > **Delete resource group**.
   (This removes ACR, ACI containers, and related resources.)

## Exam Tips
- ACR SKUs: **Basic / Standard / Premium** — Premium adds geo-replication, content trust, private endpoints.
- ACI is for simple, single-container or small container-group workloads with no orchestration — billed per second by vCPU/memory.
- For orchestration, scaling, and multi-node workloads, AKS is the answer — AZ-104 expects awareness of AKS basics (it's primarily AZ-104's *compute* domain covers ACI/ACR/App Service/VMs; AKS deep-dive is more AZ-400/AZ-305, but know what it is).
- The Portal's **Quick task** in ACR is a fast way to build images without local Docker — useful when Docker isn't available.
