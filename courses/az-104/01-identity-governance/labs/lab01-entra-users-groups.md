# Lab 01 – Microsoft Entra ID: Users, Groups & Administrative Units

## Objectives
- Create users and groups in Microsoft Entra ID (formerly Azure AD)
- Manage group membership and assign group-based licenses
- Create an administrative unit and delegate scoped admin rights
- Configure self-service password reset (SSPR) settings (overview)

## Prerequisites
- An Entra ID tenant with Global Administrator or User Administrator role
- Signed in at [portal.azure.com](https://portal.azure.com)

## Estimated time
45 minutes

---

## Part 1 – Create users

1. Go to **Microsoft Entra ID** > **Users** > **New user** > **Create new user**.
2. Create four users:
   - `alice@<yourtenant>.onmicrosoft.com` — Display name: Alice Smith
   - `bob@<yourtenant>.onmicrosoft.com` — Display name: Bob Jones
   - `carol@<yourtenant>.onmicrosoft.com` — Display name: Carol Lee
   - `dana@<yourtenant>.onmicrosoft.com` — Display name: Dana Park
3. For each, set **Auto-generate password**, record the temporary passwords.
   Tick **Require this user to change their password when they first sign in**.
4. Set **Usage location** to your country (required for license assignment).
5. After creation, go to **Microsoft Entra ID** > **Users** and confirm all four
   users appear in the list with the correct display names and UPNs.

## Part 2 – Create a group and add members

1. **Entra ID** > **Groups** > **New group**.
2. Group type: **Security**. Group name: `grp-az104-lab`.
3. Membership type: **Assigned**. Under **Members**, add Alice, Bob, Carol, and Dana.
4. Select **Create**.
5. Repeat to create a second group: **Group type**: Security, name:
   `grp-az104-lab-cli`, membership type **Assigned**, with no members for now —
   this second group is used in Lab 02 to compare role assignments made to
   different groups.

## Part 3 – Dynamic group (requires Entra ID P1)

1. **Groups** > **New group** > Membership type: **Dynamic User**.
2. Add a rule: `(user.department -eq "IT")`.
3. Note: dynamic membership requires Entra ID P1/P2 licensing — if unavailable,
   just review the rule builder UI without saving.

## Part 4 – Administrative Units

1. **Entra ID** > **Roles & administrators** > **Administrative units** > **Add**.
2. Name: `au-branch-office`.
3. After creation, open `au-branch-office` > **Members** > **Add members** and
   add `grp-az104-lab` as a member of the administrative unit.
4. Go to **Roles and administrators** within the AU, assign **User Administrator**
   scoped to a test account — this user can now manage only members of this AU.

## Part 5 – Self-service password reset (overview)

1. **Entra ID** > **Password reset**.
2. Set **Self service password reset enabled** to **Selected** and add `grp-az104-lab`.
3. Review **Authentication methods** (mobile app, email, security questions).
4. *(No need to fully test SSPR in a lab tenant — understand where the settings live.)*

## Validation
- [ ] **Entra ID** > **Users** shows 4 users: Alice, Bob, Carol, Dana
- [ ] **Entra ID** > **Groups** shows `grp-az104-lab` (with all 4 users as members)
      and `grp-az104-lab-cli` (empty)
- [ ] Administrative unit `au-branch-office` exists, contains `grp-az104-lab`,
      and has a scoped User Administrator assigned
- [ ] SSPR policy scoped to `grp-az104-lab`

## Cleanup
1. **Entra ID** > **Users** > select Alice, Bob, Carol, Dana > **Delete user**.
2. **Entra ID** > **Groups** > select `grp-az104-lab` and `grp-az104-lab-cli` >
   **Delete**.
3. **Entra ID** > **Roles & administrators** > **Administrative units** > select
   `au-branch-office` > **Delete**.

## Exam Tips
- Know the difference between **Assigned**, **Dynamic User**, and **Dynamic Device** groups.
- Administrative units scope *who can administer whom*, not resource access (that's RBAC — see Lab 02).
- Group-based licensing auto-assigns/removes licenses as membership changes.
