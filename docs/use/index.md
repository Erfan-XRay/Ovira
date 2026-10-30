# Using the panel

The panel is a single web application. A menu on the side (a button at the top on a phone) lists its pages, and what you see depends on your role. This section describes each page, field by field. Start here for the parts every page shares.

## The menu

| Page | What it is for | Who sees it |
|---|---|---|
| [Overview](/use/dashboard) | Online users, traffic, plans that run out, the state of the server. | Everyone |
| [Clients](/use/clients) | Create and manage the people who connect. | Everyone |
| [Connections](/use/connections) | Open tunnels now, and finished connections. | Everyone |
| [Inbounds](/use/inbounds) | The protocols and ports your servers offer. | Roles that can view inbounds |
| [Nodes](/use/nodes) | The servers that run the inbounds. | Roles that can view nodes |
| [Groups](/use/groups) | Bundles of inbounds you give to clients. | Roles that manage groups or view them all |
| [Panel accounts](/use/admins) | People who sign in to the panel, and their roles. | Owners |
| [Settings](/use/settings) | Addresses, history, look, HTTPS, backups. | Everyone, with different tabs |
| [License](/use/license) | Your plan, its limits, buying and renewing. | Everyone |
| [Updates](/use/updates) | The installed version and new releases. | Owners and roles that see all clients |

Owners see everything. Admin accounts see the clients and infrastructure pages their role allows. Reseller accounts see only their own clients. [Panel accounts](/use/admins) and [Roles and resellers](/use/resellers) explain how to set this up.

## Language and theme

At the bottom of the menu, the language button switches between English and فارسی. Persian switches the whole panel to right-to-left. The theme button cycles **System**, **Dark** and **Light**. Both choices are remembered in the browser.

The accent colour of the panel is a separate setting for everyone who signs in: **Settings → General → Panel colour**, with eight colours. Client pages have their own colour, see [The subscription page](/use/subscription-page).

## How lists and dialogs behave

- The clients list has tabs on top (**All**, **Online**, **Running out**, **Used up**, **Expired**, **Disabled**), a search box and a sort, and it is paged. Other lists have filters suited to them.
- Tick rows on the clients and groups lists to get a bar of bulk actions.
- The **⋯** button on a row, or **More** on a page, opens that item's actions. Destructive actions ask for confirmation, and say what will stop working.
- Forms report a problem next to the field that caused it. The last error of a form shows above the **Save** button.
- Settings that need a restart say so when you save them. A restart of the panel does not disconnect VPN users.

## When the panel is read-only

A red banner at the top tells you why changes are off:

- **Your license has expired, so changes are paused until it is renewed.** Renew on the [License](/use/license) page. Tunnels keep running.
- For a reseller, the banner says the account is switched off, expired or out of traffic. Contact the owner.

## Related pages

- [Get started](/start/): installing and connecting your first client.
- [How Ovira works](/how/): the parts behind these pages.
- [Glossary](/reference/glossary): terms such as inbound, node and subscription link.
