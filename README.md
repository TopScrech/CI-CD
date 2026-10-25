# CI/CD

Native SwiftUI app for managing Xcode Cloud & Coolify

<img width="330" height="717" alt="0x0ss" src="https://github.com/user-attachments/assets/f6588857-faa1-4810-9798-2d7c921b00c1" />

## Supported platforms
- iOS / iPadOS 18+
- macOS 14+
- visionOS 2+

## Coolify proxy setup

### Purpose

Route Coolify HTTPS requests through an authenticated HTTPS CONNECT proxy on a VDS with a stable outbound IPv4 address

- VDS: `5.83.140.89`
- Upstream: `https://clfy.crunchy.host`
- Preserve end-to-end Coolify TLS and existing API token authentication
- Restrict the proxy to the Coolify hostname on port 443
- Keep SSH passwords, proxy passwords, and API tokens out of this repository

### Progress — 2026-10-25

- Diagnosed Coolify project loading failures as HTTP 403 responses from its API IP allowlist
- Added HTTP response validation and visible API errors to the app
- Confirmed that removing the Coolify IP restriction allowed requests to succeed
- Connected to the VDS over SSH and identified Ubuntu 24.04 LTS
- Confirmed port 3128 was unused and the VDS had no existing proxy service
- Installed Squid 6.14 from Ubuntu packages and enabled automatic startup
- Restricted access to authenticated CONNECT requests for `clfy.crunchy.host:443`
- Bound outbound connections to `5.83.140.89`
- Generated a separate proxy password and stored the password hash in `/etc/squid/coolify-passwd`
- Verified from both the VDS and the Mac that Cloudflare saw `5.83.140.89` for the Coolify-domain connection check
- Verified successful CONNECT tunneling and an expected HTTP 401 from `/api/v1/projects` without a Coolify API token
- Verified missing and incorrect proxy credentials returned HTTP 407
- Verified requests to another hostname returned HTTP 403

### TLS upgrade — 2026-10-26

- Added Cloudflare DNS-only A record `proxy.topscrech.dev` → `5.83.140.89`
- Issued a publicly trusted Let’s Encrypt certificate for the proxy hostname
- Replaced the GnuTLS Squid package with Ubuntu’s `squid-openssl` package to serve the complete certificate chain
- Enabled an HTTPS proxy listener on port 443 with TLS 1.2 or newer
- Verified certificate trust from the VDS and authenticated proxy access from the Mac
- Verified the outbound IP remained `5.83.140.89`, unauthenticated requests returned 407, and other destinations returned 403
- Updated the Mac’s private curl configuration to use the HTTPS proxy
- Configured Certbot automatic renewal and a deploy hook to reload Squid certificates
- Passed a simulated certificate renewal including the deploy hook
- Disabled the plain HTTP listener on port 3128 and verified it was unreachable
- Updated both VDS private connection files to use the HTTPS endpoint

### Connection settings

| Setting | Value |
| --- | --- |
| Type | HTTPS forward proxy with CONNECT |
| Host | `proxy.topscrech.dev` |
| Port | `443` |
| Username | `coolify` |
| Allowed destination | `clfy.crunchy.host:443` |
| Outbound IPv4 | `5.83.140.89` |

Keep the app's Coolify URL set to `https://clfy.crunchy.host` — the proxy address belongs in the client's proxy configuration, not in the Coolify URL field

In the app, open a Coolify account’s settings, enable **Use proxy**, enter the proxy password, and tap **Save**
The proxy URL starts blank and must be entered by the user — HTTPS uses port 443 automatically when omitted
Enter the proxy username explicitly — for the current server it is `coolify`; the app does not supply a default
The URL, username, and password are stored together per account in synchronizable iCloud Keychain, not SwiftData or UserDefaults
The enabled toggle is stored with the account
Missing credentials, invalid settings, or a failed proxy connection never trigger a direct-connection fallback
If using a device-wide proxy, other destinations will be blocked by this Coolify-only configuration

