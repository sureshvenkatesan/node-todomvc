#!/bin/bash
set -euo pipefail

# ========== Configurable Inputs ==========
KEY_NAME="${1:-}"
if [ -z "$KEY_NAME" ]; then
  echo "Usage: $0 <key-name>"
  exit 1
fi

EMAIL="${KEY_NAME}@yourdomain.com"
ALIAS="$KEY_NAME"
COMMENT="$KEY_NAME"
KEY_LENGTH=4096
EXPIRE_DATE=0
PASSPHRASE="${PASSPHRASE:-}"  # Optional: set via env var if needed

# ========== Temp Working Directories ==========
GPG_HOMEDIR=$(mktemp -d)
JSON_FILE_PATH=$(mktemp)

# ========== Generate GPG Key ==========
cat > keydetails <<EOF
  %echo Generating a GPG key
  Key-Type: RSA
  Key-Length: $KEY_LENGTH
  Subkey-Type: RSA
  Subkey-Length: $KEY_LENGTH
  Name-Real: $ALIAS
  Name-Comment: $COMMENT
  Name-Email: $EMAIL
  Expire-Date: $EXPIRE_DATE
EOF

if [ -n "$PASSPHRASE" ]; then
  echo "  Passphrase: $PASSPHRASE" >> keydetails
else
  echo "  %no-ask-passphrase" >> keydetails
  echo "  %no-protection" >> keydetails
fi

cat >> keydetails <<EOF
  %commit
  %echo done
EOF

mkdir -p "$GPG_HOMEDIR"
chmod 700 "$GPG_HOMEDIR"
gpg --homedir "$GPG_HOMEDIR" --batch --gen-key keydetails
rm -f keydetails

# ========== Extract Key ID ==========
KEY_ID=$(gpg --homedir "$GPG_HOMEDIR" --list-keys --with-colons "$EMAIL" | grep '^pub' | cut -d':' -f5 | head -n1)

# ========== Export Keys ==========
if [ -n "$PASSPHRASE" ]; then
  PRIV_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --pinentry-mode loopback --passphrase "$PASSPHRASE" --export-secret-keys "$KEY_ID")
else
  PRIV_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export-secret-keys "$KEY_ID")
fi

PUB_KEY=$(gpg --armor --homedir "$GPG_HOMEDIR" --export "$KEY_ID")

# ========== Prepare JSON ==========
PRIV_KEY_ESC=$(printf "%s" "$PRIV_KEY" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
PUB_KEY_ESC=$(printf "%s" "$PUB_KEY" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

cat >"$JSON_FILE_PATH" <<EOF
{
  "pairName": "$KEY_NAME",
  "pairType": "GPG",
  "alias": "$ALIAS",
  "privateKey": "$PRIV_KEY_ESC",
  "publicKey": "$PUB_KEY_ESC",
  "passphrase": "$PASSPHRASE"
}
EOF

# ========== Upload to Artifactory ==========
echo "Uploading GPG key pair to Artifactory..."
jf rt curl -s -XPOST "/api/security/keypair" \
  -H 'Content-Type: application/json' \
  --data-binary @"$JSON_FILE_PATH"

echo "Key $KEY_NAME uploaded successfully."

# ========== Cleanup ==========
rm -rf "$GPG_HOMEDIR" "$JSON_FILE_PATH"

echo "Temporary files cleaned up."
