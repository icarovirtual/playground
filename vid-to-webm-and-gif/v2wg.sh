#!/bin/bash
# TODO:
# calcular o #~ frames que vai ser processado pegando o fps e a duracao do video
# habilitar um modo simples que soh passa direto o nome do arquivo
# deixar como padrao sem audio (inverter o parametro)
# mostrar e calcular melhor se eh video inteiro, ao inves de generalizar pra 300s
if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo \
"v2wg (video to webm and gif) version 1.0 by iraupph
  convert your video files to .gif or .webm files. provides options to set time limits and transpose (rotate) the video.

usage: v2wg [--no_audio] [-i infile -o outfile] [-s start] [-d duration] [-t transpose] [-f format]
where:
  -h        print this help menu
  -i        path to the input file
              e.g.: /Users/me/video.mp4
  -o        path to the output file, without the extension
              e.g.: /Users/me/output
  -s        time (in the formats \"[-][HH:]MM:SS[.m...]\" or \"[-]S+[.m...]\") to start the conversion
              e.g.: -i 15
                -i 00:05:30.500
                -i 33.128
  -d        the duration (in the formats \"[-][HH:]MM:SS[.m...]\" or \"[-]S+[.m...]\") of the video to be used in the conversion
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
  v2wg -i /Users/me/video.mp4 -o /Users/me/output
complete example:
  v2wg --audio -i /Users/me/video.mp4 -o /Users/me/output -p 320x480 -s 15 -d 5.500 -t 1 -f webm

this process uses the \"ffmpeg\" library with \"libvpx\" and \"libvorbis\" plugins. if any errors occur relating to these requirements, install them with the following command:
  brew install ffmpeg --with-libvpx --with-libvorbis"
else
  # Defaults
  START_SECS=0
  DURATION=300 # Nobody will make a webm/gif longer than 5 minutes...
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

  if [ ! -z ${INPUT} ];       then echo INPUT PATH ............. "${INPUT}"; fi
  if [ ! -z ${OUTPUT} ];      then echo OUTPUT PATH ............ "${OUTPUT}"; fi
  if [ ! -z ${START_SECS} ];  then echo START AT ............... "${START_SECS}" seconds; fi
  if [ ! -z ${DURATION} ];    then echo DURATION ............... "${DURATION}" seconds; fi
  if [ ! -z ${TRANSPOSE} ];   then echo TRANSPOSE .............. "${TRANSPOSE}"; fi
  if [ ! -z ${AUDIO} ];       then echo NO AUDIO ............... "${AUDIO}"; fi
  if [ ! -z ${FORMAT} ];      then echo OUTPUT FORMAT .......... "${FORMAT}"; fi
  if [ ! -z ${SIZE} ];        then echo OUTPUT SIZE ............ "${SIZE}"; fi

  if [ -z ${INPUT} ]; then
    echo "Please provide the input file location using the -i argument"
  elif [ -z ${OUTPUT} ]; then
    echo "Please provide the output file location using the -o argument"
  else
    # Transpose is optional and has no default. Use if is provided, otherwise is empty
    if [ ! -z ${TRANSPOSE} ]; then TRANSPOSE_CMD="-vf transpose=${TRANSPOSE}"; else TRANSPOSE_CMD=""; fi
    if [ ! -z ${AUDIO} ]; then AUDIO_CMD=""; else AUDIO_CMD="-an"; fi
    #      Show progress but don't show other logs                                                                       These quality settings should be good enough
    ffmpeg -stats -loglevel 0 -ss ${START_SECS} -t ${DURATION} -i "${INPUT}" -s ${SIZE} ${TRANSPOSE_CMD} ${AUDIO_CMD} -c:v libvpx -b:v 3500k -qmin 10 -qmax 42 "${OUTPUT}.${FORMAT}"
  fi
fi
