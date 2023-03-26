#!/bin/bash

WHITE="\033[1;37m"
RED="\033[0;31m"
RESET_COLOR="\033[0m"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

################## ARGUMENTS

while [ ! -z "$1" ]; do
  case "$1" in
  --username | -n)
    shift
    USERNAME=$1
    ;;
  --token | -c)
    shift
    TOKEN=$1
    ;;
  --clean | -c)
    shift
    CLEAN=$1
    ;;
  *) ;;
  esac
  shift
done

################## PRINT

echo ""
echo -e "${GREEN}##################################################################################${RESET_COLOR}"
echo -e "${YELLOW}# cloning with username ${GREEN}$USERNAME ${WHITE} token ${GREEN}$TOKEN ${WHITE}${RESET_COLOR}"
echo -e "${GREEN}##################################################################################${RESET_COLOR}"
echo ""

################## ORGANIZATION

declare -a organizations=($(curl -H "Authorization: token $TOKEN" https://api.github.com/user/orgs | jq -r '.[].login'))

################## DIRECTORY

if [[ -d "$USERNAME" ]]; then
  rm -rf $USERNAME
fi

################## PWD

ROOT_PATH=$(pwd)
mkdir "$USERNAME"
cd $USERNAME
MAIN_ORG_PATH=$(pwd)

################## CLONING

for ((i = 0; i < ${#organizations[@]}; i++)); do
  echo -e "${GREEN}====================================================${RESET_COLOR}"
  echo -e "${GREEN}organization => ${YELLOW}${organizations[$i]}${RESET_COLOR}"
  echo -e "${GREEN}====================================================${RESET_COLOR}"
  declare -a orgArray=($(curl -X GET -u $USERNAME:$TOKEN https://api.github.com/orgs/${organizations[$i]}/repos | jq -r '.[]|.ssh_url'))
  if [ -z "$orgArray" ]; then
    echo -e "${RED}organization => ${organizations[$i]} does not have any repos ${RED}skipping${RESET_COLOR}"
    echo ""
  else
    wget -qO- https://raw.githubusercontent.com/xotoscript/xotoscript-git-orgclone/development/install.sh | bash -s -- --token $TOKEN --username $USERNAME --clean $CLEAN --organization ${organizations[$i]}
  fi
  cd "${MAIN_ORG_PATH}"
done

################## PRINT
echo ""
echo -e "${GREEN}#############################################${RESET_COLOR}"
echo -e "${YELLOW}# FINISHED WITH PROCESS ${RESET_COLOR}"
echo -e "${GREEN}#############################################${RESET_COLOR}"
echo ""
cd "${ROOT_PATH}"
rm -rf $USERNAME

