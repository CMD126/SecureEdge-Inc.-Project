**MVP: Captive Portal with FreeRADIUS and Active Directory Integration**

## **1\. Project Overview**

### **Goal**

To deploy a captive portal solution that authenticates network users (wired or wireless) against Microsoft Active Directory using FreeRADIUS, ensuring controlled access and user accountability.

### **Scope (MVP)**

* Implement a functional captive portal that intercepts HTTP/HTTPS traffic for unauthenticated users.

* Integrate FreeRADIUS for authentication and accounting.

* Configure Active Directory integration.

* Demonstrate successful login and access control for AD users.

* Log authentication events for audit and troubleshooting.

## **2\. Key Components**

| Component | Role |
| ----- | ----- |
| **FreeRADIUS** | Central AAA (Authentication, Authorization, Accounting) server. Handles user authentication against AD. |
| **Captive Portal** | Web-based login interface that redirects unauthenticated clients to a login page. (pfSense portal) |
| **Active Directory (AD)** | Enterprise identity store providing user credentials. |
| **NAS (Network Access Server)** | Switch, Access Point, or Gateway device that redirects traffic to the portal and communicates with FreeRADIUS (pfSense).  |

## **3\. System Architecture**

**Flow:**

1. User connects to network → redirected to Captive Portal.

2. User enters AD credentials.

3. Captive Portal sends authentication request to FreeRADIUS.

4. FreeRADIUS queries Active Directory (via LDAP or winbind).

5. On success → portal grants network access.

6. On failure → user remains restricted.

7. Accounting logs stored for session tracking.

## **4\. MVP Deliverables**

| Deliverable | Description |
| ----- | ----- |
| **Running Captive Portal** | Users redirected to login page upon connection. |
| **FreeRADIUS-AD Integration** | Users authenticated against AD. |
| **Access Control** | Authenticated users get full internet access; others restricted. |
| **Accounting Logs** | Basic session logging in FreeRADIUS DB or log files. |
| **Demo Scenario** | Show AD user login and access granted. |

## **5\. Success Criteria**

* Users are redirected to a login page when unauthenticated.

* AD users can log in successfully and gain access.

* Failed authentication denies access.

* RADIUS logs contain clear authentication and accounting entries.

* System works for at least 5 concurrent test users.

