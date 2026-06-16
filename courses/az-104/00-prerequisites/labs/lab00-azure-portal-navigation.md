# Lab 00 – Azure Portal Navigation: Hands-On Exploration

## Real-Life Scenario

**Company: Contoso Ltd**

You are a new Azure administrator at Contoso, a mid-sized financial services company. Your manager has just given you your first task: "We're moving our on-premises applications to Azure. Before we start building, I need you to get familiar with the Azure Portal. Understand how to organize our resources, find Azure services, and manage costs. Here are the credentials for our dev subscription."

Your mission in this lab is to **become comfortable navigating the Azure Portal** so you can confidently help the team set up infrastructure in coming labs.

---

## Objectives

- Create a Resource Group (the logical container for all lab resources)
- Navigate the Azure Portal using search, favorites, and the menu
- Understand subscriptions, scopes, and resource organization
- Explore Azure services by category
- Use the Cloud Shell and portal help features
- Apply resource tagging for cost tracking
- Understand the relationship between Resource Groups and resources

## Prerequisites

- An Azure subscription (free trial, MSDN, or pay-as-you-go)
- Signed in to [portal.azure.com](https://portal.azure.com)
- Modern web browser (Chrome, Edge, Firefox, Safari)

## Estimated Time

45-60 minutes

---

## Part 1 – Create a Resource Group

A **Resource Group** is a logical container that holds related Azure resources. Nearly every lab in this course starts by creating one. In this case, we'll create `rg-az104-lab00` to hold our lab resources.

### Step 1: Start Creating a Resource Group

1. Go to [portal.azure.com](https://portal.azure.com).
2. In the **Search bar** (at the top of every page), type `resource groups`.
3. Select **Resource groups** from the dropdown results.
4. Click **+ Create**.

### Step 2: Fill in the Basics

1. **Subscription**: select your subscription (e.g., "Azure subscription 1").
2. **Resource group name**: `rg-az104-lab00`
3. **Region**: `East US` (or your preferred region — this is where the RG metadata is stored).
4. Click **Review + create**.

### Step 3: Review and Create

1. Confirm the settings look correct.
2. Click **Create**.
3. You'll see a notification: "Deployment is in progress" → "Your deployment is complete."

**Verification:** Go to **Home** > **Resource groups** (or search for Resource groups again). You should see `rg-az104-lab00` listed with status "Succeeded".

---

## Part 2 – Explore the Azure Portal Layout

Now that we have a Resource Group, let's explore the portal's key features.

### The Portal Home Page

1. Click **Home** in the left sidebar (or the **AZ-104 Learning Hub** logo at the top).
2. Observe:
   - **Favorites** section (top left) — add services here for quick access
   - **Create a resource** button
   - **Recently accessed resources**
   - **Resource groups** card

### The Search Bar (Your Most Powerful Tool)

The **Search bar** (at the very top) is the fastest way to get anywhere in the Azure Portal.

1. Click the search bar and type `virtual machines`.
2. See the dropdown with:
   - **Virtual machines** (the service)
   - Suggestions for related content
3. Don't click — just observe. The search bar knows about services, resources, documentation, and settings.

**Key tip for exams and labs:** Every lab instruction that says "Go to **\<service name\>**" means "use the Search bar to find that service."

### Adding to Favorites

1. Search for `virtual machines` and select it from the dropdown.
2. You're now on the **Virtual machines** page. On the left sidebar, find the **Virtual machines** menu item.
3. **Hover over it** and click the **star icon** to add it to Favorites.
4. Go **Home**. You should now see **Virtual machines** in your Favorites section at the top.

**Why Favorites?** Frequently-used services appear in the left sidebar without having to search.

---

## Part 3 – Understand Subscriptions and Scopes

**Scope** is a foundational concept in Azure. Resources exist within a hierarchy:

```
Tenant (your organization)
  ↓
Management Group (optional, for large organizations)
  ↓
Subscription (billing boundary, the main organizing unit)
  ↓
Resource Group (logical container for related resources)
  ↓
Resource (VMs, storage accounts, databases, etc.)
```

### View Your Subscription

1. Search for `subscriptions`.
2. Click **Subscriptions** from the results.
3. You should see your subscription listed. Click on it.
4. Observe:
   - **Subscription ID** (a unique identifier)
   - **State** (should be "Enabled")
   - **Cost Management** tile (shows your spending)
5. Click **Cost Management** (or search for it) and explore:
   - **Cost Analysis** — see your spending over time
   - **Budgets** — set alerts if you exceed a threshold (useful for managing free trial spend)

### Understand Scopes in the Portal

**Scopes** determine what resources you can see and manage. RBAC (Role-Based Access Control) is also scoped — an admin role at the subscription level grants different permissions than at the resource group level.

1. Navigate to your `rg-az104-lab00` resource group.
2. Click **Access control (IAM)** on the left sidebar.
3. Click **Role assignments**.
4. You should see at least one role assignment (yourself, with Owner or similar role).
5. Note the **Scope** column — it shows the resource group scope (`/subscriptions/.../resourceGroups/rg-az104-lab00`).

**Key concept:** The same user can have different roles at different scopes. For example:
- You might be "Owner" of `rg-az104-lab00` (can do anything in that RG)
- But only "Reader" at the subscription level (can view everything, but not change anything outside the RG)

---

## Part 4 – Find Azure Services by Category

Azure has 200+ services. The portal organizes them by category. Let's explore.

### Browse Services by Category

1. Click **Create a resource** on the Home page (or search for `create a resource`).
2. You'll see a page with categories on the left:
   - **Compute** (VMs, containers, serverless)
   - **Storage** (disks, blob storage, queues)
   - **Networking** (VNets, load balancers, firewalls)
   - **Databases** (SQL, Cosmos DB, MySQL)
   - **Analytics** (big data, machine learning)
   - And more...
3. Click **Compute**.
4. You'll see resources like:
   - Virtual Machines
   - App Service
   - Azure Container Registry
   - Azure Kubernetes Service (AKS)
5. Each one has a description. This is useful for exam prep — spend time understanding what each service does.

### Find a Specific Service

1. On the **Create a resource** page, search for `storage account` in the top search box.
2. You'll see **Storage account** listed.
3. Click on it (but don't create one yet).
4. You'll see a description: "Create a cloud storage account..."
5. Click **Create** to see the creation wizard (we'll use this in Part 5).

---

## Part 5 – Create a Storage Account (Understanding Blades and Tabs)

A "**blade**" is the portal's term for a panel/page that slides in or opens. Most creation wizards have multiple tabs: **Basics**, **Networking**, **Advanced**, **Tags**, **Review + create**.

### Create a Storage Account

1. Search for `storage account` > **Create**.
2. **Basics** tab:
   - **Subscription**: your subscription
   - **Resource group**: select `rg-az104-lab00`
   - **Storage account name**: `stcontoso<YYMMDD>` (e.g., `stcontoso260615` for 2026-06-15; storage account names must be globally unique and lowercase)
   - **Region**: `East US`
   - **Performance**: Standard
   - **Redundancy**: Locally-redundant storage (LRS)
3. Click **Next: Networking** (or click **Next >** to skip to the next tab).
4. **Networking** tab:
   - Leave defaults for now (we'll cover networking in Module 04).
5. Click **Next: Advanced**.
6. **Advanced** tab:
   - Leave defaults.
7. Click **Next: Tags**.

---

## Part 6 – Apply Resource Tags

**Tags** are key-value pairs that help organize and track resources. At Contoso, you might tag resources with:
- `Environment: Development` or `Production`
- `CostCenter: Finance` or `Sales`
- `Owner: alice.lee@contoso.com`

### Add Tags to the Storage Account

1. You're now on the **Tags** tab.
2. Add the following tags:
   - **Key**: `Environment` | **Value**: `Development`
   - **Key**: `CostCenter` | **Value**: `Lab`
   - **Key**: `Owner` | **Value**: `<Your name>`
3. Click **Review + create**.

---

## Part 7 – Review and Create

The **Review + create** tab is your last chance to verify everything before Azure provisions the resource.

1. You're on the **Review + create** tab.
2. Review:
   - Storage account name
   - Resource group: `rg-az104-lab00`
   - Region: `East US`
   - Tags (scroll down to see them)
3. Click **Create**.
4. You'll see "Deployment is in progress" → "Your deployment is complete."
5. Click **Go to resource** to open the storage account.

### Explore the Storage Account Blade

1. You're now viewing the storage account's **Overview** blade.
2. On the left sidebar, click different sections:
   - **Overview**: summary of the resource
   - **Access keys**: credentials to access the storage account (keep these secret!)
   - **Configuration**: settings like HTTPS requirement
   - **Monitoring**: performance metrics
   - **Cost Management**: estimated costs
3. This structure (Overview, Settings, Monitoring, etc.) is common across all Azure resources.

---

## Part 8 – Use the Cloud Shell and Portal Help

### Open the Cloud Shell

1. At the top right of the portal, find the **terminal icon** (`>_`).
2. Click it. A terminal panel slides up from the bottom of your browser.
3. Select **Bash** (or **PowerShell** if you prefer).
4. First time? You'll be prompted to create a storage account for Cloud Shell. Click **Create storage**.
5. Wait a few moments for the terminal to initialize. You'll see `user@cloudshell:~$`.

### Run a Command in Cloud Shell

1. Type:
   ```bash
   az account show
   ```
2. Press Enter. You'll see JSON output with your subscription details (ID, name, state).

**Note:** Cloud Shell is useful for automation, but this course uses the Portal only. Just know it exists and how to open it.

### Access Portal Help and Support

1. Click the **?** icon (top right).
2. You'll see:
   - **Help center**: documentation links
   - **Keyboard shortcuts**: e.g., `G` + `H` = go to Home
   - **Contact support**: file an Azure support ticket (useful for production issues)
   - **Send us feedback**: report bugs or suggest features
3. Click **Keyboard shortcuts** to see the most useful portal shortcuts:
   - `G` + `H` = Home
   - `G` + `/` = Go to resource
   - `?` = Help

**Tip for exams:** Knowing keyboard shortcuts can help you navigate the portal faster during performance-based exam scenarios.

---

## Part 9 – Explore All Resources

A useful portal feature is **All resources** — a flat view of everything you own across all subscriptions (if you have access to multiple).

### View All Resources

1. Click **All resources** (or search for it).
2. You should see:
   - `rg-az104-lab00` (your resource group)
   - `stcontoso<YYMMDD>` (your storage account)
3. Filter by:
   - **Resource group**: select `rg-az104-lab00`
   - **Resource type**: select "Storage accounts"
4. This view is useful for finding a specific resource by name or type.

---

## Part 10 – Understanding Resource Groups and Resource Organization

Now let's solidify why Resource Groups matter.

### View Resources in a Resource Group

1. Search for **Resource groups** > select `rg-az104-lab00`.
2. Click the **Overview** tab.
3. You'll see:
   - **Resources**: a list of all resources in this RG (currently just your storage account)
   - **Deployments**: a history of when resources were added (click to see details)
4. If you had more resources (VMs, databases, etc.), they'd all appear here.

### Why Resource Groups Matter

- **Cost tracking**: All resources in a RG inherit the same tags, making it easy to track costs by department or project.
- **Cleanup**: Deleting a RG deletes all resources inside it. This is crucial for keeping your subscription clean and costs low. (We'll do this in the Cleanup section.)
- **RBAC**: You can grant someone admin access to a RG, and they can manage all resources inside it without needing individual permissions on each resource.
- **Organization**: A company might have RGs like:
  - `rg-prod-webservices` (production environment)
  - `rg-dev-databases` (development environment)
  - `rg-shared-networking` (shared resources like VNets)

---

## Validation Checklist

Before moving on, verify you can do the following:

- [ ] Created resource group `rg-az104-lab00` in East US
- [ ] Located services using the Search bar
- [ ] Added a service to Favorites
- [ ] Viewed your subscription details in **Subscriptions**
- [ ] Accessed **Access control (IAM)** and understood the scope concept
- [ ] Browsed Azure services by category in **Create a resource**
- [ ] Created a storage account with tags
- [ ] Opened and navigated the Cloud Shell (Bash or PowerShell)
- [ ] Used the **?** help menu and keyboard shortcuts
- [ ] Found your storage account in **All resources**
- [ ] Viewed resources in your Resource Group via **Overview**

---

## Cleanup

**Important:** Azure charges for running resources. While a storage account is cheap (~$1-2/month), it's a good habit to clean up after every lab.

### Delete the Resource Group (and Everything Inside)

1. Search for **Resource groups** > select `rg-az104-lab00`.
2. Click **Delete resource group**.
3. Confirm by typing the name: `rg-az104-lab00`.
4. Click **Delete**.
5. You'll see "Deployment is in progress" → "Your deployment is complete."

**Verification:** Go to **Resource groups**. You should no longer see `rg-az104-lab00`.

---

## Exam Tips

- **Search is your friend**: Every "Go to **\<service name\>**" instruction is a Search bar query.
- **Scope matters**: Resources, RBAC roles, and policies are all scoped to a level in the hierarchy (subscription, RG, or resource).
- **Resource Groups = logical organization**: They don't cost money and have no performance impact. Use them liberally.
- **Tags = cost tracking**: Tag everything by department, project, or environment so you can analyze costs later.
- **Cloud Shell vs. Portal**: Cloud Shell is a CLI tool; the Portal is the UI. This course uses the Portal, but both are ways to manage Azure.

---

## See It In Action

Once you understand the Portal, subsequent labs will feel natural:
1. Each lab starts with "Create a Resource Group named `rg-az104-labXX`" — you'll know exactly how to do this.
2. Each service (VMs, databases, networking) has a similar structure: Overview, Configuration, Monitoring, etc.
3. Every resource can be tagged, has access control, and belongs to a Resource Group.

---

## Next Steps

- **Lab 01** (Module 01 – Identity & Governance): Use the Portal to manage users and groups in Microsoft Entra ID.
- **Lab 02** (Module 01): Use the Portal to assign RBAC roles and Azure Policies.
- Subsequent labs: Build real infrastructure (networking, VMs, storage, databases) using the same Portal skills you learned here.

---

## Key Takeaways

| Concept | Definition | Why It Matters |
|---------|-----------|----------------|
| **Resource Group** | Logical container for related resources | Organization, cleanup, cost tracking, RBAC |
| **Scope** | Hierarchy: Tenant → Subscription → RG → Resource | Determines what you can see and manage |
| **Subscription** | Billing boundary and organizational unit | Separates costs and access for different teams |
| **Blade** | A panel/page in the Portal | Understanding the Portal structure |
| **Tags** | Key-value pairs for organization | Cost tracking, filtering, governance |
| **Search Bar** | Fastest way to find services and resources | Core navigation tool in the Portal |
| **Favorites** | Quick access to frequently-used services | Efficiency in the Portal |
| **Cloud Shell** | Browser-based CLI (Bash or PowerShell) | Alternative to the Portal for automation |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Storage account name not unique | Storage account names are globally unique. Add a timestamp or your initials (e.g., `stcontosoal260615`) |
| Resource Group not appearing | Wait a moment and refresh. Sometimes deployments take 30-60 seconds to show. |
| Can't find a service via Search | Try alternate names (e.g., "VM" instead of "Virtual Machines", "Container instances" instead of "ACI") |
| Cloud Shell times out | Cloud Shell is free but has usage limits. For this course, the Portal is sufficient. |

---

## Related Concepts

- [Module 00 Concepts: Azure Portal Navigation](../concepts/04-azure-portal-navigation.md)
- [Module 01 – Identity & Governance](../../01-identity-governance/README.md)
