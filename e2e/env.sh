
export API_KEY=$(terraform -chdir=../terraform/site output -raw api_key_value)
export INVOKE_URL=$(terraform -chdir=../terraform/site output -raw invoke_url)
export AWS_ACCESS_KEY_ID="AKIAW6URCXUWU4NYS5NP"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_REGION="eu-west-1"