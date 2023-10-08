cd lambdas
terraform init
terraform plan -out=plan.out
terraform apply plan.out

cd ../rest_open_api
terraform init
terraform plan -out=plan.out
terraform apply plan.out