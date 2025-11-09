# Security Policies
## Password Policies: Strong password policies will be configured to enforce strong authentication measures.


#### A) Password Policy: Users will have to set a password on first log in, users will have a 30 day period for each password, different from the previous 8 passwords (when applied) and use special characters to enhance security.

  1) Enforce password history: last 8 passwords
  2) Maximum password age: 30 days
  3) Minimum password age: 29 days
  4) Minimum password length: 10 characters
  5) Password must meet complexity requirement

#### B) Lockout Period: Lockout Period forces users to wait in case of wrong password combinations. This enhances security and mitigates possible brute force and dictionary attacks.

1) Account lockout duration: 20 minutes
2) Account lockout threshold: 5 invalid logon attempts
3) Allow administrator account lockout: Enable
4) Reset account lockout counter after: 15 minutes


## Access Policies: Access policies will be defined to ensure the principle of least privilege.

#### A) Change System Time: Only the IT manager can change the System Time. 
This can prevent several issues such as computers that belong to a domain not be able to authenticate themselves, time stamps on event log entries could be made inaccurate, time stamps on files and folders that are created or modified could be incorrect or other critical issues.
  
#### B) Disabled Windows Installer: All users and employees will only not be able to install any software via Windows Installer. Only applications previously approved by the IT team. Executables and Scripts can still be runned. 




