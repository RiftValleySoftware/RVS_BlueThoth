# RVS_BlueThoth Change Log

## 1.9.1

- **September 16, 2022**

- Updated to the latest tools.
- Updated SwiftLint

## 1.9.0

- **September 1, 2022**

- More changing implicit optionals to explicit ones.

## 1.8.0

- **August 30, 2022**

- Some basic work to make the API a bit more robust. This does introduce some minor changes to the API, as we are not publishing implicit optionals, anymore.

## 1.7.4

- **July 12, 2022**

- Just updated a couple of dependencies, used for the tests. No API changes.

## 1.7.3

- **June 26, 2022**

- Also changed the WatchOS and TVOS test harnesses to use the local module. No changes to API.

## 1.7.2

- **June 21, 2022**

- Changed the MacOS and iOS test harnesses to use the package, linked locally. No changes to API.

## 1.7.1

- **June 1, 2022**

- Lowered the MacOS requirement.
- Removed the dash-notation.
- Updated the `RVS_Generic_Swift_Toolbox` dependency.
- Updated the `RVS__Persistent_Prefs` dependency.

## 1.6.3

- **May 14, 2022**

- Updated the `RVS_Generic_Swift_Toolbox` dependency.
- Updated the `RVS__Persistent_Prefs` dependency.

## 1.6.2

- **January 27, 2022**

- Added support for DocC. No code or API changes.

## 1.6.1

- **December 14, 2021**

- Updated the tools.

## 1.6.0

- **September 23, 2021**

- Updated to work with the latest toolchains.

## 1.5.5

- **November 13, 2020**

- Addresses possible crashes, when reading descriptors. Unable to reproduce, but I think I can at least avoid crashes.

## 1.5.4

- **September 4, 2020**

- Addressed a possible crasher, in system IDs being provided with an offset, that could cause casting to overrun memory. The same bug resulted in incorrect readings of some integer values.

## 1.5.3

- **September 3, 2020**

- Added states for disconnecting or connecting to the discovery info type.
- Upped the dependency version for the included dependency.

## 1.5.2

- **August 24, 2020**

- Some minor documentation tweaks.
- Added the ability to change the timeout from an instance. Not super thread-safe, but it is not something that should ever give us that type of problem.

## 1.5.1

- **August 20, 2020**

- Updated the reported versions of all the test harnesses and the framework targets.
- Added a computed property to the AdvertisementData struct, to access advertised Services.
- Simplified the advertisement string display a bit, in the test harnesses.

## 1.5.0

- **August 18, 2020**

- This is the first "official" release.

## 1.4.2

- **August 15, 2020**

- Added WatchOS test harness.
- Some documentation fixes.
- Reorganized to create default SPM structure.
- Fixed a few minor issues with the SDK.

## 1.4.1

- **August 4, 2020**

- Added Mac test harness.
- Some minor fixes and work on the SDK.

## 1.4.0

- **July 28, 2020**

- Added write handling (Characteristics and Descriptors).
- Starting Mac Test Harness implementation (still incomplete).

## 1.3.0

- **July 5, 2020**

- Updated the dependencies to the latest (static) versions.
- Made the build product static.

## 1.2.2

- **June 25, 2020**

- Removed the prefs dependency from the package file, as it is not necessary for consumers of the package.

## 1.2.1

- **June 24, 2020**

- SPM had a number of issues. These have been addressed.

## 1.2.0

- **June 21, 2020**

- Adding test harness projects.
- Enabling Characteristic and Descriptor writes.
- Swapped Carthage out for SPM

## 1.0.7

- **May 4, 2020**

- Added placeholder source files for all the standard Apple Descriptors. They don't do anything -yet.

## 1.0.6

- **May 3, 2020**

- Added targets for WatchOS and TVOS.

## 1.0.5

- **May 2, 2020**

- Likely no operational change. Added a "Belt and Suspenders" check in the timeout, in case we ever get called after the timer was cleared (Hey, you never know).

## 1.0.4

- **May 2, 2020**

- Added support for the Characteristic Presentation Format Descriptor.

## 1.0.3

- **May 1, 2020**

- Added support for the User Description Descriptor.

## 1.0.2

- **April 30, 2020**

- Added support for the Characteristic Extended Properties Descriptor.
