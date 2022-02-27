# homebridge-appletv
Configuration of pyatv and homebridge-cmd4 for reading the Apple TV status in Homebridge.

## Installation
- Install [pyatv](https://github.com/postlund/pyatv) and pair with the Apple TV.
```
$ pip3 install pyatv
$ /home/pi/.local/bin/atvremote scan
$ /home/pi/.local/bin/atvremote --id AA:BB:CC:DD:EE:FF --protocol airplay pair
$ /home/pi/.local/bin/atvremote --id AA:BB:CC:DD:EE:FF --protocol companion pair
```

- Install [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4) plugin.

## Upgrade
- Upgrade [pyatv](https://github.com/postlund/pyatv) when new version is released.
```
pip3 install --upgrade pyatv
```

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
   
}
```

## Shell script `appletv_control.sh`

- Place the script file inside the folder `/var/lib/homebridge/`
- Set the script as executable with the command `chmod +x /var/lib/homebridge/appletv_control.sh`
- Change ATV_id with the ID of your Apple TV
- Change airplay_credentials with the credentials given when pairing with the Apple TV
- Change companion_credentials with the credentials given when pairing with the Apple TV

## Known issues

There is a known issue for pyatv if you have configured a Homepod to be the default audio output. In this case, you will always get the power to be ON (postlund/pyatv#1667).

## Many thanks to
- [pyatv](https://github.com/postlund/pyatv)
- [homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4)
