# Roles and resellers

A role is a set of permissions and limits that you give to panel accounts. A reseller is an account whose role lets it manage only its own clients, inside a traffic pool and the limits you set. This page covers the **Roles** tab, the permission table, the limits, and how a reseller account works day to day. Accounts themselves are on [Panel accounts](/use/admins).

Reseller accounts need a plan that includes them. The **License** page shows whether yours does.

## The built-in roles

**Owner**, **Admin** and **Reseller** exist from the start. **Admin** may do everything a role can, on all clients. **Reseller** may manage its own clients and connections, and view the groups and inbounds you grant it. Built-in roles cannot be changed. Use **Duplicate** on one to make your own version, with the name `Reseller copy`, then edit the copy.

Open **Panel accounts** and switch to the **Roles** tab. Each role shows how many accounts use it and a one-line summary, such as `Clients: Own clients only`. The menu on a role offers **View** or **Edit**, **Duplicate** and **Delete**. A role used by accounts cannot be deleted.

## Create a role

Press **New role**.

| Section | What it holds |
|---|---|
| **Name** | **Role name**. |
| **Permissions** | What accounts with this role may do. |
| **Limits** | Defaults for every account on the role. Each account can override them. |

### Permissions

Permissions are grouped by what they act on. Each one is set from a list.

| Resource | Permissions |
|---|---|
| **Clients** | **View**, **Create**, **Edit**, **Delete**, **Reset traffic**, **Disconnect** |
| **Connections** | **View**, **Disconnect** |
| **Groups** | **View**, **Manage** |
| **Inbounds** | **View**, **Manage** |
| **Nodes** | **View**, **Manage** |

The choices are **No access**, **All**, and for the permissions that can be limited a middle one. For clients and connections it is **Own clients only**: the clients the account created itself. For viewing groups and inbounds it is **Only those granted**: the ones you list in the account's access. **Manage** permissions and node permissions are **No access** or **All**.

Settings, accounts and roles, license, billing, updates and backup are never part of a role. They stay with owners.

### Limits

The **Limits** section starts with **Default traffic pool**, the pool suggested when you create an account with this role. When the role works on own clients, more fields appear.

| Field | What it does |
|---|---|
| **Client limit** | The most clients an account may own. Empty means no limit. |
| **Groups it may assign** | Clients of the account can be put in these groups only. |
| **Inbounds it may assign** | Single inbounds the account may hand to a client. |
| **Clients must be in a group** | Every client goes into one of the allowed groups, and single inbounds cannot be picked. |
| **Most traffic per client** | The upper limit for one client's allowance. |
| **Longest client lifetime** | The days a client may last. Clients then need an end date. |
| **Most devices per client** | The upper limit for one client's devices. |
| **Clients without a traffic cap** | When off, every client needs a traffic limit. |

A role that works on all clients has nothing to limit here, and the page says so.

## A reseller account

When you create an account with a reseller role, the **Plan** section holds two fields.

| Field | What it does |
|---|---|
| **Traffic pool** | The traffic that all the account's clients use together. |
| **End date** | The account's end date. Traffic left unused is lost at the end of that day. |

The pool counts the real traffic of all the account's clients, and a node with a multiplier counts more. Deleting a client does not give any back. When the pool is used up or the end date passes, all the clients of the account stop until you add traffic or extend it. The account page shows the state: **Active**, **Switched off**, **Expired** or **Out of traffic**.

The **Access** section chooses the groups and inbounds the account may give to its clients. An account with nothing granted cannot create clients. The **Client rules** section sets the per-client limits. Every limit shows **From role:** with the role's value, and a switch **Set for this account** overrides it for this one account.

To top up a reseller, use **Add traffic…** (adds to the pool) or **Extend…** (adds days, sets a new pool, and optionally resets what is used) from the account's menu.

### What the reseller sees

A reseller sees **Overview**, **Clients**, **Connections**, **Settings** (only **My account**) and **License**. The clients are only its own. **Overview** shows **Your account** with the pool and warnings: at 80 percent used, at 95 percent, and in the last days before the end date. When the account is switched off, expired or out of traffic, a banner explains it and changes are off. The reseller asks you for more.

## Related pages

- [Panel accounts](/use/admins): creating accounts and managing them.
- [Groups](/use/groups): the groups a reseller can assign.
- [Clients](/use/clients): the client form a reseller uses.
- [License](/use/license): which plans include reseller accounts.
