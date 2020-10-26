stage_variables_as_json=$(aws apigateway get-stage --rest-api-id=$1 --stage-name=$2 --region=$3 --query=variables --output=json)
if [[ $stage_variables_as_json == *'"version"'* ]] ;
then
   echo $stage_variables_as_json
else
   echo '{"version":""}'
fi