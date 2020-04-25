![Icon](https://github.com/RiftValleySoftware/BlueVanClef/raw/master/icon.png)

BlueVanClef
=

This is a "Bluetooth Explorer" app that was written in order to develop a general-purpose Core Bluetooth "Wrapper" SDK, and learn Bluetooth.

[This is the GitHub repo for this project.](https://github.com/RiftValleySoftware/BlueVanClef) It is 100% open-source, MIT-licensed code.

Although this is an iOS app, it will be used to develop a cross-[Apple]-platform SDK.

It is destined to become an Apple App-Store app, but that's still a ways off, and Apple needs to greenlight it _(They can sometimes be a bit "squeamish" with developer tools like this)_.

This is a fairly straightforward "drill-down" interface. You start with a screen that contains discoved devices (Peripherals). You can modify which devices by setting up a minimum power (RSSI) threshold, and establishing "filter" UUIDs for advertised Services or individual devices.

THE DEVICE LIST SCREEN
-

In the initial screen (Device List), there will only be unconnected devices that have been discovered through advertising.

At the top of the screen, is a button. If the app is currntly scanning for advertised Peripherals, it will be green, and say "SCANNING". Tapping on it will change it red, saying "NOT SCANNING". If it is not scanning, then no updates will be made to the device list, and new Peripherals will not be discovered.

We can "left-swipe" devices, or touch the "EDIT" button (that appears if we stop scanning). In that case, we can choose devices to be "ignored." They will be left off the list, until we do a new "Pull to Refresh," or bring up the Settings Screen (Which will renew the scanning, if we were scanning when we called it).

If we are not scanning, the list will not be changed. Any of the devices can be connected, if they are allowed to connect.

Devices that cannot connect will be displayed as "grayed out," and will not allow selection.

THE DEVIICE INFO/SERVICE LIST SCREEN
-

Once you select a device, the app connects to the device, and displays a screen that has a list of the available Services, as well as the advertisement information. Once this screen appears, the app has established a connection with the Peripheral. Leaving this screen, and returning to the Device List, will terminate the connection.

THE CHARACTERISTIC LIST SCREEN
-

If we tap on a Service, another screen appears, with a list of all the Characteristics for that Service.

If the connection has read access to a Characteristic, an initial read is done, and the value of that Characteristic is updated. No further reads are done, unless we tap on the "READ" button. There may also be a "NOTIFY" button. Tapping on that will start the Characteristic notifying.

THE DESCRIPTOR LIST SCREEN
-

If the Characteristic has Descriptors, tapping on the Characteristic will bring in another screen, with the Descriptors. An initial read is done for the Descriptor. Tapping on a Descriptor will trigger a new read.

"PULL TO REFRESH"
-

On all the screens, the table has a "pull to refresh," so we can pull down on the table to "start over from scratch." Depending on which screen we are on, the operation may "clear the slate," and start over, or it may just trigger new reads for all the entities listed.

THE SETTINGS SCREEN
-

At the top of the Device List Screen, are two icons. The left one (Info), is the "About" screen, with information about the app.

The right one (the "gear") brings up the Settings Screen, where we can:

**Continuously Update Scans**

This is a switch that, if on (default is off), will continuously update the advertisement data for the devices in the list.

**Filter UUIDs**

These are text boxes that will allow us to enter valid Bluetooth CBUUIDs (either 4 or 48 hex characters).
It will be one UUID per line.

***Specific Device Identifiers***

If provided, these will limit discover to ONLY the devices with the IDs provided. All other devices will be ignored.

***Advertised Services***

UUIDs here, will limit discovery to only devices that *advertise* the given Services. It should be noted that this only applies to *advertised* Services. Most Peripherals actually have many more Services than the ones they advertise, and this will not apply to those Services.

***Characteristics***

If provided, all Characteristic List Screens will be limited to only the ggiven Characteristic. This will apply to All Services, in all Peripherals.

**Minimum RSSI**

This is a slider that sets a minimal RSSI (signal strength) setting. Devices with signal strength below this will be ignored.
