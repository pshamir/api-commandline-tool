#!/bin/bash

download_list() {
  local FILES
  local DELIMITER='"filename":'
  local ENTRY
  local DOWNLOADFILES="https://download.appdynamics.com/download/downloadfilelatest/"
  local FILTER='.*'
  local BREAKONFIRST=0
  while getopts "1df:s:" opt "$@";
  do
    case "${opt}" in
      d)
        DELIMITER='"download_path":'
      ;;
      f)
        FILTER="${OPTARG}"
      ;;
      s)
        DOWNLOADFILES="https://download.appdynamics.com/download/downloadfile/?format=json&page=1&search=$(urlencode "${OPTARG}")"
      ;;
      1)
        BREAKONFIRST=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  output "Downloading list of available files. Please wait."
  debug "Download URL: ${DOWNLOADFILES}"
  FILES=$(httpClient -s "${DOWNLOADFILES}")
  #delimiter='"download_path":'
  local s=$FILES${DELIMITER}
  COMMAND_RESULT=""
  while [[ $s ]]; do
    ENTRY="${s%%"${DELIMITER}"*}\n\n"
    if [ "${ENTRY:0:1}" == "\"" ] ; then
	    ENTRY=${ENTRY:1}
      ENTRY=${ENTRY%%\",*}
      if [[ "${ENTRY}" =~ ${FILTER} ]] ; then
	       COMMAND_RESULT="${COMMAND_RESULT}${ENTRY}${EOL}"
         if [ "${BREAKONFIRST}" -eq 1 ] ; then
           return
         fi;
      else
        debug "${ENTRY} does not match ${FILTER}"
      fi;
    fi;
    s=${s#*"${DELIMITER}"};
  done;
}
rde download_list "List agent files." "You can provide a filter (-f) to filter for specific agent files. Or you can provide a search query (-s) to execute . Provide parameter -d to get the full download path" "-d -f golang"
