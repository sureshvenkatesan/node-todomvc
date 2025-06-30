#!/bin/bash

exec 2>&1
exec > /tmp/lab-setup.out

log_error () {
    echo -e "[`date`]\033[31mERROR: $1\033[0m"
}

log_task () {
    echo -e "[`date`]\033[32mTASK: $1\033[0m"
}

log_task "Started Lab setup"

cd jfrog

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
    -T 110-github-oidc/labs1/lab110-repo-npm-def-all.yaml \
     "api/system/configuration" --server-id=academy

log_task "Repositories created"

chmod +x 110-github-oidc/labs1/update_repo_environments.sh

bash 110-github-oidc/labs1/update_repo_environments.sh academy lab110-npm-dev-local DEV
bash 110-github-oidc/labs1/update_repo_environments.sh academy lab110-npm-prod-local PROD
bash 110-github-oidc/labs1/update_repo_environments.sh academy lab110-npm-qa-local QA

log_task "Repositories Assigned to environments"


110-github-oidc/labs2_RBv2/auto_generate_upload_gpg_key.sh sureshv-signing-key
log_task "GPG Key generated and uploaded to Artifactory"