# RVS_BlueThoth Change Log

## 1.5.1.0000

- **August 20, 2020**

- Updated the reported versions of all the test harnesses and the framework targets.
- Added a computed property to the AdvertisementData struct, to access advertised Services.
- Simplified the advertisement string display a bit, in the test harnesses.

## 1.5.0.0000

- **August 18, 2020**

- This is the first "official" release.

## 1.4.2.0000

- **August 15, 2020**

- Added WatchOS test harness.
- Some documentation fixes.
- Reorganized to create default SPM structure.
- Fixed a few minor issues with the SDK.

## 1.4.1.0000

- **August 4, 2020**

- Added Mac test harness.
- Some minor fixes and work on the SDK.

## 1.4.0.0000

- **July 28, 2020**

- Added write handling (Characteristics and Descriptors).
- Starting Mac Test Harness implementation (still incomplete).

## 1.3.0.0000

- **July 5, 2020**

- Updated the dependencies to the latest (static) versions.
- Made the build product static.

## 1.2.2.0000

- **June 25, 2020**

- Removed the prefs dependency from the package file, as it is not necessary for consumers of the package.

## 1.2.1.0000

- **June 24, 2020**

- SPM had a number of issues. These have been addressed.

## 1.2.0.0000

- **June 21, 2020**

- Adding test harness projects.
- Enabling Characteristic and Descriptor writes.
- Swapped Carthage out for SPM

## 1.0.7.0000

- **May 4, 2020**

- Added placeholder source files for all the standard Apple Descriptors. They don't do anything -yet.

## 1.0.6.0000

- **May 3, 2020**

- Added targets for WatchOS and TVOS.

## 1.0.5.0000

- **May 2, 2020**

- Likely no operational change. Added a "Belt and Suspenders" check in the timeout, in case we ever get called after the timer was cleared (Hey, you never know).

## 1.0.4.0000

- **May 2, 2020**

- Added support for the Characteristic Presentation Format Descriptor.

## 1.0.3.0000

- **May 1, 2020**

- Added support for the User Description Descriptor.

## 1.0.2.0000

- **April 30, 2020**

- Added support for the Characteristic Extended Properties Descriptor.
