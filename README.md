![Icon](img/icon.png)

RVS_BlueThoth
=

This is a Bluetooth SDK for "Central" (Client) Core Bluetooth (BLE) implementation.

It abstracts some of the more "tedious" aspects of using Core Bluetooth; allowing the app to easily implement a Bluetooth Client functionality.

[This is the GitHub repo for this project.](https://github.com/RiftValleySoftware/RVS_BlueThoth) It is 100% open-source, MIT-licensed code.


INSTALLATION
=
[This Project Requires Use of  the Swift Package Manager (SPM)](https://swift.org/package-manager/)
-
If you are unfamiliar with the SPM, [this series](https://littlegreenviper.com/series/spm/) may be helpful.
You can use SPM to load the project as a dependency, by referencing its [GitHub Repo](https://github.com/RiftValleySoftware/RVS_BlueThoth/) URI (SSH: [git@github.com:RiftValleySoftware/RVS_BlueThoth.git](git@github.com:RiftValleySoftware/RVS_BlueThoth.git), or HTTPS: [https://github.com/RiftValleySoftware/RVS_BlueThoth.git](https://github.com/RiftValleySoftware/RVS_BlueThoth.git)).

Once you have the dependency attached, you reference it by adding an import to the files that consume the package:
    
    import RVS_BlueThoth

This project has a couple of sub-dependencies to the [RVS_Generic_Swift_Toolbox](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox) project (required to use the SDK), and the [RVS_Persistent_Prefs project](https://github.com/RiftValleySoftware/RVS_PersistentPrefs) (which is only used for the test harness, and is not necessary for the SDK user).