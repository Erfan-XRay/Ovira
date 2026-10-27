# Plans and licenses

Burrow is free for small setups. Every feature works on every plan; plans differ only in size.

| Plan | Active clients | Nodes | Panels at once | Panel accounts | 1 month | 3 months | 12 months |
|---|---|---|---|---|---|---|---|
| **Free** | 5 | 2 | 1 | 1 | — | — | — |
| **Starter** | 200 | 3 | 1 | 2 | $3 | $8 | $27 |
| **Pro** | 800 | 10 | 2 | 5 | $7 | $19 | $63 |
| **Business** | unlimited | unlimited | 3 | unlimited | $15 | $40 | $135 |

Pro and Business include **reseller accounts** (panel users who manage only their own clients, with a client cap).

*Active clients* are enabled and not past their end date. Disabled or expired clients you keep for records do not count.

## Buy or renew inside the panel

1. Open **License**, choose the period and press **Buy** (or **Renew**).
2. Pick a payment method:
   - **USDT on TRON (TRC20)**: send the exact amount shown to the address shown. The decimals identify your payment.
   - **Other cryptocurrencies**: a NOWPayments page with Bitcoin, Ethereum, TON, USDT on other networks and more.
3. Keep the window open or close it; the license activates by itself once the payment confirms.

Renewing adds the paid time to what is left. Switching plans applies the new limits right away.

## Panels at once

A license runs on as many panels at the same time as its plan allows. Each panel checks in with the license server twice a day.

- To move a license to another server, open **License → Remove license** on the old one (this frees its slot), then paste the key on the new one.
- A slot also frees itself if a panel has not checked in for 10 days.

## Offline grace

If a panel cannot reach the license server, it keeps working normally for **10 days**. After that, management is paused (tunnels keep running) until it can check in again.

## When a license ends

Tunnels keep running, but clients cannot be created or changed until you renew. Renewing from the **License** page restores everything immediately.

## Keys bought elsewhere

Paste a key (`BRW2-…`) under **License → License key**. Older offline keys (`BRW1-…`) tied to one server still work.
