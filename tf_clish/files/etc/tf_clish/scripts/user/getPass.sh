#!/bin/bash

echo "Enter user password:"
read -s  password
echo "Password entered -->  " "${password}"

/etc/tf_clish/scripts/user/config_user.lua "${1}" "${2}" "${password}" ${3}