# iocage-plugin-mirakurun
Artifact file(s) for Mirakurun iocage plugin

https://github.com/Chinachu/Mirakurun

## Assumptions and cautions

- iocage-plugin-mirakurun works as FreeBSD jail.
- It requires a DVR tuner and a smart card reader to work.
- Hardware must be connected to the server and properly recognized by the host OS (FreeBSD, TrueNAS, etc.).
- To allow access to the hardware from jail.

## Installation

Add the rules to `/etc/devfs.rules` so that you can access the device files of the tuner and smart card reader. If the existing rules can be used, there is no need to add them.

This example uses the following rules.

```
[usbrules=100]
add path 'usbctl' mode 660 group uucp
add path 'usb/' mode 660 group uucp
```

Then install the plugin with some options. Set the `mount_devfs` and `allow_mount_devfs` options to yes, and specify the rule number added in the previous step in `devfs_ruleset`.

```
sudo iocage fetch -P mirakurun -n mirakurun -g https://github.com/fuji44/iocage-fuji44-plugins.git --branch main ip4_addr="em0|192.168.0.100/24" mount_devfs=yes allow_mount_devfs=yes devfs_ruleset=100
```

## Usege

After the installation has successfully completed, you should be able to view the WebUI by accessing the following URL. It won't do anything until the tuner and channel settings are complete, though.

`http://your_ip_addr:40772/`

## Configure

After installing the plugin, you will need to set up the tuner and channels. See the [official documentation](https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md) for details.

It can also be configured from the WebUI. The WebUI allows you to configure the server, tuner, and channel settings as well as view the tuner usage, logs, and event history.

When it comes to channels, you can set them up to be scanned automatically. To do this, you need to send a request to the WebAPI, but you can easily do this from the Suwagger UI.

- Suwagger UI: `http://your_ip_addr:40772/api/debug`
- Scan Channels: `http://your_ip_addr:40772/api/debug?url=/api/docs#/config/channelScan`

If you are scanning a large range of channels, it will take a very long time. Let's have a cup of coffee and wait while looking at the event history in the WebUI.
