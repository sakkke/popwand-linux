function error_message {
  local message="$*"
  echo -e "\e[31m$message\e[m"
}

function input_prompt {
  local message="$*"
  echo "$message"
  read -p"$(echo -en '\e[33m->\e[m ')" p
}

function is_number {
  local number="$1"
  grep '^[0-9]\+$' <<< "$number" > /dev/null
}

function list_devices {
  local items=($@)
  echo ${items[@]} \
    | xargs -n1 \
    | nl -s' => ' -v0 \
    | while read a b c; do
        echo -e "\e[34m$a\e[m $b \e[3;32m$c\e[m \e[2;3m/dev/$c\e[m"
      done \
        | column -t \
        | column
}

function select_prompt {
  local kind=$1
  shift
  local items=($@)
  while :; do
    list_$kind $@
    input_prompt Select a device number to install
    if is_number "$p" && [ -v "items[$p]" ]; then
      echo ${items[$p]}
      break
    else
      error_message Invalid value
      echo
    fi
  done
}

devices=($(ls /tmp/dev \
  | grep '^\(mmcblk[0-9]\+\|nvme[0-9]\+n[0-9]\+\|sd[a-z]\+\|sr[0-9]\+\)$' \
  | xargs))

echo Hint: press C-c to cancel the installation process
select_prompt devices ${devices[@]}
device=${devices[p]}
echo
while :; do
  input_prompt Enter name of the new user
  if grep '^[0-9A-Za-z]\{1,8\}$' <<< "$p" > /dev/null; then
    user_name="$p"
    break
  else
    error_message Invalid user name
    echo
  fi
done
echo
echo Default password: p@ssw0rd
echo
echo Installation is complete!