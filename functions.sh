function findOrPrompt() {
  local varName="$1"
  local prompt="$2"

  if [[ -z "${!varName}" ]]
  then
    read -p "$prompt: " $varName
  else
    echo "Value for $varName found in environment"
  fi
}

function banner() {
  echo "###"
  echo "### $(date)"
  echo "### $*"
  echo "###"
  echo ""
}

function prompt() {
  local prompt="$2"

  read -p "$prompt: " resp
  echo "$resp"
}

# Wait until there is no (non-error) output from a command
function waitForRemoval() {
  while [[ -n $("$@" 2> /dev/null || true) ]]
  do
    message "Waiting for resource to disappear ..."
    sleep 5
  done
}

