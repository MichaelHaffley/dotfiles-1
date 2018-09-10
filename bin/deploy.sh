#!/usr/bin/env bash
#
# ./deploy.sh hostname branch/tag
#
# Examples:
#
#   Deploy master to qa.local prod
#   ./deploy.sh atl1q39tacow01
#
#   Deploy branch W-4283621  to qa.local prod
#   ./deploy.sh atl1q39tacow01 W-4283621
#
#   Deploy tag 4.12.0  to qa.local prod
#   ./deploy.sh atl1q39tacow01 tags/4.12.0


error_exit() {
    echo "${REV}FAILED TO DEPLOY${NORMAL}"
    exit 1
}

readonly TARGET_HOST=$1
readonly BRANCH_TAG="${2:-master}"
if [ -d $TARGET_HOST ]; then
  pushd $TARGET_HOST
  TARGETS=`ls -dr1 *`
  echo "0. Appling deploy of $BRANCH_TAG to $TARGETS"
  popd
else
  echo "$TARGET_HOST deploy directory not found"
  error_exit
fi

if [[ $TARGET_HOST == atl* ]]; then
  DOMAIN="qa.local"
  USER="tacossvc@${DOMAIN}"
  TARGET_SSH="${USER}@${DOMAIN}@${TARGET_HOST}.${DOMAIN}"
  SSH_OPTIONS=""
  SCP_OPTIONS=""
elif [ "$TARGET_HOST" = "localhost" ]; then
  DOMAIN=""
  USER="phaffley"
  TARGET_SSH="${USER}@127.0.0.1"
  SSH_OPTIONS="-p2222"
  SCP_OPTIONS="-P 2222"
else
  DOMAIN="et.local"
  USER="tacos@${DOMAIN}"
  TARGET_SSH="${USER}@${DOMAIN}@${TARGET_HOST}.${DOMAIN}"
  SSH_OPTIONS=""
  SCP_OPTIONS=""
fi

# Function borrowed from internet to determine current working directory
get_script_dir () {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$( readlink "$SOURCE" )"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    $( cd -P "$( dirname "$SOURCE" )" )
    pwd
}

# From the current directory calculate service name "SchedulingService"
readonly SCRIPT_DIR="$(get_script_dir)"
readonly DEPLOY_DIR="${HOME}/deploy"
readonly GIT_TEAM_REPO="git@github.exacttarget.com:QE-Automation"

readonly NORMAL=`tput rmso`
readonly REV=`tput rev`

remote_copy() {
  local level=$1
  local file=$2
  local remote_dir=$3

  echo "${REV}${level} scp -r $SCP_OPTIONS $file $TARGET_SSH:$remote_dir/$file${NORMAL}"
  scp -r $SCP_OPTIONS $file $TARGET_SSH:$remote_dir/$file || error_exit
}

remote_command() {
  local level=$1
  local dir=$2
  local cmd=$3

  echo "${REV}${level} $SSH_OPTIONS $TARGET_SSH \"cd $dir;$cmd\"${NORMAL}"
  ssh -t $SSH_OPTIONS $TARGET_SSH bash -c "cd $dir;$cmd" || error_exit
}

refresh_deploy_dir() {
  local level=$1

  echo "${REV}${level} remove old deploy${NORMAL}"
  rm -rf $DEPLOY_DIR
  mkdir -p $DEPLOY_DIR
}

git_dir() {
  local level=$1
  local target=$2
  local target_dir=$3

  echo "${REV}${level} git clone ${GIT_TEAM_REPO}/${target}.git ${target_dir}${NORMAL}"
  rm -rf ${target_dir}
  git clone ${GIT_TEAM_REPO}/${target}.git ${target_dir} || error_exit
}

update_branch_or_tag() {
  local level=$1
  local dir=$2

  echo "${REV}${level} update to tag or branch: ${BRANCH_TAG}${NORMAL}"
  pushd $dir
  git checkout $BRANCH_TAG
  rm -rf .git
  popd
}

copy_config_files() {
  local level=$1
  local target=$2
  local target_dir=$3

  echo "${REV}${level} cp -rf \"${SCRIPT_DIR}/${TARGET_HOST}/${target}\" \"${target_dir}/script/${TARGET_HOST}\"${NORMAL}"
  # mkdir -p "${dir}/script/${TARGET_HOST}"
  cp -rf "${SCRIPT_DIR}/${TARGET_HOST}/${target}" "${target_dir}/script/${TARGET_HOST}"
}

deploy() {

  refresh_deploy_dir "1."
  pushd $DEPLOY_DIR
  for target in $TARGETS; do
    if [[ $target == Icon* ]]; then
      echo "Skipping $target"
    else
      target_dir=$(mktemp $target.XXXXXXXXXXXXXX)
      git_dir "<$target> 2." $target $target_dir
      update_branch_or_tag "<$target> 3." $target_dir
      copy_config_files "<$target> 4." $target $target_dir
      remote_copy "<$target> 5." $target_dir "."
      remote_command "<$target> 5." "." "sudo ./${target_dir}/script/install.sh ${target_dir}"
    fi
  done
  popd
}

deploy
