#!/bin/bash

set -e

# Exit immediately for unbound variables.
set -u


length=$#
device=""
io=""
characteristic=""
option=""
ATV_id="50:32:37:93:F0:70"
airplay_credentials="c559e2a53e289609d0107d13f487fcce2591c776275c582a92a655a1344d8d81:054ece2d7cbbeb573a5732b21e6e28684b95a3618abc51492adf79eb2ecc8d00:32433042313742422d434642342d344630442d413233322d453734354236343133373039:37663863313232622d633865662d346463322d613230392d383463343864396564303562"

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
               ATV_POWER_STATE=$(/home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
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
               # If requested when Apple TV is off, it will switch on and this is unwanted
               ATV_POWER_STATE=$(/home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  ATV_PLAYING_STATE=$(/home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} playing | grep -oP '(?<=Device state: ).*')
                  if [ "${ATV_PLAYING_STATE}" = "Playing" ]
                  then
                     printf "1\n"
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
               ATV_POWER_STATE=$(/home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  /home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} turn_off
               else
                  /home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} turn_on
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
               /home/pi/.local/bin/atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} play_pause
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

