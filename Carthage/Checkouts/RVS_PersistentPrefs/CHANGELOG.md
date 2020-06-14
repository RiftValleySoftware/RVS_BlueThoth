*Version 1.0.6* **June 7, 2020**
- Changed a silly typo in a test variable name.
- Made a number of fairly fundamental changes to simplify the structure.
- Swapped out the Pods SwiftLint for an embedded executable.
- Switched the String extension to use the Carthage one.
- Added CODEOWNERS


*Version 1.0.5* **May 8, 2020**
- Very minor change to replace an antiquated self reference.
- The Mac test harness needed to have its window set as the initial controller.

*Version 1.0.4* **January 12, 2020**
- No operational changes. Added some extra documentation, and tweaked the README a bit.

*Version 1.0.3* **November 4, 2019**
- No operational changes. Only the project was updated, and the documentation was updated to include a section on using Carthage.

*Version 1.0.2* **October 1, 2019**
- Added support for deletion of the prefs, if the values Array is empty.
- Fixed an issue, where the values array was not being cleared before a load().

*Version 1.0.1* **September 1, 2019**
- Made the values Dictionary KVO-observable.
- Added the missing launchimage for the tvOS test harness.
- Added this file.

*Version 1.0.0* **August 24, 2019**
- Initial Release.
