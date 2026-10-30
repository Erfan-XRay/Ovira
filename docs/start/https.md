# HTTPS for the panel

Ovira gets a free certificate from Let's Encrypt for the panel and renews it by itself. You choose the mode at install time, or later under **Settings → Panel access**, in the **HTTPS** block at the top. This page covers the three modes, what Let's Encrypt needs from the server, and using your own certificate instead.

## Choose a mode

| Mode | When to use it |
|---|---|
| **Domain** | You have a domain, and its A record points at this server. This is the best choice. |
| **Server IP** | You have no domain. The certificate is issued for the server's IP address, lasts only days, and is renewed automatically. |
| **None** | Plain HTTP. Passwords cross the network unencrypted, so use it only behind a TLS proxy of your own. |

The block shows the current state: the name the certificate is for, who issued it and when it ends. If the last renewal failed, the reason appears under the status line.

## Get a certificate

1. Open **Settings → Panel access**.
2. Choose **Domain** or **Server IP**.
3. For **Domain**, enter the domain in **Domain**.
4. Optionally enter an **Email (optional)**. Let's Encrypt writes to it only if something about the certificate needs attention.
5. Press **Get certificate**.
6. Press **Restart panel**. The panel switches to HTTPS on restart, and the address changes from `http://` to `https://`.

To go back to plain HTTP, choose **None**, press **Use plain HTTP**, and restart.

## What Let's Encrypt needs

Let's Encrypt checks that the server is yours by connecting to it for about a minute. It tries port 80, and port 443 when port 80 is busy. If another program, such as nginx or Caddy, holds both ports during issuing, Ovira cannot get a certificate. Free one of the ports for the check, or use your own certificate files.

Renewals need the same port again. A certificate that cannot renew expires, and browsers then warn about the panel. The panel picks up a renewed certificate without a restart.

## Use your own certificate

Under **Settings → Panel access**, fill in **TLS certificate file** and **TLS key file** with full paths on the server, for example the files `certbot` keeps under `/etc/letsencrypt/live/`. Save and restart. Leave both empty to use the Ovira-managed certificate or plain HTTP.

## From the command line

```bash
ovira ssl                  # menu: domain, IP or off
ovira ssl status           # current certificate and mode
ovira ssl off              # plain HTTP; restarts the panel
ovira ssl issue -mode domain -domain panel.example.com -email you@example.com
ovira ssl issue -mode ip   # certificate for the server's IP
systemctl restart ovira    # after issue, to switch the panel to HTTPS
```

## Related pages

- [Install the panel](/start/install-panel): the installer asks the same question.
- [Settings](/use/settings): the other fields of the **Panel access** tab.
- [OpenConnect](/protocols/openconnect): an OpenConnect inbound can reuse the panel's certificate.
- [Troubleshooting](/reference/troubleshooting): certificate and port problems by symptom.
