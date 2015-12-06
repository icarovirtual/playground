#!/bin/bash

# TODO:
# calcular o #~ frames que vai ser processado pegando o fps e a duracao do video
# mostrar e calcular melhor se eh video inteiro, ao inves de generalizar pra 300s

if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo \
"v2wg (video to webm and gif) version 1.5 by iraupph
  convert your video files to .gif or .webm files. provides options to set time limits, resolution, muting and rotation of the video.

usage:
  v2wg infile
  v2wg [--audio] [-i infile] [-o outfile] [-s start] [-d duration] [-t transpose] [-f format] [-p resolution]
where:
  -h        print this help menu
  -i        path to the input file
              e.g.: /Users/me/video.mp4
  -o        path to the output file, without the extension
              e.g.: /Users/me/output
  -s        time (in the formats \"HH:MM:SS[.m...]\" or \"S+[.mmmm]\") to start the conversion
              e.g.: -i 15
                -i 00:05:30.500
                -i 33.128
  -d        the duration (in the formats \"HH:MM:SS[.m...]\" or \"S+[.mmmm]\") of the video to be used in the conversion
              e.g.: -i 15
                -i 00:05:30.500
                -i 33.128
  -t        transposing options, as follows:
              1 to rotate the video in 90 degrees clockwise
              2 to rotate the video in 90 degrees anti-clockwise
                this argument is usually useful when converting portrait videos
  -p        size of the output, in the format WIDTHxHEIGHT or using one of the abbreviations:
              nhd (640x360), hd480 (852x480), qhd (960x540), hd720 (1280x720), hd1080 (1920x1080)
  -f        the output format. acceptable types are \"gif\" and \"webm\"
  --audio   enable the audio in the output^

  ^ use these arguments at the start of the command to avoid problems

basic example:
  v2wg /Users/me/video.mp4
complete example:
  v2wg --audio -i /Users/me/video.mp4 -o /Users/me/output -p 320x480 -s 15 -d 5.500 -t 1 -f webm

this script uses the \"ffmpeg\" library with \"libvpx\" and \"libvorbis\" plugins. if any errors occur relating to these requirements, install them with the following command:
  brew install ffmpeg --with-libvpx --with-libvorbis"
else
  # Convert seconds to HH:MM:SS.mmmm
  function secs_to_hours_f () {
    # If it's (barely) already in the expected format just return it
    if [[ $1 == *":"*":"*":"* ]]; then
      echo $1
    else
      SECONDS="${1%.*}" # Get only the seconds (without the millis)
      MILLIS="0000" # Default millis
      if [[ $1 == *"."* ]]; then
        # If there is millis
        MILLIS="${1##*.}"
      fi
      SECS_AS_HOURS=$(printf '%02d:%02d:%02d.%-04s' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)) $MILLIS)
      echo ${SECS_AS_HOURS}
    fi
  }

  # Defaults
  START="0"
  # DURATION=300 # Nobody will make a webm/gif longer than 5 minutes...
  FORMAT="webm"
  SIZE="qhd"

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
          START="$2"
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
          -p)
          SIZE="$2"
          shift
          ;;
          --audio)
          AUDIO=YES # No shift cuz no value
          ;;
          *)
          # default
          ;;
      esac
      shift
  done

  # Try to parse the file path from the first parameter
  if [ -z ${INPUT} ]; then
    INPUT=$1; # Get the file path from parameter
  fi
  # Generate a output file name from the input file
  if [ -z ${OUTPUT} ]; then
    OUTPUT="${INPUT%.*}"; # Remove the extension from file path
  fi

  # Check if the input file exists and abort if it does not
  if [ ! -f ${INPUT} ]; then
    echo "Input file \"${INPUT}\" not found!";
    exit 1;
  fi

  # Check if the output file exists and prompt for overwriting
  if [ -f "${OUTPUT}.${FORMAT}" ]; then
    read -p "Output file \"${OUTPUT}.${FORMAT}\" already exists, overwrite? [y/n] " prompt
    tput cuu 1 && tput el # Clear the previous line
    if [[ ! $prompt == "y" && ! $prompt == "Y" && ! $prompt == "yes" && ! $prompt == "Yes" ]]; then
      echo "Use the -o parameter to specify the output file path"
      exit 0;
    fi
  fi

  if [ -z ${DURATION} ]; then
    # Get the duration by inspecting the file
    DURATION=$(ffprobe "${INPUT}" 2>&1 | sed -n "s/.* Duration: \([^,]*\), .*/\1/p")
  else
    DURATION=$(secs_to_hours_f ${DURATION})
  fi
  START=$(secs_to_hours_f ${START})

  # Calculate the total frames to be processed
  HRS=$(echo $DURATION | cut -d":" -f1)
  MIN=$(echo $DURATION | cut -d":" -f2)
  SEC=$(echo $DURATION | cut -d":" -f3)
  FPS=$(ffprobe "${INPUT}" 2>&1 | sed -n "s/.*, \(.*\) tbr.*/\1/p")
  FRAMES=$(echo "($HRS*3600+$MIN*60+$SEC)*$FPS" | bc | cut -d"." -f1)

  if [ ! -z ${INPUT} ];       then echo INPUT PATH ............. "${INPUT}"; fi
  if [ ! -z ${OUTPUT} ];      then echo OUTPUT PATH ............ "${OUTPUT}"; fi
  if [ ! -z ${START} ];       then echo START AT ............... "${START}"; fi
  if [ ! -z ${DURATION} ];    then echo DURATION ............... "${DURATION}"; fi
  if [ ! -z ${TRANSPOSE} ];   then echo TRANSPOSE .............. "${TRANSPOSE}"; fi
  if [ ! -z ${AUDIO} ];       then echo NO AUDIO ............... "${AUDIO}"; fi
  if [ ! -z ${FORMAT} ];      then echo OUTPUT FORMAT .......... "${FORMAT}"; fi
  if [ ! -z ${SIZE} ];        then echo OUTPUT SIZE ............ "${SIZE}"; fi
  if [ ! -z ${FRAMES} ];      then echo TOTAL FRAMES ........... "~${FRAMES}"; fi

  if [ -z ${INPUT} ]; then
    echo "Please provide the input file location using the -i argument"
  elif [ -z ${OUTPUT} ]; then
    echo "Please provide the output file location using the -o argument"
  else
    # Transpose is optional and has no default. Use if is provided, otherwise is empty
    if [ ! -z ${TRANSPOSE} ]; then TRANSPOSE_CMD="-vf transpose=${TRANSPOSE}"; else TRANSPOSE_CMD=""; fi
    if [ ! -z ${AUDIO} ]; then AUDIO_CMD=""; else AUDIO_CMD="-an"; fi
    #      Show progress but don't show other logs - force output file overwrite                                           These quality settings should be good enough
    ffmpeg -stats -loglevel "error" -ss ${START} -y -t ${DURATION} -i "${INPUT}" -s ${SIZE} ${TRANSPOSE_CMD} ${AUDIO_CMD} -c:v libvpx -b:v 3500k -qmin 10 -qmax 42 "${OUTPUT}.${FORMAT}"
  fi
fi
