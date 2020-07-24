#!/bin/bash
if [[ ${INSPECTOR} == 1 ]]
then
  curl -o ~/inspector -L https://inspector-agent.amazonaws.com/linux/latest/install
  chmod +x ~/inspector
  ~/inspector >~/inspector.log 2>~/inspector.log
fi

