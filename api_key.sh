cd terraform/site

INVOKE_URL=$(terraform output -raw invoke_url)

echo "curl" ${INVOKE_URL}v1/pets"
echo "curl" ${INVOKE_URL}v1/pet"
echo "curl -X POST -d '{\"name\":\"Fido\", \"breed\":\"doberman\"}' ${INVOKE_URL}v1/pet"
echo "curl -X DELETE -d '{\"id\": \"<id>\"}' ${INVOKE_URL}v1/pet"
echo "curl -X PUT -d '{\"name\":\"<value>\", \"breed\":\"<value>\", \"id\": \"<id>\"}' ${INVOKE_URL}v1/pet"