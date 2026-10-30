# Groups

A group decides which inbounds its clients get. Instead of choosing inbounds for each client, you put clients in a group and change the group once. This page covers what a group is, the group form, and how groups combine with the inbounds a client was created with.

## How groups decide access

- A client in one or more groups gets the inbounds of all its groups together.
- A client in no group keeps the inbounds it was created with.
- A group can list chosen inbounds, or include **All inbounds, including ones added later**. The second kind picks up every new inbound by itself.
- A disabled group gives no inbounds to its clients.

Groups only add inbounds. They do not change a client's traffic, end date or device limit, which stay on the client.

## The list

The **Groups** page shows one row per group: its name, a **Disabled** tag if it is off, **All inbounds** or the number of inbounds, and the number of clients. The client count is a link to the **Clients** list filtered by that group.

Tick rows for the bulk bar: **Enable**, **Disable** and **Delete**. The pencil edits a group; the bin deletes it.

## Create or edit a group

Press **Create group**.

| Field | What it does |
|---|---|
| **Name** | The group's name. |
| **Note** | Free text for you. |
| **Inbounds** | The switch **All inbounds, including ones added later**, or a list of inbounds to tick. |
| **Enabled** | Off keeps the group but stops it giving inbounds. |

## Put clients in a group

- In the client form, the **Groups** field assigns the groups when you create or edit one client.
- In the **Clients** list, tick several clients, choose **Groups**, pick a group, choose **Add to** or **Remove from**, and press **Apply**.
- When you create an inbound, its **Access** section lists the groups that will get it.

## Delete a group

Deleting asks for confirmation. Clients lose the inbounds that only this group gave them. A client left in no group gets back the inbounds it was created with.

## Groups and resellers

A role can be set so that its accounts may assign only certain groups, or must always put clients in a group. That is how an owner limits what a reseller can hand out. See [Roles and resellers](/use/resellers).

## Related pages

- [Clients](/use/clients): the **Groups** field in the client form.
- [Inbounds](/use/inbounds): the **Access** section of a new inbound.
- [Roles and resellers](/use/resellers): limits on the groups an account may assign.
