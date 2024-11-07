## Workflow and Domain Events

### Key Creation Workflow

1. **Initiate Key Generation Event**
   - Triggered when a new individual or organization requires keys.
2. **Generate Certify Key**
   - Created in a secure, offline environment.
3. **Generate Subordinate Keys**
   - Signing, Encryption, and Authorization keys are generated.
4. **Certify Subordinate Keys**
   - Subordinate keys are certified by the Certify Key.
5. **Distribute Public Keys**
   - Public keys are added to the active keys list and distributed as necessary.

### Key Usage Workflow

1. **Authentication Event**
   - User or system authenticates using the Authorization Key.
2. **Encryption/Decryption Event**
   - Data is encrypted using the recipient's Encryption Key and decrypted using the private key.
3. **Signing/Verification Event**
   - Data is signed with the Signing Key and verified using the public key.

### Key Renewal Workflow

1. **Expiration Notice Event**
   - System alerts stakeholders of upcoming key expiration (e.g., 30 days prior).
2. **Generate New Keys**
   - New subordinate keys are generated and certified.
3. **Update Active Keys List**
   - New public keys replace old ones in the active keys list.
4. **Notify Stakeholders**
   - Inform relevant parties of key updates.

### Key Revocation Workflow

1. **Compromise Detection Event**
   - Detection of key compromise or loss.
2. **Generate Revocation Certificate**
   - A revocation certificate is created for the compromised key.
3. **Update Active Keys List**
   - Remove the revoked key from the active keys list.
4. **Distribute Revocation Notice**
   - Notify all stakeholders of the revocation.
5. **Key Replacement**
   - Generate and distribute new keys as necessary.

---

## Active Public Keys List

### Maintenance

- **Central Repository:**
  - Maintain an up-to-date repository of all active public keys.
- **Access Control:**
  - Restrict modification access to authorized personnel.
- **Automation:**
  - Utilize scripts or services to automate the updating process upon key events.

### Distribution

- **Accessibility:**
  - Ensure the active keys list is easily accessible for quick verification.
- **Security:**
  - Protect the integrity of the list to prevent tampering.
- **Revocation Updates:**
  - Promptly update the list upon key revocations.
