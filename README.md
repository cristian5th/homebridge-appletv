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

### pyatv installation on Synology NAS
- Install [Homebridge Synology package](https://github.com/oznu/homebridge-syno-spk) and enable compiling native modules.
```
$ sudo su
$ mkdir -p /volume1/@Entware/opt
$ rm -rf /opt
$ mkdir /opt
$ mount -o bind "/volume1/@Entware/opt" /opt
```
For aarch64 (see [here](https://github.com/Entware/Entware/wiki/Install-on-Synology-NAS) for other architectures):
```
$ wget -O - https://bin.entware.net/aarch64-k3.10/installer/generic.sh | /bin/sh
```

- Install [pyatv](https://github.com/postlund/pyatv) and pair with the Apple TV.
```
$ opkg update
$ opkg install python3 python3-pip python3-cffi python3-dev
$ pip3 install pyatv
$ /volume1/@Entware/opt/bin/atvremote scan
$ /volume1/@Entware/opt/bin/atvremote --id AA:BB:CC:DD:EE:FF --protocol airplay pair
$ /volume1/@Entware/opt/bin/atvremote --id AA:BB:CC:DD:EE:FF --protocol companion pair
```
>**Note:** you may get an error when executing atvremote.  
>`ModuleNotFoundError: No module named 'bitarray._bitarray'`  
>Downgrading bitarray will solve the problem.
>```
>pip install --upgrade bitarray==2.3.7
>```

## Upgrade
- Upgrade [pyatv](https://github.com/postlund/pyatv) when new version is released.
```
pip3 install --upgrade pyatv
```

## Homebridge-cmd4 plugin configuration
>**Note:** replace `/var/lib/homebridge/` with `/volume1/homebridge` when using a Synology NAS
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
            "displayName": "ATV Power",
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
            "displayName": "ATV Video Play",
            "on": "FALSE",
            "queue": "A",
            "polling": [
                {
                    "characteristic": "on",
                    "interval": 6,
                    "timeout": 5000
                }
            ],
            "state_cmd": "bash /var/lib/homebridge/appletv_control.sh"
        },
        {
            "type": "Switch",
            "displayName": "ATV Video Play",
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
>**Note:** replace `/var/lib/homebridge/` with `/volume1/homebridge` when using a Synology NAS

- Place the script file inside the folder `/var/lib/homebridge/`
- Set the script as executable with the command `chmod +x /var/lib/homebridge/appletv_control.sh`
- Change ATV_id with the ID of your Apple TV
- Change airplay_credentials with the credentials given when pairing with the Apple TV
- Change companion_credentials with the credentials given when pairing with the Apple TV

## Known issues

There is a known issue for pyatv if you have configured a Homepod to be the default audio output. In this case, you will always get the power to be ON ([postlund/pyatv#1667](https://github.com/postlund/pyatv/issues/1667)).

## Many thanks to
- [postlund/pyatv](https://github.com/postlund/pyatv)
- [ztalbot2000/homebridge-cmd4](https://github.com/ztalbot2000/homebridge-cmd4)
- [NorthernMan54/homebridge-cmd-television](https://github.com/NorthernMan54/homebridge-cmd-television)
