![Icon](img/icon.png)

# RVS_BlueThoth

This is a low-level, [native Swift](https://developer.apple.com/swift/) Bluetooth SDK for ["Central" (Client)](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) Core Bluetooth (BLE) implementation.

It abstracts some of the more "tedious" aspects of using Core Bluetooth; allowing the app to easily implement a Bluetooth Client functionality.

[This is the GitHub repo for this project.](https://github.com/RiftValleySoftware/RVS_BlueThoth)

[This is the project technical documentation](https://riftvalleysoftware.github.io/RVS_BlueThoth/)

# WHAT PROBLEM DOES THIS SOLVE?

Implementing [the Apple Core Bluetooth SDK](https://developer.apple.com/documentation/corebluetooth) can be a rather tedious process. For example, discovery of [Services](https://developer.apple.com/documentation/corebluetooth/cbservice), [Characteristics](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic), and [Descriptors](https://developer.apple.com/documentation/corebluetooth/cbdescriptor) can be intricate and time-consuming. RVS_BlueThoth takes care of that in the "background," allowing you to concentrate on providing a richer experience to the users of your application or SDK.

# LOW-LEVEL SDK

RVS_BlueThoth is not really designed to be a direct dependency of an application-layer system (although it is demonstrated that way, in [the test harnesses](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests)). Rather, it is designed to be the basis for application-specific ["Façade"](https://en.wikipedia.org/wiki/Facade_pattern) layers, such as [OBD](https://en.wikipedia.org/wiki/On-board_diagnostics) adapters, or [mesh device](https://gotennamesh.com) drivers.

# ULTRA-HIGH QUALITY

The basic philosophy behind RVS_BlueThoth, is that it is a fundamental infrastructure element, and, as such, it needs to be of the highest quality possible. All efforts have been made to ensure that it works flawlessly.

# LICENSE

RVS_BlueThoth is 100% open-source, [MIT-licensed](https://opensource.org/licenses/MIT) code.

You are free to use it as you wish, but be aware that we are under no obligation to support the project, and there are NO GUARANTEES as to whether or not it is fit for your purposes.

# REQUIREMENTS

## External Dependencies

### [This Project Requires Use of the Swift Package Manager (SPM)](https://swift.org/package-manager/)

If you are unfamiliar with the SPM, [this series](https://littlegreenviper.com/series/spm/) may be helpful.

RVS_BlueThoth has one external build dependency: [the RVS_Generic_Swift_Toolbox Project](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox) (also written and supported by The Great Rift Valley Software Company). If you wish to build [the test harnesses](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests), then you also need [the RVS_PersistentPrefs Project](https://github.com/RiftValleySoftware/RVS_PersistentPrefs).

[The included XCode workspace](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/RVS_BlueThoth.xcworkspace) has these dependencies already.

## Native Swift Only

RVS_BlueThoth is a fully native Swift SDK. It does not interface with Objective-C.

RVS_BlueThoth will work on all of the Apple operating systems ([iOS](https://www.apple.com/ios)/[iPadOS](https://www.apple.com/ipados), [MacOS](https://www.apple.com/macos), [tvOS](https://www.apple.com/tvos/), and [WatchOS](https://www.apple.com/watchos/)). It can be incorporated into projects that target any of these environments.

## Static Library

The SPM build is provided as a static library, as opposed to [a dynamic framework](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html). RVS_BlueThoth is a fairly "light" codebase, and is likely to be one of the smaller components of any given project. If you prefer a dynamic library, it can be easily changed in [the `Package.swift` file](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Package.swift) for the project. There are no resource, or non-code components, in the SDK. It is a simple executable codebase.

## Will Not Work On A simulator

It should be noted that Core Bluetooth requires use of a device; not a simulator. The library will not work on a simulator, registering a Bluetooth Not Available error.

# TESTING

RVS_BlueThoth does not implement [unit tests](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTesting.html). Instead, it provides four [test harness apps](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests); one for each of the supported platforms ([iOS/iPadOS](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests/RVS_BlueThoth_Test_Harness_iOS), [MacOS](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests/RVS_BlueThoth_Test_Harness_MacOS), [tvOS](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests/RVS_BlueThoth_Test_Harness_tvOS), and [WatchOS](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests/RVS_BlueThoth_Test_Harness_WatchOS)).

[Here is an article that explains the philosophy behind the use of test harnesses.](https://littlegreenviper.com/miscellany/testing-harness-vs-unit/)

## The Test Harness Apps Are Serious code

Each of the test harness apps is a fully-qualified, "App Store release-ready" application. They act as "Bluetooth sniffer" apps. In fact, [the iOS test harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/tree/master/Tests/RVS_BlueThoth_Test_Harness_iOS) has actually been converted into [a released app on the iOS App Store](https://riftvalleysoftware.com/work/ios-apps/bluevanclef/) ([here is the source code](https://github.com/RiftValleySoftware/BlueVanClef)).

They should provide excellent "starting points," when learning to implement the SDK.

# IMPLEMENTATION

## Installation

As noted previously, you should use [the Swift Package Manager (SPM)](https://swift.org/package-manager/) to import the project into your own project. If you are unsure how to do that, then [this article may be quite helpful](https://littlegreenviper.com/miscellany/spm/implementing-swift-package-manager-05/).

The SSH GitHub URI is [`git@github.com:RiftValleySoftware/RVS_BlueThoth.git`](git@github.com:RiftValleySoftware/RVS_BlueThoth.git), and the HTTPS GitHub URI is [`https://github.com/RiftValleySoftware/RVS_BlueThoth.git`](https://github.com/RiftValleySoftware/RVS_BlueThoth.git)).

Once you have the package installed, you'll need to import the module into any files that use it, by adding the following to the beginning of the file:
    
    import RVS_BlueThoth

## Delegate Required

RVS_BlueThoth implements [a Delegate pattern](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Delegation.html) (but implemented more like an [Observer](https://en.wikipedia.org/wiki/Observer_pattern)).

In order to reduce the complexity of the SDK, we have created [a single "bottleneck" delegate protocol](https://riftvalleysoftware.github.io/RVS_BlueThoth/framework-internal/Protocols/CGA_BlueThoth_Delegate.html), that handles all responses from the SDK.

If you are implementing an application-focused layer over RVS_BlueThoth, then you may want to consider dividing this into Observers or Bindings. That's up to you. In order to use the SDK, you need to have a single delegate that can handle the various callbacks, and dispatch them accordingly.

The delegate is "one-way," like an observer. It receives callbacks from the SDK, and does not respond in any way.

All delegate callbacks are in the main thread.

The delegate needs to be a class (as opposed to a struct), and is weakly referenced from within the SDK (meaning that you need to make sure that it stays around).

Examples of the delegate in the four test harnesses are in the following source files:

- [The iOS Test Harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Tests/RVS_BlueThoth_Test_Harness_iOS/Source/View%20Controllers/Navigation%20Screens/CGA_InitialViewController.swift)
- [The MacOS Test Harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Tests/RVS_BlueThoth_Test_Harness_MacOS/Source/Main/RVS_BlueThoth_Test_Harness_MacOS_AppDelegate.swift)
- [The WatchOS Test Harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Tests/RVS_BlueThoth_Test_Harness_WatchOS/RVS_BlueThoth_Test_Harness_WatchOS_Extension/RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.swift)
- [The tvOS Test Harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Tests/RVS_BlueThoth_Test_Harness_tvOS/Source/Main/CGA_AppDelegate.swift)

## Creating An Instance

We start by instantiating [the RVS_BlueThoth class](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Sources/RVS_BlueThoth/RVS_BlueThoth.swift):

    CGA_AppDelegate.centralManager = RVS_BlueThoth(delegate: self)

This example is from [the tvOS Test Harness](https://github.com/RiftValleySoftware/RVS_BlueThoth/blob/master/Tests/RVS_BlueThoth_Test_Harness_tvOS/Source/View%20Controllers/Navigation/CGA_InitialViewController.swift)

Note that we provide the delegate immediately. It is likely to get a callback quickly, indicating that the Bluetooth system is set up, and ready to start scanning for peripherals.

## Scanning for Peripherals

Once the Bluetooth system is ready, we can start scanning for Peripherals (also from the tvOS test harness):

    centralManager?.scanCriteria = scanCriteria
    centralManager?.minimumRSSILevelIndBm = prefs.minimumRSSILevel
    centralManager?.discoverOnlyConnectablePeripherals = prefs.discoverOnlyConnectableDevices
    centralManager?.allowEmptyNames = prefs.allowEmptyNames
    centralManager?.startScanning(duplicateFilteringIsOn: !prefs.continuouslyUpdatePeripherals)

It is possible to set a few properties that control how to deal with discovered Peripherals.

From here, on, it is best to use [the API documentation](https://riftvalleysoftware.github.io/RVS_BlueThoth/framework-public/Classes/RVS_BlueThoth.html), or the [in-depth technical documentation]([the technical documentation](https://riftvalleysoftware.github.io/RVS_BlueThoth/framework-internal/Classes/RVS_BlueThoth.html)).