# Plans and licenses

Ovira has a free plan for small setups. Plans set client, node, panel and administrator limits; reseller accounts are available on Pro and Business.

The table below lists the default plans. The **License** page shows the current offers, prices and payment methods before you buy.

| Plan | Active clients | Nodes | Panels at once | Panel accounts | 1 month | 3 months | 12 months |
|---|---|---|---|---|---|---|---|
| **Free** | 5 | 2 | 1 | 1 | — | — | — |
| **Starter** | 200 | 3 | 1 | 2 | $3 | $8 | $27 |
| **Pro** | 800 | 10 | 2 | 5 | $7 | $19 | $63 |
| **Business** | unlimited | unlimited | 3 | unlimited | $15 | $40 | $135 |

Pro and Business include **reseller accounts** (panel users who manage only their own clients, with a client cap).

*Active clients* are enabled and not past their end date, including clients waiting for their first connection. Disabled or expired clients kept for records do not count. A client that has used its traffic allowance still counts until disabled or expired. The node limit counts remote nodes; the panel's local server is separate.

## Buy or renew inside the panel

1. Open **License**, choose the period and press **Buy** (or **Renew**).
2. Choose one of the payment methods currently offered. When direct **USDT TRC20** is enabled, use the exact amount, address and network shown. When **NOWPayments** is enabled, follow its checkout for the supported currency and network. Availability depends on the license service.
3. Wait for payment confirmation and activation. Closing the payment dialog does not cancel the order. The purchase history on **License** shows pending, paid, expired and failed orders; you can reopen pending payments and retry applying a paid order when activation failed.

Renewing adds the paid time to what is left. Switching plans applies the new limits right away.

## Panels at once

A license runs on as many panels at the same time as its plan allows. Panels renew their license automatically.

To move a license, remove it from the old panel while that panel can reach the license service, then enter the key on the new panel. A released installation's slot can remain reserved until its last signed lease expires, so removal does not guarantee an immediate free slot. Manual activation on a new installation requires the license owner's approval. Purchases inside the panel approve the purchasing installation after payment confirmation.

## Offline

Paid online licenses need periodic HTTPS access to the license service. Current installation-bound leases last at most 72 hours and normally renew every six hours. Check the deadline and any renewal error on **License**; do not rely on a fixed multi-day grace period beyond the displayed deadline.

When a previously valid signed lease passes its renewal deadline, management becomes read-only until renewal succeeds. This does not itself stop OpenVPN processes; client expiry, traffic allowance, device and access limits continue to apply. A missing, invalid or pending license can instead use the free limits, so these states are not equivalent to a temporary renewal outage.

## When a license ends

A previously valid license that expires or is suspended makes management read-only. The **License** page remains available for recovery and renewal. Tunnels remain subject to their client limits; renewal restores paid management after the new license evidence is accepted.

## Keys bought elsewhere

Paste a key (`BRW2-…`) under **License → License key**.

Do not copy a panel database or installation identity to make another licensed panel. Activate the new installation separately, within the plan's panel limit. New offline activation is not supported; already installed legacy offline licenses retain their compatibility path.
