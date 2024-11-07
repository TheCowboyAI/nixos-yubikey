# Usage
Upon creation of the Yubikey, How do I use it with NixOS?

# Key Management Plan for CIM

## Introduction

### Purpose

The purpose of this Key Management Plan is to establish a comprehensive framework for managing cryptographic keys within the CIM (Company/Community Identity Management) system. This plan outlines the policies, procedures, and workflows for key creation, usage, renewal, and revocation, ensuring the security and integrity of our systems and communications.

### Scope

This plan applies to all cryptographic keys used within the CIM system, including those for individuals, organizations, servers, and clients. It encompasses technologies such as GPG, SSH, SSL/TLS certificates, YubiKeys, NATS, and JWT.

### Policies
You will also need a set of [Policies](./policies.md) that respects this.

---

## Technologies Used

- **GPG (GNU Privacy Guard):** Used for encryption and signing of data and communications.
- **gpg-agent:** A daemon to manage private keys independently of any protocol.
- **SSH (Secure Shell):** Provides secure remote login and other secure network services.
- **SSL/TLS (Secure Sockets Layer/Transport Layer Security):** Protocols for encrypting information over the internet.
- **X.509 Certificates:** Standard defining the format of public-key certificates.
- **Passkeys:** Passwordless authentication mechanisms.
- **YubiKey:** Hardware authentication device used for securing access.
- **NATS:** A connective technology for adaptive edge and distributed systems.
- **JWT (JSON Web Tokens):** A compact URL-safe means of representing claims to be transferred between two parties.
- **PAM:** Pluggable Authentication Modules for integrating multiple authentication technologies.
- **RADIUS:** Protocol for remote user authentication and accounting.
- **IPA Server:** Provides centralized authentication, policy, and authorization.
- **Git:** Version control system for tracking changes in source code.
- **NGINX:** Web server and reverse proxy server.

---

## Key Types and Hierarchies

### Certify Key (Master/Root Key)

- **Description:** The primary key for individuals and organizations, used to certify subordinate keys.
- **Purpose:** Acts as a root of trust incorporated into all GPG keys.
- **Usage:** Not used for daily operations; kept offline to prevent compromise.

### Subordinate Keys

Derived from the Certify Key:

- **Signing Key:**
  - Used for signing documents, code, and communications.
- **Encryption Key:**
  - Used for encrypting data and communications.
- **Authorization Key:**
  - Used for authentication and access control mechanisms.

From these keys, we also generate other subkeys which have limited lifetimes.

### SSL/TLS Certificates

- **Self-Signed Root CA:**
  - Serves as the root Certificate Authority.
  - Used to issue subordinate certificates.
- **Wildcard Domain Certificate:**
  - Covers all subdomains of a domain.
  - Used for securing web services.
- **Client Certificate:**
  - Used for mutual TLS authentication between clients and servers.

---

## Key Lifecycle Management

### Creation

- **Certify Key Generation:**
  - Generated in a secure, offline environment.
  - Stored securely, preferably in hardware security modules (HSM) or encrypted storage.
- **Subordinate Key Generation:**
  - Generated and certified by the Certify Key.
  - Stored securely, with private keys protected by passphrases or hardware tokens like YubiKey.

### Usage

- **Operational Keys:**
  - Signing, Encryption, and Authorization keys are used in day-to-day operations.
  - Access controlled through gpg-agent and ssh-agent.

### Renewal/Rotation

- **SSL Certificates:**
  - Renewed every **5 years**.
- **Other Keys:**
  - Rotated every **2 years**.
- **Process:**
  - Initiate renewal process before the expiration date.
  - Generate new keys and certify them with the Certify Key.
  - Distribute new public keys and update the active keys list.

### Revocation

- **Trigger Events:**
  - Key compromise, loss, or suspected unauthorized access.
- **Process:**
  - Generate a revocation certificate.
  - Update the active keys list to reflect revocation.
  - Notify all relevant parties of the revocation.
  - Replace the revoked key with a new key as necessary.

---

### [Workflow](./workflow.md)

---

## Security Considerations

### Private Key Storage

- **Encryption:**
  - Encrypt private keys with strong passphrases.
- **Hardware Tokens:**
  - Use YubiKeys to store private keys securely.
- **Physical Security:**
  - Store Certify Keys and root CA keys in secure, offline locations.
---

## Integration with Applications

### Agent Usage

- **gpg-agent and ssh-agent:**
  - Use agents to manage keys securely in memory.
