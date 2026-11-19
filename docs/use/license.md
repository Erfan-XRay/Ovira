# License

Ovira is free for small setups and paid beyond that. A license sets how many active clients, nodes and panel accounts you can have, and whether reseller accounts are available. Every license runs on one panel at a time, on every plan. The **License** page shows your plan and limits, sells and renews plans, and moves a license between servers. This page covers the plans, buying and renewing, moving a license, and what the panel does when a license ends.

## Plans

Without a license the panel runs on the **Free plan**: 5 active clients, 2 nodes and one panel account. A paid plan raises those limits. The plans on offer, with their prices, are on the **License** page. At the time of writing they are:

| Plan | Active clients | Nodes | Panel accounts | Reseller accounts |
|---|---|---|---|---|
| **Free** | 5 | 2 | 1 | no |
| **Starter** | 200 | 3 | 2 | no |
| **Pro** | 800 | 10 | 5 | yes |
| **Business** | unlimited | unlimited | unlimited | yes |

Every plan runs on **one panel**. Plans and prices can change, so treat the **License** page as the current list. A plan includes all updates for as long as it runs.

What the limits count:

- **Active clients** are clients that are enabled and not past their end date, including those waiting for their first connection. Disabled and expired clients kept for your records do not count. A client that has used all its traffic still counts until you disable it or it expires.
- **Nodes** are the servers you connect. The panel's own server, **This server**, is not counted.
- **Panel accounts** are the accounts under **Panel accounts**.
- **One panel**: a license is active on one panel at a time. To use it on another server, move it first, see below.

## The License page

The card at the top shows:

| Item | What it shows |
|---|---|
| State | **Free**, **Active**, **Expired**, **Not valid**, **Suspended** or **Check failed**. |
| Plan | The plan name, or **Free plan**. |
| **Licensed to** | The holder of the license. |
| **Valid until** | The end date, with the days left. |
| **Key** | The license key, partly hidden. |
| **Limits** | **Active clients**, **Nodes** and **Panel accounts**, each as used and allowed, with a bar, and **One panel**. |

`Last checked` and **Check now** appear for licenses bought online. **Check now** asks the license service for the current state. The page also shows **This server's machine ID**, which identifies the server a license is issued for.

Only owners can buy, renew, enter a key or remove a license.

## Buy or renew

1. Open **License**.
2. Under **Billing period**, choose **1 month**, **3 months** or **12 months**. Longer periods save on Pro and Business; Starter costs the same per month.
3. On the plan you want, press **Buy**. On your current plan the button is **Renew**; on another plan it is **Switch to this plan**.
4. Choose the **Payment method**: **USDT on TRON (TRC20)**, or **Other cryptocurrencies** through the NOWPayments page. Enter an optional Telegram or email contact for support with this purchase.
5. Press **Pay**, then pay as the page says. For USDT, send exactly the amount shown, including the decimals, to the address shown, on the TRC20 network only. Funds sent on another network are lost, and the exact amount is how the payment is matched to you.
6. Wait for the payment to be confirmed. The license activates by itself.

Renewing adds the paid time to what is left. Switching plans applies the new limits at once. Closing the payment window does not cancel the order: it keeps waiting in the background, and **Cancel this order** stops offering it. **Purchase history** lists every order with its **Status**: **Paid**, **Waiting for payment**, **Expired**, **Failed** or **Cancelled**. From it you can **Continue payment**, or **Install again** for a paid order whose license did not install.

If online payment is not available, the page says so and shows a **Support** link.

## Enter a key bought elsewhere

Under **Enter a license key**, paste the key into **License key** and press **Activate**. Keys bought on the page install themselves.

## Move a license to another server

Each license runs on one panel at a time, on every plan. To move it to another server, uninstall Ovira on the old server (`ovira uninstall`) or press **Remove license** there; the license is free at once. If the old server is gone, the license frees itself 72 hours after that panel last reached the license service.

1. On the old server, run `ovira uninstall`, or open **License** on the old panel, press **Remove license** and confirm. The license is free at once, and the old panel falls back to the free plan.
2. On the new panel, open **License**, paste the key into **License key** and press **Activate**.

If the key is still active on another panel, **Activate** fails and tells you when that panel was last seen and when the license frees itself. Remove the license there first. If you cannot reach that server, wait for the time shown, or contact support from the **License** page.

Reinstalling Ovira on the same server with its data kept brings the license back by itself.

## When a license ends

When a paid license expires or is suspended, the panel becomes read-only. Your tunnels keep running and clients connect within the plan's limits, but you cannot create or change clients, inbounds or nodes. A red banner says `Your license has expired, so changes are paused until it is renewed.` The **License** page stays available, so you can renew from it. When the renewal goes through, changes work again.

A panel that has not been able to reach the license service for too long also pauses changes. The page says `This server has not reached the license server for too long, so changes are paused.` Check that the server has internet access, then press **Check now**. A license that is **Not valid** or **Suspended** shows the reason on the card.

## When the free limits apply

The free limits apply when no license is installed, when you remove one, and while a new key has not been activated yet. If you use more than the free plan allows, the extras stop working:

- Clients beyond the limit cannot connect. The oldest clients, up to the limit, keep working.
- Nodes beyond the limit stop serving traffic.
- Panel accounts beyond the limit cannot sign in. The first owner account always can.

::: warning
Removing a license while you have more than 5 active clients stops the extra clients from connecting. Remove it when you are ready to activate the key elsewhere, and disable the clients you do not need first.
:::

## Related pages

- [Panel accounts](/use/admins): the account limit and reseller accounts.
- [Nodes](/use/nodes): the node limit.
- [Move the panel](/start/move-server): moving a panel together with its license.
- [Troubleshooting](/reference/troubleshooting): license messages by symptom.
