# Notifications and webhooks

Ovira tells you what happens in three ways: a bell in the panel, messages in Telegram, and webhooks that call your own service. This page covers all three.

## The bell

The bell in the panel lists what happened: a client ran out of traffic or is about to expire, a node went offline or came back, a backup failed, an inbound did not start, a license is ending. Press **Mark all as read** to clear the count. How long they are kept is set under **Settings → General**.

## Telegram

Owners set up one Telegram bot for the panel under **Settings → Telegram**: create it with @BotFather and paste its token. The same bot sends backups and notifications.

Then each admin or reseller connects their own chat under **Settings → My account**, in **Telegram notifications**: press **Connect Telegram**, open the link in Telegram and press Start. You choose which events to send, the language of the messages, and whether you hear about **All clients** or **Only my clients**. **Send test message** checks that it works.

## Webhooks

A webhook posts events to an address you choose, for example a shop bot. Open **Settings → Webhooks** and press **Add webhook**. Enter the address, choose the events or **Send all events**, and copy the signing secret that is shown once. **Send test** checks the address, and **Deliveries** lists the latest events. See [Webhooks](/api/webhooks) for the format.

## Related pages

- [Back up and restore](/use/backup): failed backups also raise a notification.
- [Webhooks](/api/webhooks): the request format.
- [Settings](/use/settings): the tabs.
