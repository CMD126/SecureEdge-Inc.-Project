# Network Access Control (NAC)

This section covers the NAC implementation for SecureEdge Inc., combining a Captive Portal with FreeRADIUS and Active Directory integration to enforce authenticated network access.

## Overview

NAC ensures only authorized and compliant users and devices can connect to the network. The implementation follows the **AAA framework** — Authentication, Authorization, and Accounting — using:

- **pfSense Captive Portal** — intercepts unauthenticated HTTP/HTTPS traffic and redirects users to a login page.
- **FreeRADIUS** — acts as the central AAA server, processing authentication requests.
- **Active Directory (AD)** — serves as the enterprise identity store via LDAP integration.

## Architecture Flow

```
User connects to network
        ↓
pfSense Captive Portal intercepts traffic
        ↓
User submits AD credentials
        ↓
Captive Portal sends RADIUS request to FreeRADIUS
        ↓
FreeRADIUS queries Active Directory via LDAP
        ↓
Success → Full network access granted
Failure → User remains restricted
        ↓
Session logged for audit and accounting
```

## Key Components

| Component | Role |
|---|---|
| **pfSense Captive Portal** | Redirects unauthenticated users to login page |
| **FreeRADIUS** | AAA server — authenticates users against AD |
| **Active Directory** | Enterprise identity store (user credentials) |
| **NAS (pfSense)** | Network Access Server — enforces access decisions |

## Documents

- [Network Access Control (NAC).md](Network%20Access%20Control%20(NAC).md) — Full NAC theory, AAA framework explanation, and implementation guide.
- [MVP: Captive Portal with FreeRADIUS and AD Integration](MVP_%20Captive%20Portal%20with%20FreeRADIUS%20and%20Active%20Directory%20Integration%20nome.md) — MVP scope, deliverables, and success criteria.
