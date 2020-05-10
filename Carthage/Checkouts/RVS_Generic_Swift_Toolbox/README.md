![Icon](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/raw/master/icon.png)

RVS_Generic_Swift_Toolbox
=

***Version:*** *1.0.5 (April 21, 2020)*

[This is the technical documentation for this repository](https://riftvalleysoftware.github.io/RVS_Generic_Swift_Toolbox/)

DESCRIPTION
-
This repository is an Xcode project with a set of ambidextrous (That's what I really mean by "generic"; not just using generics) tools that can be applied to Swift projects deployed for [iOS](https://apple.com/ios), [iPadOS](https://apple.com/ipados), [MacOS](https://apple.com/macos), [WatchOS](https://apple.com/watchos) and [TVOS](https://apple.com/tvos).

These tools will work for all of these platforms, and will, at most, rely only on [the Foundation library](https://developer.apple.com/documentation/foundation).

- [**COLLECTION TOOLS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/src/Collection%20Tools)
    - [**RVS_FIFOQueue**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/src/Collection%20Tools/RVS_FIFOQueue.swift)

        This is a high-performance generic FIFO queue data structure. It's based on the work of [Ole Begemann](https://oleb.net), who used it as an example in his [Advanced Swift](https://oleb.net/advanced-swift/) book.
    - [**RVS_SequenceProtocol**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/src/Collection%20Tools/RVS_SequenceProtocol.swift)
    
        This is a simple protocol that gives classes and structs that conform to it some basic [Sequence](https://developer.apple.com/documentation/swift/sequence) behavior.

- [**DEBUG TOOLS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/src/Debug%20Tools)
    - [**RVS_DebugTools**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/src/Debug%20Tools/RVS_DebugTools.swift)
    
        This is a set of tools used to aid debugging and testing code.

- [**EXTENSIONS**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/tree/master/src/Extensions)
    - [**RVS_Int_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/src/Extensions/RVS_Int_Extensions.swift)
    
        Extensions to integer data types.
        
    - [**RVS_String_Extensions**](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/blob/master/src/Extensions/RVS_String_Extensions.swift)
    
        Extensions to the [StringProtocol protocol](https://developer.apple.com/documentation/swift/stringprotocol). This adds some significant capabilities, such as [MD5](https://en.wikipedia.org/wiki/MD5)/[SHA](https://en.wikipedia.org/wiki/Secure_Hash_Algorithms)-hashing, substring searching, simple localization, and basic parsing.

USAGE
-
- [**Carthage**](https://github.com/Carthage/Carthage)

    You are probably best off using Carthage to install these tools. It's extremely simple to use, and squeaky clean. You will only need to include references to the files into your project.
    You implement it by adding the following line in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md):

    `github "RiftValleySoftware/RVS_Generic_Swift_Toolbox"`
    
    Once you have done this, navigate the Terminal to the directory containing the Cartfile, and execute:
    
    `carthage update`
    
    You will likely see the following output:
    
        Dependency "RVS_Generic_Swift_Toolbox" has no shared framework schemes

        If you believe this to be an error, please file an issue with the maintainers at     https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox/issues/new
        *** Skipped building RVS_PersistentPrefs due to the error:
        Dependency "RVS_PersistentPrefs" has no shared framework schemes

        If you believe this to be an error, please file an issue with the maintainers at    https://github.com/RiftValleySoftware/RVS_PersistentPrefs/issues/new
        
    You can safely ignore this.

    This will result in a directory, at the same level as the Cartfile, called `Carthage`. Inside of that directory, will be another directory, called `Checkouts`. Inside of that directory, will be a directory called `RVS_Generic_Swift_Toolbox`.
    The files that you are looking for will be in the `src` directory. They are arranged in the grouping they are documented, above.
    
    Just drag those files into your Xcode project, and add them to the appropriate targets.
    
- **[Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules)**

    You could also directly include the project as a Git Submodule.  Submodules can be annoying to work with, but are a good way to maintain ironclad version integrity.
    If you do this, then you should do the same as above, but instead of a Carthage directory, you will have whatever directory you choose to use to place the submodule.

REQUIREMENTS
-
These utilities require [the Swift programming language](https://developer.apple.com/swift/), and are not designed to be abstracted via a framework or bundle. They should be directly added to the source of your intended application.

LICENSE
-
© Copyright 2019, [The Great Rift Valley Software Company](https://riftvalleysoftware.com)

[MIT License](https://opensource.org/licenses/MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
