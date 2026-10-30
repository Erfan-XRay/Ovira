# Activity log

The activity log records what people did in the panel: who signed in, who created or changed a client, who restored a backup. It answers "who changed this, and when". This page covers the log's columns, what it records and how long it is kept.

## Where to find it

Open **Settings → Activity log**. Owners and roles that see all clients can open it. A reseller account does not have the tab.

## The columns

| Column | What it shows |
|---|---|
| **When** | The date and time of the action. |
| **Who** | The panel account. A dash when the event has no account. |
| **Action** | A short code such as `client.create` or `login.failed`. Codes with `failed` in them are shown in red. |
| **Target** | What the action was about, for example a client name, with details under it. |
| **IP** | The address the request came from. Hidden on narrow screens. |

Newest entries come first. The list loads in pages; press **Load more** for older entries. An empty log says `No activity yet.`

## What is recorded

The codes group by what they cover:

| Group | Examples |
|---|---|
| Sign-in | `login`, `login.failed`, `login.recovery-code`, `login.refused` |
| Your account | `account.password`, `account.2fa.enable`, `account.2fa.disable`, `account.sessions.revoke` |
| Panel accounts and roles | `admin.create`, `admin.update`, `admin.password`, `admin.reset-2fa`, `admin.delete`, `role.create`, `role.update`, `role.delete` |
| Clients | `client.create`, `client.bulk-create`, `client.update`, `client.delete`, `client.wg-reset` |
| Connections | `connection.kick` |
| Groups | `group.create`, `group.update`, `group.assign` |
| Inbounds and nodes | `instance.create`, `instance.update`, `instance.assign`, `instance.unassign`, `instance.delete`, `node.create`, `node.update`, `node.delete` |
| Settings and maintenance | `settings.update`, `settings.panel`, `settings.tls`, `panel.restart`, `backup.download`, `backup.restore`, `update.start`, `update.install` |
| License | `license.install`, `license.remove`, `license.order` |

The log does not record VPN traffic. For who was connected, see [Connections](/use/connections).

## How long it is kept

Set **Activity log** under **Keep history for** in **Settings → General**, in days. Older entries are removed.

## Related pages

- [Settings](/use/settings): the retention setting.
- [Panel accounts](/use/admins): the accounts the **Who** column refers to.
- [Connections](/use/connections): live and finished VPN connections.