HTTPS payloads and the Coolify API token remain encrypted end to end
The connection to the proxy is also TLS-encrypted, including proxy authentication
Clients must support HTTPS proxies and use `https://proxy.topscrech.dev`, not a plain HTTP proxy setting

### Credentials

- On the VDS: `/root/coolify-proxy-credentials.txt` contains the connection settings and generated password, readable only by root
- On the VDS: `/root/coolify-proxy-curl.conf` contains a ready-to-use curl configuration, readable only by root
- On this Mac: `~/.config/cicd/coolify-proxy-curl.conf` contains the same curl configuration with mode `600`, outside the repository
- The SSH login password was not saved in repository files or reused for proxy authentication

Retrieve the proxy password over SSH when configuring a client:

```sh
ssh root@5.83.140.89 'cat /root/coolify-proxy-credentials.txt'
```

Verify the outbound IP from this Mac:

```sh
curl --config ~/.config/cicd/coolify-proxy-curl.conf \
  https://clfy.crunchy.host/cdn-cgi/trace
```

Expected `ip=` value: `5.83.140.89`

### Operations

Run these commands on the VDS:

```sh
systemctl status squid
squid -k parse
systemctl reload squid
tail -n 50 /var/log/squid/access.log
```

- Active configuration: `/etc/squid/squid.conf`
- Original package configuration backup: `/etc/squid/squid.conf.before-coolify`
- Installation log: `/root/coolify-proxy-install.log`
- TLS package logs: `/root/coolify-proxy-tls-install.log` and `/root/coolify-proxy-openssl-install.log`
- Certificate source: `/etc/letsencrypt/live/proxy.topscrech.dev/`
- Squid certificate copies: `/etc/squid/tls/` — private key mode `640`, owned by `root:proxy`
- Automatic renewal: `certbot.timer`
- Renewal deploy hook: `/etc/letsencrypt/renewal-hooks/deploy/reload-coolify-proxy`
- Renewal verification log: `/root/coolify-proxy-renewal-test.log`
- Test future renewals with `certbot renew --dry-run --no-random-sleep-on-renew --run-deploy-hooks`
- Port 80 must remain reachable for standalone ACME validation during issuance and renewal
- Cloudflare must remain DNS-only for this forward proxy
- UFW was inactive and was left unchanged
- To stop the proxy and disable automatic startup: `systemctl disable --now squid`

To rotate the proxy password, run `htpasswd -B /etc/squid/coolify-passwd coolify` interactively, restart Squid to clear cached credentials, and update both private curl configurations and the private credentials file

### Remaining work

- Enter the proxy password in the app and verify authenticated project loading on a signed device
- Verify iCloud Keychain syncing on a second device signed into the same Apple account with iCloud Keychain enabled
- Add `5.83.140.89` to Coolify's IP allowlist and verify authenticated project loading before removing any other required entries
- Confirm the IP evaluated by Coolify itself if its origin proxy still reports a different address — the connection check verifies Cloudflare's view

### App proxy settings — 2026-10-26

- Added a per-account Use proxy toggle with conditional URL and password fields
- Saved both fields as a synchronizable Keychain item with when-unlocked accessibility
- Routed all Coolify API calls through authenticated TLS CONNECT when enabled
- Used Apple’s Network proxy configuration with direct failover disabled
- Validated HTTPS URLs, empty URLs, explicit ports, invalid URLs, and missing passwords with Swift Testing
- Verified a live URLSession request through the proxy returned HTTP 200 and outbound IP `5.83.140.89`
- Cross-device Keychain synchronization still needs verification on signed devices
- Passed unsigned device builds for the iOS and visionOS schemes without launching a simulator
- Fixed an existing visionOS build error by making the shared Hide removed apps preference available outside the iOS-only settings block

### Explicit proxy username — 2026-10-26

- Added a separate proxy username field and removed the hard-coded username
- Saved the username with the URL and password in iCloud Keychain
- Preserved existing saved URLs and passwords when loading older Keychain items, leaving the new username field blank until entered
