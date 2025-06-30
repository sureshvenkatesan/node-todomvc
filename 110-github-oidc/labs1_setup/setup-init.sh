#!/bin/bash

exec 2>&1
exec > /tmp/lab-setup.out

source /root/.bashrc

log_error () {
    echo -e "[`date`]\033[31mERROR: $1\033[0m"
}

log_task () {
    echo -e "[`date`]\033[32mTASK: $1\033[0m"
}

log_task "Started Lab setup"

cd jfrog

snap install jq
log_task "Installed jq"

# Wait for Artifactory
while [ true ]
do
    wget http://academy-artifactory  > /dev/null 2>&1
    if [ $? -eq 0 ]
    then   
        break
    fi
done
log_task "Artifactory is responding"

while [ true ]
do
    jf config add  academy --url=http://academy-artifactory --user=admin --password=Admin1234! --interactive=false
    if [ $? -eq 0 ]
    then
        break
    fi
    sleep 20
done
log_task "JF Config executed"

jf rt curl \
    -X PATCH \
    -H "Content-Type: application/yaml" \
    -T 110-github-oidc/labs1_setup/lab110-repo-npm-def-all.yaml \
     "api/system/configuration" --server-id=academy

log_task "Repositories created"

chmod +x 110-github-oidc/labs1_setup/update_repo_environments.sh

curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer  $JFROG_ACCESS_TOKEN" \
  -d '{"name": "QA"}' \
  "http://academy-artifactory/access/api/v1/environments"

log_task "Environment QA created"

log_task "Updating repository environments"

bash 110-github-oidc/labs1_setup/update_repo_environments.sh academy lab110-npm-dev-local DEV
bash 110-github-oidc/labs1_setup/update_repo_environments.sh academy lab110-npm-prod-local PROD
bash 110-github-oidc/labs1_setup/update_repo_environments.sh academy lab110-npm-qa-local QA

log_task "Repositories Assigned to environments"

DEFAULT_SIGNING_KEY="default-signing-key"

read -p "Enter RBV2 Signing key [${DEFAULT_SIGNING_KEY}]: " RBV2_SIGNING_KEY

# Use default if input is empty
RBV2_SIGNING_KEY="${RBV2_SIGNING_KEY:-$DEFAULT_SIGNING_KEY}"

export RBV2_SIGNING_KEY

110-github-oidc/labs2_RBv2/auto_generate_upload_gpg_key.sh "$RBV2_SIGNING_KEY"
log_task "GPG Key generated and uploaded to Artifactory for RBv2 signing"