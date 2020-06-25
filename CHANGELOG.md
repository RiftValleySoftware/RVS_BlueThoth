# RVS_BlueThoth Change Log

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
