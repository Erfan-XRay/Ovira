# Clients

A client is a person or device that connects to your VPN. The **Clients** page lists them, creates them, and acts on many at once. A client has one plan: a traffic allowance, an end date and a device limit. The same client works on every inbound and node it is allowed to use. This page covers the list, the client form, bulk creation and the client's own page.

## The list

Tabs filter the list by state: **All**, **Online**, **Running out**, **Used up**, **Expired** and **Disabled**. The search box matches a name, a note or a contact. **Sort** orders by **Newest**, **Name**, **Most traffic**, **Ending soonest** or **Last online**. If you have groups, a **Group** filter appears.

| Column | What it shows |
|---|---|
| **Client** | The name, with the note or contact under it. |
| **Status** | **Active**, **Disabled**, **Expired**, **Used up**, **Not started** (waiting for first connection) or **Online**. |
| **Traffic** | Traffic used against the allowance, or `Unlimited`. |
| **Ends** | `N days left`, `No end date`, or `N days from first connection` for a client that has not connected yet. |
| **Online** | Open tunnels now, out of the device limit when there is one. |
| **Owner** | The account that owns the client. Shown to owners and admins. |

Two buttons on a row copy the subscription link and download the client's profile file. The **⋯** menu offers **Extend**, **Edit**, **Disable** or **Enable**, **Reset traffic**, **Disconnect** and **Delete**, depending on your role.

Tick rows to get a bar of bulk actions: **Extend…**, **Groups**, **Enable**, **Disable**, **Reset traffic**, **Disconnect** and **Delete**. Deleting asks for confirmation, since the profiles stop working immediately.

## Create a client

Press **New client**.

| Field | What it does |
|---|---|
| **Name** | Also the VPN user name. Letters, digits, dot, dash and underscore. |
| **Traffic allowance** | In GB. Presets from 10 to 500. Leave empty for unlimited. Starts at 50. |
| **Duration** | Days of validity, with presets from 1 to 365. Leave empty for no end date. Starts at 30. |
| **Start the clock** | **Now**, or **At first connection**. With the second, the days begin when the client first connects. |
| **Devices at once** | How many tunnels may be open together, counted across all inbounds and nodes. `0` means no limit. Starts at 2. |
| **Reset traffic** | **Never**, **Every day**, **Every week** or **Every month**: the used traffic returns to zero on that schedule. |
| **Groups** | Shown when groups exist. A client in groups gets the inbounds of those groups. |
| **Inbounds** | Shown when there is more than one inbound and no group is chosen. **All inbounds**, or a selection. |

Under **More options**:

| Field | What it does |
|---|---|
| **VPN password** | For inbounds that sign in with a password. Leave empty to generate one. When you edit, empty keeps the current one. |
| **Fixed tunnel address** | Optional. Must be inside an inbound's reserved range. |
| **Contact** | `@telegram` or a phone number. |
| **Note** | Free text for you. |
| **Owner** | The account that owns the client. Shown when you edit. |
| **Enabled** | A disabled client cannot connect. |

When you edit a client, **Duration** is replaced by **Ends on**, with buttons for 30, 60 and 90 days and **No end date**.

## Create several

**Create several** makes clients that share one plan. Set **Name prefix**, **First number** and **How many**. The form previews the names, for example `Creates user-01 … user-10`. All the plan fields of the single form apply to every client.

## The client page

Open a client for its page.

- The top shows the state, when it was last online and who owns it. **Extend** adds days or traffic: **Add days**, **Add traffic**, and **Also reset used traffic to zero**.
- The menu has **Disable** or **Enable**, **Reset traffic**, **Disconnect**, **New subscription link**, **Replace certificate** and **Delete client**.
- **Plan** shows the traffic left, the end date, the next reset and **All-time traffic**.
- **Usage** is a chart over 24 hours, 7 days, 30 days or 90 days.
- **Connected now** lists the open tunnels. **Recent connections** lists the finished ones.
- **Send to the client** holds the subscription link and its QR code. See [The subscription page](/use/subscription-page).
- **Profiles** offers a profile file per OpenVPN inbound and one with **All inbounds in one file**. OpenConnect inbounds show the **Server address** and the **Certificate pin**. WireGuard inbounds show **WireGuard devices**: one slot per device with **Download .conf**, **Show QR** and **Reset keys**.
- **Sign-in** shows the user name and password when an inbound uses one.
- **Details** shows the fixed address, contact, note and the certificate with its end date.

Two actions need care.

- **New subscription link** cancels the current link at once. Send the new one to the client.
- **Replace certificate** makes every OpenVPN profile the client downloaded stop working. The client has to download it again.

## What ends a client's connection

A client is refused or cut off when it is disabled, past its end date, out of traffic, over its device limit, or not allowed on that inbound. The client's app retries on its own, so a plan that has ended keeps failing until you extend it. How the checks work is on [The life of a connection](/how/connection).

## Related pages

- [Groups](/use/groups): hand inbounds to many clients at once.
- [Connections](/use/connections): live tunnels, and clients over their device limit.
- [Traffic, quotas and limits](/how/traffic): how usage is counted and reset.
- [Roles and resellers](/use/resellers): what a reseller may set on a client.
