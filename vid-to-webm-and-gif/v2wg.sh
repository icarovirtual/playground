#!/bin/bash
if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo "help
  aa"
else
  # Defaults
  START_SECS=0
  DURATION=300 # Nobody will make a webm/gif longer than 5 minutes...
  FORMAT="webm"
  TRANSPOSE=4

  while [[ $# > 1 ]]
  do
      key="$1"
      case $key in
          -i)
          INPUT="$2"
          shift
          ;;
          -o)
          OUTPUT="$2"
          shift
          ;;
          -s)
          START_SECS="$2"
          shift
          ;;
          -d)
          DURATION="$2"
          shift
          ;;
          -t)
          TRANSPOSE="$2"
          shift
          ;;
          -f)
          FORMAT="$2"
          shift
          ;;
          *)
          # default
          ;;
      esac
      shift
  done

  if [ ! -z ${INPUT} ];       then echo INPUT PATH ............. "${INPUT}"; fi
  if [ ! -z ${OUTPUT} ];      then echo OUTPUT PATH ............ "${OUTPUT}"; fi
  if [ ! -z ${START_SECS} ];  then echo START AT ............... "${START_SECS}" seconds; fi
  if [ ! -z ${DURATION} ];    then echo DURATION ............... "${DURATION}" seconds; fi
  if [ ! -z ${TRANSPOSE} ];   then echo TRANSPOSE .............. "${TRANSPOSE}"; fi
  if [ ! -z ${FORMAT} ];      then echo OUTPUT FORMAT .......... "${FORMAT}"; fi

  if [ -z ${INPUT} ]; then
    echo "Please provide the input file location using the -i argument"
  elif [ -z ${OUTPUT} ]; then
      echo "Please provide the output file location using the -o argument"
  else
    sudo ffmpeg -ss ${START_SECS} -t ${DURATION} -i ${INPUT} -vf "transpose=${TRANSPOSE}" ${OUTPUT}.${FORMAT}
  fi
fi
