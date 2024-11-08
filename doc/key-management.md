## Key Management Plan for CIM

### Key Hierarchy and Structure
   - **Certify Key (Root Key):**  
     - Acts as the master key (root) incorporated into all GPG keys.
     - Used to generate root signing, encryption, and authorization keys for each individual.
     - Stored offline with strict access controls.

   - **Derived Keys (Per Individual):**  
     - **Signing Key**: Used for signing transactions, messages, and documents.
     - **Encryption Key**: Used for encrypting and decrypting sensitive data.
     - **Authorization Key**: Used for authenticating access.

   - **YubiKey Integration:**  
     - YubiKeys are configured using the [nixos-yubikey](https://github.com/thecowboyai/nixos-yubikey) setup.
     - Coupled with VaultWarden for password/passkey management and integrated with OpenLDAP and FreeRADIUS for organizational account management.
     - Coupled with a NATS User through Ldap association

### Key Management Practices
   - **[Regulatory Compliance](./regulatory.md)** 
   - **Key Rotation and Renewal:**
     - **SSL Certificates**: Renew every 5 years.
     - **Other Keys (e.g., GPG, SSH)**: Rotate every 2 years.
     - **Emergency Rotation**: In case of a security breach, immediate rotation of affected keys.
   - **Secure Storage**:
     - Use YubiKeys to store and manage root keys securely.
     - VaultWarden serves as a central passkey/password manager for individuals, with access controlled through YubiKey.
     - Sensitive keys (e.g., Certify Keys) are stored in a secure environment, offline when not in use.
     - All keys in use are revocable and renewable.

   - **Key Generation and Usage**:
     - Use strong cryptographic standards for key generation (e.g., ECC P-256).
     - Ensure all keys generated through GPG, SSH, and other protocols adhere to best practices for strength and entropy.
   - **Authentication and Authorization**:
     - NATS and JWT are used for message-based authentication and stateless authorization.
     - TLS and X.509 are used to establish secure communication channels.
   - **GPG-Agent and SSH Configuration**:
     - Utilize `gpg-agent` as an SSH agent to enable encrypted connections.
     - Maintain configurations to automatically lock and expire sessions after periods of inactivity.

### Access Control and Distribution
   - **Fido2**:
     - Passkey integration with Vaultwarden
   - **OpenLDAP and FreeRADIUS Integration**:
     - Manage organizational accounts and enforce policies using OpenLDAP and FreeRADIUS.
     - Utilize FreeRADIUS to authenticate YubiKeys and user credentials.
   - **Policy Enforcement**:
     - All key usage must adhere to CIM’s access control policies.
     - Periodic audits to ensure compliance with key management policies.

### Operational Procedures
   - **Key Creation and Distribution**:
     - Certify Keys and derived keys are created by security personnel in a controlled environment.
     - YubiKeys are provisioned with required keys and distributed to authorized users securely.
     - Vaultwarden is the primary user interface
   - **Renewal and Revocation**:
     - Schedule and track key renewal dates.
     - Implement a clear revocation process for compromised or obsolete keys using GPG’s revocation mechanisms.
   - **Backup and Recovery**:
     - Back up all Certify Keys and critical derived keys.
     - Utilize secure, encrypted storage for key backups.
   - **Monitoring and Auditing**:
     - Regularly review logs for key usage and access attempts.
     - Perform audits to verify adherence to key management policies and identify any irregularities.

### Integration
   - **VaultWarden**:
     - Serve as the primary passkey and password manager, tightly integrated with YubiKeys for enhanced security.
   - **NATS & JWT**:
     - NATS (Messaging) and JWT (REST Authorization) will ensure robust message and access security across systems.
   - **TLS/SSL & X.509**:
     - Ensure secure communication channels through the use of strong TLS protocols and X.509 certificates.
