# Auto Generate and Upload GPG Key for JFrog Distribution RBv2

[auto_generate_upload_gpg_key.sh](auto_generate_upload_gpg_key.sh) is a streamlined script that automatically generates a GPG key pair and uploads it directly to JFrog Artifactory in a single operation. This script is designed for automation and CI/CD pipelines where you need to quickly create and register GPG keys for Release Bundle v2 signing.

## Features

- **One-command operation**: Generate and upload GPG keys in a single step
- **Automatic cleanup**: Removes temporary files after upload
- **Optional passphrase protection**: Secure private keys with passphrases
- **Temporary working directories**: Uses system temp directories for security
- **Error handling**: Comprehensive error checking and validation
- **CI/CD friendly**: Non-interactive operation suitable for automation

## Prerequisites

- GPG (GnuPG) installed on your system
- JFrog CLI (`jf`) configured and authenticated
- Bash shell environment
- Write permissions for temporary directories

## Usage

### Basic Usage (No Passphrase)

```bash
./auto_generate_upload_gpg_key.sh <key-name>
```

**Example:**
```bash
./auto_generate_upload_gpg_key.sh my-release-key
```

This will:
- Generate a GPG key pair named "my-release-key"
- Use email "my-release-key@yourdomain.com"
- Create a 4096-bit RSA key with no expiration
- Upload the key pair to Artifactory
- Clean up temporary files

### Usage with Passphrase Protection

To protect your private key with a passphrase, set the `PASSPHRASE` environment variable:

```bash
export PASSPHRASE="your-secure-passphrase"
./auto_generate_upload_gpg_key.sh <key-name>
```

**Example:**
```bash
export PASSPHRASE="MySecurePassphrase123!"
./auto_generate_upload_gpg_key.sh production-key
```

### Inline Passphrase Usage

You can also set the passphrase inline for single commands:

```bash
PASSPHRASE="temporary-passphrase" ./auto_generate_upload_gpg_key.sh test-key
```

## Key Configuration

The script automatically configures the following parameters:

| Parameter | Value | Description |
|-----------|-------|-------------|
| Key Type | RSA | Standard RSA encryption |
| Key Length | 4096 bits | High-security key length |
| Expiration | 0 (no expiration) | Keys never expire |
| Email | `<key-name>@yourdomain.com` | Auto-generated email |
| Alias | `<key-name>` | Same as key name |
| Comment | `<key-name>` | Same as key name |

## Security Considerations

### Passphrase Protection

- **Recommended for production**: Always use a strong passphrase for production keys
- **CI/CD considerations**: Store passphrases securely in your CI/CD system's secrets management
- **Passphrase strength**: Use a combination of uppercase, lowercase, numbers, and special characters
- **Minimum length**: Aim for at least 12 characters

### Temporary File Security

- The script uses system temporary directories (`mktemp -d`)
- GPG home directory permissions are set to 700 (owner read/write/execute only)
- All temporary files are automatically cleaned up after upload
- No sensitive data is left on disk

### Example Security Best Practices

```bash
# For production environments
export PASSPHRASE="$(openssl rand -base64 32)"
./auto_generate_upload_gpg_key.sh production-release-key

# For CI/CD pipelines (using environment variables)
export PASSPHRASE="$GPG_PASSPHRASE_SECRET"
./auto_generate_upload_gpg_key.sh ci-release-key
```

## Output

The script provides clear feedback about the process:

```
Uploading GPG key pair to Artifactory...
Key my-release-key uploaded successfully.
Temporary files cleaned up.
```

## Error Handling

The script includes comprehensive error handling for:

- Missing key name parameter
- GPG key generation failures
- Key export failures
- Upload failures
- Permission issues
- Temporary directory creation failures

## Comparison with generate_rbv2_gpg_key.sh

| Feature | auto_generate_upload_gpg_key.sh | generate_rbv2_gpg_key.sh |
|---------|--------------------------------|---------------------------|
| Operation | Generate + Upload | Generate only |
| Automation | Fully automated | Interactive/non-interactive |
| Cleanup | Automatic | Manual |
| Use case | CI/CD, automation | Manual key management |
| Complexity | Simple | Advanced features |

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   ```bash
   chmod +x auto_generate_upload_gpg_key.sh
   ```

2. **GPG not found**
   ```bash
   # Install GPG on Ubuntu/Debian
   sudo apt-get install gnupg
   
   # Install GPG on CentOS/RHEL
   sudo yum install gnupg
   
   # Install GPG on macOS
   brew install gnupg
   ```

3. **JFrog CLI not authenticated**
   ```bash
   jf c add --url <your-artifactory-url> --user <username> --password <password>
   ```

4. **Passphrase issues**
   - Ensure the passphrase doesn't contain special characters that might interfere with shell interpretation
   - Use quotes around the passphrase if it contains spaces or special characters

### Debug Mode

To see more detailed output, you can modify the script to remove the `-s` flag from the JFrog CLI command:

```bash
# In the script, change this line:
jf rt curl -XPOST "/api/security/keypair" \
```

## Examples

### Development Environment
```bash
# Quick test key without passphrase
./auto_generate_upload_gpg_key.sh dev-test-key
```

### Staging Environment
```bash
# Staging key with simple passphrase
export PASSPHRASE="staging-pass-2024"
./auto_generate_upload_gpg_key.sh staging-key
```

### Production Environment
```bash
# Production key with strong passphrase
export PASSPHRASE="$(openssl rand -base64 32)"
./auto_generate_upload_gpg_key.sh production-key
```

### CI/CD Pipeline Example
```yaml
# Example GitHub Actions workflow
- name: Generate and Upload GPG Key
  env:
    PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
  run: |
    ./auto_generate_upload_gpg_key.sh ${{ github.run_id }}-key
```

## Notes

- The script automatically generates an email address based on the key name
- All temporary files are created in system temp directories for security
- The script exits immediately if any step fails (using `set -euo pipefail`)
- Keys are uploaded with the same name as the key pair name
- No manual intervention is required during execution 