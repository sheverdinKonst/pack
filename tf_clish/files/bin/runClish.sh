#!/bin/bash

export CLISH_PATH=/etc/tf_clish/menu_config_xml
if [[ "${CLISH_PATH}" != "/etc/tf_clish/menu_config_xml" ]]; then
        echo "CLISH_PATH not set"
else
        clish
fi

