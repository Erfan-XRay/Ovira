# Panel accounts

A panel account is a person who signs in to the panel. The **Panel accounts** page, which only owners see, lists them, creates them and controls what each one may do. This page covers the account list, creating and managing an account, and the account's own sign-in security: password, two-factor sign-in and signed-in devices.

## Roles in short

Every account has a role.

| Role | What it can do |
|---|---|
| **Owner** | Everything, with no limits. Settings, accounts and roles, license, billing, updates and backup stay with owners. |
| **Admin** | Manages clients and inbounds. |
| **Reseller** | Sees and manages only the clients it created, inside a traffic pool and the limits you set. |

You can add roles of your own. See [Roles and resellers](/use/resellers). The free plan has one panel account; the **License** page shows how many your plan allows. Reseller accounts need a plan that includes them.

## The list

The **Accounts** tab shows:

| Column | What it shows |
|---|---|
| **Username** | The sign-in name. `you` marks your own account. |
| **Role** | The role's name. |
| **Status** | **Active**, **Switched off**, **Expired** or **Out of traffic**. |
| **Clients** | How many clients the account owns. |
| **Traffic** | The traffic pool used and left, for accounts that have one. |
| **Ends** | The end date, or `No end date`. |
| **Online** | How many of its clients are online. |

Select an account to open its page, which lists its clients and usage. The **⋯** menu offers the actions below.

## Create an account

Press **New account**. Pick a role first, then set the plan.

| Field | What it does |
|---|---|
| **Username** | The sign-in name. |
| **Password** | At least 10 characters. Only on creation. |
| **Role** | **Owner** or one of the roles. A line under it says how many accounts use the role. |
| **Active** | When off, the account cannot sign in and its clients are paused. |

For accounts that are not owners, three more sections follow. They are described under [Roles and resellers](/use/resellers): **Plan** (the traffic pool and end date), **Access** (the groups and inbounds the account may hand out) and **Client rules** (limits on each client it creates). An account with no access granted cannot create clients, and the form warns you.

**Note** is for you only.

## Manage an account

The menu on a row, and on the account's page, offers **Open** and:

| Action | What it does |
|---|---|
| **Edit** | Changes the fields above. |
| **Set password** | Sets a new password for the account. |
| **Turn off 2FA** | Offered when the account has two-factor sign-in on. Removes it; the user can set it up again. |
| **Add traffic…**, **Extend…**, **Reset used traffic** | Change the account's traffic pool, end date or used traffic. Not offered for owners. |
| **Switch off** or **Switch on** | A switched-off account is signed out, and all its clients stop. |
| **Pause all clients** or **Resume all clients** | Disables or enables every client of the account. |
| **Delete** | Deletes the account. You cannot delete or switch off your own account. |

When an account owns clients, **Delete** asks what to do with them: **Move them to another account** (nothing changes for the clients) or **Delete the clients** (their profiles stop for good).

## Your own account

**Settings → My account** is available to every account.

- **Change password**: enter **Current password** and **New password**. Every other device is signed out.
- **Two-factor sign-in**: press **Turn on**, scan the QR code with an authenticator app such as Google Authenticator or Aegis, or type the key shown under **Or enter this key**, then enter the code. Each later sign-in asks for a six-digit code, or a recovery code.
- **Recovery codes**: shown once, when you turn two-factor sign-in on. Each code works once. To get a new set, enter your password and press **New recovery codes**. To turn two-factor sign-in off, enter your password and press **Turn off**.
- **Signed-in devices**: every browser signed in to your account, with its address and last activity. **Sign out** ends one session, **Sign out everywhere else** ends all but this one.

Settings can also set **Sign out after inactivity** for everyone, see [Settings](/use/settings).

## Related pages

- [Roles and resellers](/use/resellers): permissions, pools and per-client limits.
- [First sign-in](/start/first-sign-in): what to do when a password or two-factor device is lost.
- [Audit log](/use/audit): who did what.
- [License](/use/license): how many accounts your plan allows.
