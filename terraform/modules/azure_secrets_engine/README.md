


export AZURE_CREDS_FILE=$HOME/.Azure/creds2.txt
export TF_VAR_ARM_SUBSCRIPTION_ID=14692f20-9428-451b-8298-102ed4e39c2a
export TF_VAR_ARM_TENANT_ID=$(jq -r .tenant $AZURE_CREDS_FILE)
export TF_VAR_ARM_CLIENT_SECRET=$(jq -r .password $AZURE_CREDS_FILE)
export TF_VAR_ARM_CLIENT_ID=$(jq -r .appId $AZURE_CREDS_FILE)

export AZURE_CREDS_FILE=$HOME/.Azure/creds2.txt
export TF_VAR_subscription_id=14692f20-9428-451b-8298-102ed4e39c2a
export TF_VAR_tenant_id=$(jq -r .tenant $AZURE_CREDS_FILE)
export TF_VAR_client_secret=$(jq -r .password $AZURE_CREDS_FILE)
export TF_VAR_client_id=$(jq -r .appId $AZURE_CREDS_FILE)