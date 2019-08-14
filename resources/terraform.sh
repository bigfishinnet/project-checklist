# Wrapper for Terraform
#!/bin/bash -e

while getopts "a::c:e:g:p:s:r:b:" arg; do
  case $arg in
    a)
      ACTION=$OPTARG
      ;;
    c)
      COMPONENT=$OPTARG
      ;;
    e)
      ENVIRONMENT=$OPTARG
      ;;
    g)
      GROUP=$OPTARG
      ;;
    p)
      PROJECT=$OPTARG
      ;;
    s)
      STATE_STORAGE=$OPTARG
      ;;
    r)  
      REGION=$OPTARG
      ;;
    b)
      BOOTSTRAP=$OPTARG
      ;;
  esac
done

echo "BOOTSTRAP: ${BOOTSTRAP}"
# Setting defaults if getopts is not providing anything. 
ACTION=${ACTION:-'plan'}
REGION=${REGION:-'eu-west-1'}
STATE_STORAGE=${STATE_STORAGE:-'mapcourse-137003653577-eu-west-1-bootstrap'}
BOOTSTRAP=${BOOTSTRAP:-'false'}
if [ "x" == "x$COMPONENT" ] || [ "x" == "x$ENVIRONMENT" ] || [ "x" == "x$GROUP" ] || [ "x" == "x$PROJECT" ]; then 
    echo "You have to specify COMPONENT, ENVIRONMENT, GROUP, PROJECT"
    exit 1
fi

cd ${0%/*}
# If You dont want to download this each  time just comment out next two lines. 
rm -rfv $(pwd)/tfenv
git clone https://github.com/kamatama41/tfenv.git $(pwd)/tfenv

cd components/$COMPONENT
../../tfenv/bin/tfenv install

if [ $BOOTSTRAP = 'false' ]; then 
backend_config="terraform {
  backend \"s3\" {
    bucket = \"${STATE_STORAGE}\"
    key = \"${PROJECT}/${COMPONENT}/${ENVIRONMENT}\"
    region = \"${REGION}\"
  }
}";
echo -e "${backend_config}" > ./backend-config.tf
cat ./backend-config.tf
fi

../../tfenv/bin/terraform init -reconfigure
if [ $ACTION = 'plan' ]; then
../../tfenv/bin/terraform ${ACTION} -var-file=../../config/global.tfvars -var-file=../../config/group_${GROUP}.tfvars -var-file=../../config/env_eu-west-1_${ENVIRONMENT}.tfvars
else 
../../tfenv/bin/terraform ${ACTION} -var-file=../../config/global.tfvars -var-file=../../config/group_${GROUP}.tfvars -var-file=../../config/env_eu-west-1_${ENVIRONMENT}.tfvars -auto-approve
fi
# Cleanup.
rm -rfv ./backend-config.tf
rm -rfv ./terraform