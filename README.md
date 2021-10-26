# homebridge-appletv
Configuration of pyatv and homebridge-cmd4 for reading the Apple TV status in Homebridge.

## Installation
- Install [pyatv](https://github.com/postlund/pyatv) and pair with the Apple TV.
```
$ pip3 install pyatv
$ atvremote scan
$ atvremote -s 192.168.0.57 --protocol airplay pair
```

- Install [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) plugin.

## Homebridge-cmd4 plugin configuration
```
{
    "platform": "Cmd4",
    "name": "Cmd4",
    "interval": 5,
    "timeout": 4000,
    "debug": false,
    "stateChangeResponseTime": 3,
    "queueTypes": [
        {
            "queue": "A",
            "queueType": "WoRm"
        }
    ],
    "accessories": [
        {
            "type": "Switch",
            "displayName": "Apple TV Power",
            "on": "FALSE",
            "queue": "A",
            "polling": [
                {
                    "characteristic": "on"
                }
            ],
            "state_cmd": "bash /var/lib/homebridge/appletv_control.sh"
        },
        {
            "type": "Switch",
            "displayName": "Apple TV Play State",
            "on": "FALSE",
            "queue": "A",
            "polling": [
                {
                    "characteristic": "on"
                }
            ],
            "state_cmd": "bash /var/lib/homebridge/appletv_control.sh"
        }
    ],
}
```

## Shell script `appletv_control.sh`

- Place the script file inside the folder `/var/lib/homebridge/`
- Set the script as executable with the command `chmod +x /var/lib/homebridge/appletv_control.sh`
- Change ATV_id with the MAC address of your Apple TV
- Change airplay_credentials with the credentials given when pairing with the Apple TV

```
#!/bin/bash

set -e

# Exit immediately for unbound variables.
set -u


length=$#
device=""
io=""
characteristic=""
option=""
ATV_id="00:00:00:00:00:00"
airplay_credentials="0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef:0123456789abcdef0123456789abcdef0123456789abcdef"

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

```

## Many thanks to
- [pyatv](https://github.com/postlund/pyatv)
- [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4)