#!/bin/bash
if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo \
"v2wg (video to webm and gif) version 1.0 by iraupph
  convert your video files to .gif or .webm files. provides options to set time limits and transpose (rotate) the video.

usage: v2wg [-h] [-i infile -o outfile] [-s start] [-d duration] [-t transpose] [-f format]
where:
  -h    print this help menu
  -i    path to the input file
          e.g.: /Users/me/video.mp4
  -o    path to the output file, without the extension
          e.g.: /Users/me/output
  -s    time in seconds or in the format \"HH:MM:SS.MMMM\" to start the conversion
          e.g.: -i 15
                -i 00:05:30.500
  -d    the duration in seconds of the video to be used in the conversion
  -t    transposing options, as follows:
          1 to rotate the video in 90 degrees clockwise
          2 to rotate the video in   90 degrees anti-clockwise
          this is usually useful when converting portrait videos
  -f    The output format. Acceptable types are gif and webm

basic example:
  v2wg -i /Users/me/video.mp4 -o /Users/me/output
complete example:
  v2wg -i /Users/me/video.mp4 -o /Users/me/output -s 15 -d 5 -t 1 -f webm

this process uses the \"ffmpeg\" library with \"libvpx\" and \"libvorbis\" plugins. if any errors occur relating to these requirements, install them with the following command:
  brew install ffmpeg --with-libvpx --with-libvorbis"
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
    sudo ffmpeg -ss ${START_SECS} -t ${DURATION} -i "${INPUT}" -vf "transpose=${TRANSPOSE}" "${OUTPUT}.${FORMAT}"
  fi
fi
