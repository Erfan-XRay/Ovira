# The first sign-in

The panel has one account when the installer finishes: the owner, named `admin` unless you chose another name. This page covers signing in, the settings worth checking first, and what to do when the address, the password or the two-factor device is lost.

## Sign in

1. Open the panel address the installer printed, including the secret path at the end.
2. Enter **Username** and **Password**.
3. Press **Sign in**.

If you tick **Keep me signed in for 30 days**, the browser stays signed in for that long. After too many wrong attempts the page asks you to wait a number of seconds before trying again.

The panel answers only under the secret path, and client subscription links use their own path. Any other address on the panel port looks like an empty server, so a typo in the path looks like a dead server.

## Check these first

1. **Change the password.** Open **Settings → My account**, enter the current password and a new one of at least 10 characters. Changing it signs out every other device.
2. **Turn on two-factor sign-in.** On the same tab, press **Turn on**, scan the QR code with an authenticator app, and enter the six-digit code. The panel then shows recovery codes. Each works once and is not shown again, so store them away from the server.
3. **Check the public address.** Open **Settings → General**. **Public address** is the domain or IP that client profiles connect to. The installer fills it with your domain or the server's IP. The **Overview** page shows a notice when it is empty.

## Change the panel address

Open **Settings → Panel access**. These fields decide where the panel answers:

| Field | What it does |
|---|---|
| **Listen address** | Port, for example `:2053`. Use `127.0.0.1:2053` when a reverse proxy sits in front. |
| **Secret path** | The panel answers only under this path. |
| **Subscription path** | The first part of client subscription links. The default is `sub`. |
| **TLS certificate file**, **TLS key file** | Your own certificate files, as full paths on the server. Leave empty for plain HTTP or for the Let's Encrypt certificate. |
| **Behind a reverse proxy (trust X-Forwarded-For)** | Turn on only when a proxy you control sets that header. |

Changes apply after a restart. Under the fields the panel prints the address it will have, in the form `After restart the panel will be at ...`. Write it down, press **Save**, then **Restart panel**. VPN connections are not affected by the restart.

## When something is lost

Run these on the panel server as root.

| Problem | What to do |
|---|---|
| The panel address | `ovira status` prints it. `ovira info` prints it with the machine ID and license. |
| The owner password | `ovira password` lists the accounts, asks which one, and sets a new password. Press Enter at the prompt to get a random one. Other sessions of that account are signed out. |
| The two-factor device and the recovery codes | Another owner can open **Panel accounts**, use the menu on the account and choose **Turn off 2FA**. On the server, `ovira admin reset-2fa -username NAME` does the same. |
| The list of accounts | `ovira admin list`. |

## Related pages

- [Panel accounts](/use/admins): more accounts, roles, sessions and two-factor sign-in.
- [Settings](/use/settings): the other tabs of the settings page.
- [HTTPS for the panel](/start/https): certificates and the restart they need.
- [The command line](/reference/cli): every `ovira` command.
