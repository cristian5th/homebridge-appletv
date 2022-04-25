#!/bin/bash

set -e

# Exit immediately for unbound variables.
set -u


length=$#
device=""
io=""
characteristic=""
option=""
ATV_id="AA:BB:CC:DD:EE:FF"
airplay_credentials="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
companion_credentials="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef"
atvremote_path="/home/pi/.local/bin/"

if [ $length -le 1 ]; then
   printf "Usage: $0 Get < AccessoryName > < Characteristic >\n"
   printf "Usage: $0 Set < AccessoryName > < Characteristic > < Value >\n"
   exit -1
fi

# printf "args =$#\n"   # debug
# printf "arg1 =$1\n"   # debug

if [ $length -ge 1 ]; then
    io=$1
   #  printf "io=$io\n"   # debug
fi
if [ $length -ge 2 ]; then
    device=$2
   #  printf "device = ${device}\n"   # debug
fi
if [ $length -ge 3 ]; then
    characteristic=$3
   #  printf "Characteristic = ${characteristic}\n"   # debug
fi
if [ $length -ge 4 ]; then
    option=$4
   #  printf "option = ${option}\n"   # debug
fi

if [ "${io}" == "Get" ]; then
   case $device in
      'Apple TV Power')
         case $characteristic in
            'On')
               # Get Apple TV power state
               ATV_POWER_STATE=$(${atvremote_path}atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  printf "1\n"
               else
                  printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Play State')
         case $characteristic in
            'On')
               # Get Apple TV play status
               ATV_PLAYING_STATE=$(${atvremote_path}atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} playing | grep -oP '(?<=Device state: ).*')
               if [ "${ATV_PLAYING_STATE}" = "Playing" ]
               then
                  printf "1\n"
               else
                  printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Video Play')
         case $characteristic in
            'On')
               # Get Apple TV play status and media type
               ATV_PLAYING=$(${atvremote_path}atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} playing)
               ATV_PLAYING_STATE=$(echo "$ATV_PLAYING" | grep -oP '(?<=Device state: ).*')
               ATV_MEDIA_PLAYING=$(echo "$ATV_PLAYING" | grep -oP '(?<=Media type: ).*')
               if [ "${ATV_MEDIA_PLAYING}" = "Video" ]
               then
                  if [ "${ATV_PLAYING_STATE}" = "Playing" ] || [ "${ATV_PLAYING_STATE}" = "Paused" ]
                  then
                     ATV_MEDIA_TITLE=$(echo "$ATV_PLAYING" | grep -oP '(?<=Title: ).*')
                     # If title is some streaming address, then
                     # this is my wife watching Shopping Queen and shutters must remain up
                     if [[ $ATV_MEDIA_TITLE =~ ^rtsp://.* ]]
                     then
                        printf "0\n"
                     else
                        printf "1\n"
                     fi
                  else
                     printf "0\n"
                  fi
               else
                  printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      *)
         printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
         exit -1
         ;;
   esac
fi
if [ "${io}" == 'Set' ]; then
   case $device in
      'Apple TV Power')
         case $characteristic in
            'On')
               # Get Apple TV current power state and switch accordingly
               ATV_POWER_STATE=$(${atvremote_path}atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  ${atvremote_path}atvremote --id ${ATV_id} --companion-credentials ${companion_credentials} turn_off
               else
                  ${atvremote_path}atvremote --id ${ATV_id} --companion-credentials ${companion_credentials} turn_on
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Set ${device} Characteristic ${characteristic}"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Play State')
         case $characteristic in
            'On')
               # Toggle between play and pause
               ${atvremote_path}atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} play_pause
               exit 0
               ;;
            *)
               printf "UnHandled Set ${device} Characteristic ${characteristic}"
               exit -1
               ;;
         esac
         exit 0
         ;;
      *)
         printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
         exit -1
         ;;
   esac
fi
printf "Unknown io command ${io}\n"
exit -1

