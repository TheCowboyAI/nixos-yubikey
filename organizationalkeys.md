# Organizational Keys
Creating a Key Structure is the single most critical thing you will do in Organizational IT.

>How do I handle "Secrets"?

We will create the identification hierarchy of entire systems. It is also how everything gets encrypted and decrypted.

Organizations need keys that are structured in an organizational hierarchy and persisted in a way they are accessible, but still secure.

## Why do I want Organizational Keys?
Organizational Keys act as an Authoritative Structure to not only help with Security, but also to trace interaction.

Organizations do not make decisions, people do.

For this reason, all Personal Keys are Certified by the Organizational CertifyKey as well as signed by the Organizational Signing Key.

Here is the Organizational Structure:

Org
  OrgId
  OrgName
  DomainName

CertifyKey
  AuthorizeKey
  SigningKey
  EncryptKey

SSL Root CA
  Wildcard Certificate
  Client Certificate

If you need departments, simply make the Domain Name a subdomain. This applies to any partitioning.

You can make intermediate authorities for the Keys. This lets separate partitions control their own personnel. This is a decision that should be wholly based on your Domain.

It is a conscious decision to directly relate "Internet Domain Names" to logical "Domain Names".

They allow us to use an already established methodology that is well suited to our purpose.

Everything distills to JSON.
This is our data structure Least Common Denominator.
Everything can traslate to or from JSON.

It allows us to store structured infomation in a way we can traslate to anything else.

# Structured Key Map
Our Key Map is:

Pass Phrase
