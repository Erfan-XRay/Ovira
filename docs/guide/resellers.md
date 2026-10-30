# Panel accounts and resellers

Besides the owner, the panel can have other accounts. Each account has a **role** that decides what it may do, and a reseller account can also have a **plan** with a traffic pool. Resellers need a plan that includes them, see [Plans and licenses](./plans).

## Panel accounts and roles

As the owner, open **Panel accounts**. It has two tabs: **Accounts** and **Roles**.

- **Admin** and **Reseller** are built-in roles. They cannot be edited, but you can duplicate one and change the copy.
- A custom role chooses, for each action, whether it applies to **own clients only** or to **all** clients.
- It also chooses which groups and inbounds the account may assign to its clients.
- Per-client rules limit what the account can give out: maximum traffic, maximum days, maximum devices, whether unlimited clients are allowed, and whether a group is required.

Each account can keep the role's value for a rule or override it.

To add an account: **Panel accounts → Accounts → New account**, pick the role, set the rules you want to override, and save.

## Reseller plan

On a reseller account you can set:

- a **traffic pool**, counted from the real traffic of all the reseller's clients (node multipliers apply);
- an optional **end date**;
- a **client limit**.

When the pool is used up, the end date passes, or you disable the account, all of that reseller's clients stop. They work again when you add traffic, extend the plan or enable the account. Unused traffic does not carry over past the end date.

## Owner actions on an account

From the account's row you can:

- add traffic or extend the end date;
- reset usage;
- disable or enable the account;
- disable or enable all of its clients;
- delete the account and either move its clients to another account or delete them.

## What the reseller sees

The reseller's **Overview** shows remaining traffic, days left and the client count, with warnings at 80% and 95% of the pool.
