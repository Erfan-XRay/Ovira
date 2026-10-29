# HTTPS

Ovira gets free certificates from Let's Encrypt and renews them itself. Pick a mode at install time or later under **Settings → Panel access → HTTPS**.

| Mode | When to use | Certificate life |
|---|---|---|
| **Domain** | You have a domain whose A record points at the server | 90 days, renewed at 30 days left |
| **Server IP** | No domain | Short-lived certificate; renewal starts when one third of its lifetime remains |
| **None** | Behind your own TLS proxy, or for testing | — |

Ovira checks renewal hourly and attempts it when one third of the certificate lifetime remains. Issuance and lifetime depend on the certificate authority; inspect the actual expiry in the panel. Keep the validation port reachable for renewals.

## How it works

Let's Encrypt checks that the server is yours by connecting to it for about a minute:

- on **port 80** (HTTP-01), or
- on **port 443** (TLS-ALPN-01) when port 80 is taken.

If another program (nginx, Caddy, Xray…) uses **both** ports, Ovira cannot get a certificate. Free one of them during issuing and renewal, or use your own certificate files under **Settings → Panel access → Certificate file / Key file**.

After getting a certificate, press **Restart** so the panel switches to HTTPS. Renewals are picked up without a restart.

## From the command line

```bash
ovira ssl issue -mode domain -domain panel.example.com -email you@example.com
ovira ssl issue -mode ip            # detects the server's public IPv4
ovira ssl status
ovira ssl off                       # back to plain HTTP
systemctl restart ovira
```