- **Timeouts:**
  - Configure agents with appropriate timeouts to minimize risk.

### YubiKey Usage

- **Two-Factor Authentication:**
  - Require YubiKey for accessing critical systems and VaultWarden.
- **Key Storage:**
  - Store private keys on YubiKey where possible to prevent extraction.

## YubiKey and VaultWarden Integration

- **YubiKey:**
  - Used for two-factor authentication and storing private keys securely.
- **VaultWarden:**
  - A self-hosted password/passkey manager.
- **Integration:**
  - YubiKey is coupled with VaultWarden to enhance security for password and passkey management.
  - `Yubico Authenticator` is a TOTP system frequently used for 2FA, this allows for Yubikey touch rather than copy/pasting codes
  - Eliminates sms clear text 2FA codes

### NATS

- **Authentication:**
  - Use Authorization Keys for authenticating connections.
  - Every Message in a CIM is Zero Trust, meaning it requires an authentication key.
- **Encryption:**
  - Ensure data transmitted via NATS is encrypted using an Encryption Key.
  - this can be either specified for a message or for a channel, all traffic is already encrypted communications, this means further encrypting the data sent

### JWT

- **Token Signing:**
  - Use the Signing Key to sign JWTs.
  - The most likely way to interact with NATS
- **Token Verification:**
  - Distribute the corresponding public keys for token verification.

---

## Integration with Applications

### PAM (Pluggable Authentication Modules)

- **Authentication Mechanism:**
  - Implement PAM modules that utilize GPG keys or YubiKey-based authentication.
- **Configuration:**
  - Configure PAM to authenticate users using Authorization Keys stored on YubiKeys.
- **Security Enhancements:**
  - Enforce multi-factor authentication by combining YubiKey with passphrases.
- **Key Management:**
  - Align PAM authentication keys with the Key Lifecycle Management policies for rotation and revocation.

### RADIUS (Remote Authentication Dial-In User Service)

- **Authentication and Authorization:**
  - Use Authorization Keys to authenticate users connecting via RADIUS.
- **Encrypted Communication:**
  - Secure RADIUS communications with SSL/TLS using certificates issued by the Root CA.
- **Integration:**
  - Configure RADIUS server to authenticate users against centralized key repositories.
- **Key Updates:**
  - Ensure timely updates of keys and certificates in RADIUS configurations during rotations and revocations.

### IPA Server (Identity, Policy, and Audit)

- **Centralized Management:**
  - Use IPA Server to manage user identities, policies, and access controls.
- **Certificate Authority Integration:**
  - Integrate IPA Server with the Self-Signed Root CA for certificate issuance and management.
- **Synchronization:**
  - Synchronize key and certificate data between the IPA Server and the Active Public Keys List.
- **Auditing:**
  - Utilize IPA Server's auditing capabilities to monitor key usage and access.

### Git

- **Code Signing:**
  - Developers sign commits and tags using their personal Signing Keys.
- **Repository Authentication:**
  - Use SSH keys derived from Authorization Keys for secure access to Git repositories.
- **Key Rotation Policy:**
  - Enforce rotation of Git SSH keys every **2 years** in line with the Key Lifecycle Management.
- **Access Control:**
  - Manage repository access permissions using keys stored in the Active Public Keys List.

### NGINX

- **SSL/TLS Configuration:**
  - Use the Wildcard Domain Certificate to secure all NGINX-hosted web services.
- **Client Certificate Authentication:**
  - Enable mutual TLS by requiring Client Certificates for sensitive services.
- **Key and Certificate Management:**
  - Store private keys securely with restricted access.
  - Update SSL/TLS certificates according to the **5-year** renewal policy.
- **Performance Optimization:**
  - Utilize SSL/TLS session caching and optimization techniques while maintaining security.

---

## Conclusion

This Key Management Plan provides a structured approach to managing cryptographic keys within the CIM system. By integrating key management practices with applications like PAM, RADIUS, IPA Server, Git, and NGINX, we ensure consistent security measures across all services. Adhering to the outlined policies and workflows guarantees the security, integrity, and reliability of our cryptographic operations.

Regular reviews and updates to this plan should be conducted to adapt to new security challenges and technological advancements. All stakeholders are responsible for familiarizing themselves with this plan and ensuring compliance within their respective areas.

---

**Note:** This plan is to be reviewed annually or upon significant changes to the system architecture or security requirements.