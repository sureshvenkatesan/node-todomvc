# Repository Environment Update Script

## Overview

The `update_repo_environments.sh` script is a Bash utility that automates the process of updating repository environments in JFrog Artifactory using the JFrog CLI. It fetches the current repository configuration, modifies it to include specified environments, and updates the repository via the Artifactory REST API.

## Features

- **Automated Configuration Management**: Fetches and updates repository configurations without manual JSON editing
- **Environment List Support**: Supports single or multiple environments (comma-separated)
- **Error Handling**: Comprehensive error checking and validation
- **Safe Operations**: Uses temporary files and proper cleanup
- **JSON Processing**: Properly formats environment lists as JSON arrays using `jq`

## Prerequisites

Before using this script, ensure you have:

1. **JFrog CLI** installed and configured
2. **jq** (JSON processor) installed
3. **Bash** shell environment
4. **Valid Artifactory server configuration** with the specified server-id

### Installing Prerequisites

#### JFrog CLI
```bash
# macOS (using Homebrew)
brew install jfrog-cli

# Linux
curl -fL https://install-cli.jfrog.io | sh

# Windows
# Download from https://jfrog.com/getcli/
```

#### jq (JSON processor)
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

## Usage

### Basic Syntax
```bash
./update_repo_environments.sh <server-id> <repository-name> <environment-list>
```

### Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `server-id` | The JFrog Artifactory server identifier | `psazuse` |
| `repository-name` | Name of the repository to update | `lab110-npm-dev-local` |
| `environment-list` | Comma-separated list of environments | `"DEV"` or `"DEV,PROD"` |

### Examples

#### Single Environment
```bash
./update_repo_environments.sh psazuse lab110-npm-dev-local "DEV"
```

#### Multiple Environments
```bash
./update_repo_environments.sh psazuse lab110-npm-dev-local "DEV,PROD"
```

#### With Spaces in Environment Names
```bash
./update_repo_environments.sh psazuse lab110-npm-dev-local "DEV,STAGING,PRODUCTION"
```

## How It Works

1. **Validation**: Checks that exactly 3 arguments are provided
2. **Configuration Fetch**: Retrieves current repository configuration using `jf rt curl -XGET`
3. **JSON Processing**: Converts comma-separated environment list to JSON array format
4. **Configuration Update**: Modifies the JSON to include the `environments` field
5. **Repository Update**: Posts the updated configuration using `jf rt curl -XPOST`
6. **Cleanup**: Removes temporary files

## Output

### Success Example
```
Updating repository 'lab110-npm-dev-local' on server 'psazuse' with environments: DEV
Fetching current repository configuration...
Updating configuration with environments: ["DEV"]
Updating repository configuration...
Successfully updated repository 'lab110-npm-dev-local' with environments: DEV
Repository update completed successfully!
```

### Error Examples
```
Usage: ./update_repo_environments.sh <server-id> <repository-name> <environment-list>
Example: ./update_repo_environments.sh psazuse lab110-npm-dev-local "DEV"
```

```
Error: Failed to fetch repository configuration for 'non-existent-repo'
```

## Error Handling

The script includes comprehensive error handling for:

- **Invalid Arguments**: Incorrect number of parameters
- **Repository Not Found**: Non-existent repository names
- **API Failures**: Network issues or authentication problems
- **JSON Processing Errors**: Invalid JSON responses
- **File Operations**: Temporary file creation/deletion issues

## Troubleshooting

### Common Issues

#### 1. "Command not found: jf"
**Solution**: Install JFrog CLI and ensure it's in your PATH

#### 2. "Command not found: jq"
**Solution**: Install jq JSON processor

#### 3. "Failed to fetch repository configuration"
**Possible Causes**:
- Repository doesn't exist
- Invalid server-id
- Authentication issues
- Network connectivity problems

**Solutions**:
- Verify repository name and server-id
- Check JFrog CLI configuration: `jf c show`
- Test connectivity: `jf rt ping --server-id=<server-id>`

#### 4. "Permission denied"
**Solution**: Make script executable:
```bash
chmod +x update_repo_environments.sh
```

### Debug Mode

To see more detailed output, you can modify the script to include debug information by adding `set -x` at the beginning of the script.

## Security Considerations

- The script uses temporary files that are automatically cleaned up
- No sensitive information is logged to console
- API credentials are handled by JFrog CLI configuration
- Temporary files are created with secure permissions

## Limitations

- Requires JFrog CLI to be properly configured
- Depends on `jq` for JSON processing
- Only updates the `environments` field (other fields remain unchanged)
- Requires appropriate permissions on the target repository

## Contributing

To improve this script:

1. Add additional validation for environment names
2. Support for different output formats
3. Dry-run mode for testing
4. Backup functionality before updates
5. Support for batch processing multiple repositories

## License

This script is provided as-is for educational and operational purposes.

## Support

For issues related to:
- **Script functionality**: Check this README and error messages
- **JFrog CLI**: Refer to [JFrog CLI documentation](https://jfrog.com/getcli/)
- **Artifactory API**: Refer to [Artifactory REST API documentation](https://jfrog.com/help/r/jfrog-rest-apis/artifactory-rest-apis) 