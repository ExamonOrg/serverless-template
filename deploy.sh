cd handlers/get_questions
make --file=../lambda.mk package_name=get_questions.zip build

cd ../get_tags
make --file=../lambda.mk package_name=get_tags.zip build

cd ../../terraform_app
terraform init
terraform plan -out=plan.out
terraform apply plan.out
