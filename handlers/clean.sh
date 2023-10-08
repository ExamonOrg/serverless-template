cd get_questions
make --file=../lambda_python.mk package_name=get_questions.zip clean

cd ../get_tags
make --file=../lambda_python.mk package_name=get_tags.zip clean

cd ../hello
make --file=../lambda_node.mk package_name=hello.zip clean