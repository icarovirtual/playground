#!/bin/bash
if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo \
""
elif [ $1 == "-z" ]; then
  crontab -r
else
  YT_IMPORT_LOCATION=$HOME/etc/yt_backup/
  YT_URLS_AND_LOCATIONS=${YT_IMPORT_LOCATION}data.txt
  CRON_TEMP=${YT_IMPORT_LOCATION}cron_temp.txt
  DWEEK=6

  while [[ $# > 1 ]]
    do
        key="$1"
        case $key in
            -y)
            YOUTUBE_URL="$2"
            shift
            ;;
            -o)
            OUTPUT="$2"
            shift
            ;;
            -m)
            DMONTH="$2"
            shift
            ;;
            -w)
            DWEEK="$2"
            shift
            ;;
            *)
            # default
            ;;
        esac
        shift
    done

  if [ ! -z ${YOUTUBE_URL} ]; then echo YOUTUBE URL ................. "${YOUTUBE_URL}"; fi
  if [ ! -z ${OUTPUT} ];      then echo OUTPUT PATH ................. "${OUTPUT}"; fi
  if [ ! -z ${DMONTH} ];      then echo DAY OF MONTH ................ "${DMONTH}"; fi
  if [ ! -z ${DWEEK} ];       then echo DAY OF WEEK ................. "${DWEEK}"; fi

  if [ -z ${YOUTUBE_URL} ]; then
    echo "Please provide the Youtube URL with the -y argument"
  elif [ -z ${OUTPUT} ]; then
      echo "Please provide the output location using the -o argument"
  else
    SCHEDULE="* * * * ${DWEEK}"
    if [ ! -z ${DMONTH} ]; then
      SCHEDULE="* * ${DMONTH} * *"
    fi
    echo SCHEDULE .................... "${SCHEDULE}"

    mkdir -p ${YT_IMPORT_LOCATION}
    touch ${YT_URLS_AND_LOCATIONS}

    crontab -l > $CRON_TEMP # Copy the current contents to a temporary file

    # echo "${SCHEDULE} echo "${YOUTUBE_URL}" >> "${OUTPUT}"/cron.txt" >> $CRON_TEMP
    # echo "* * * * * echo "${YOUTUBE_URL}" >> "${OUTPUT}"/cron.txt" >> $CRON_TEMP
    # Append the new Youtube job to the temporary file
    # echo "${SCHEDULE} youtube-dl -o "${OUTPUT}%(title)s.%(ext)s" $YOUTUBE_URL --youtube-skip-dash-manifest" >> $CRON_TEMP
    # echo "* * * * * /usr/local/bin/youtube-dl -o \"${OUTPUT}%(title)s.%(ext)s\" --youtube-skip-dash-manifest "${YOUTUBE_URL}"" >> $CRON_TEMP
    if [ ! "$(crontab -l | grep 'cron_yt_process')" == ""  ];then # Search for existent
      echo "cron job was already set up"
    else
      echo "cron job is being set up"
      echo "${SCHEDULE} /Users/buddles/projects/playground/yt_backup/cron_yt_process.sh ${YT_IMPORT_LOCATION}" >> $CRON_TEMP
    fi

    crontab $CRON_TEMP # Import everything back again

    rm $CRON_TEMP # Remove the temporary file
  fi
fi
