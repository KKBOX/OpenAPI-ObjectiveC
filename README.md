# KKBOX Open API Developer SDK for iOS/macOS/watchOS/tvOS

Copyright © 2016-2019 KKBOX Technologies Limited

[![Actions Status](https://github.com/KKBOX/OpenAPI-ObjectiveC/workflows/Build/badge.svg)](https://github.com/KKBOX/OpenAPI-ObjectiveC/actions)&nbsp;
[![build](https://api.travis-ci.org/KKBOX/OpenAPI-ObjectiveC.svg)](https://travis-ci.org/KKBOX/OpenAPI-ObjectiveC)&nbsp;
[![License Apache](https://img.shields.io/badge/license-Apache-green.svg?style=flat)](https://raw.githubusercontent.com/KKBOX/OpenAPI-ObjectiveC/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/KKBOXOpenAPI.svg?style=flat)](http://cocoapods.org/pods/KKBOXOpenAPI)&nbsp;
[![Support](https://img.shields.io/badge/macOS-10.9-blue.svg)](https://www.apple.com/tw/macos)&nbsp;
[![Support](https://img.shields.io/badge/iOS-7-blue.svg)](https://www.apple.com/tw/ios)&nbsp;
[![Support](https://img.shields.io/badge/watchOS-2-blue.svg)](https://www.apple.com/tw/watchos)&nbsp;
[![Support](https://img.shields.io/badge/tvOS-9-blue.svg)](https://www.apple.com/tw/tvos)&nbsp;

## About

The SDK helps to access KKBOX's Open API. You can easily add the SDK to your
Xcode project, and start an app powered by KKBOX. You may obtain information
about song tracks, albums, artists and playlists as well.

The SDK is developed in Objective-C programing language, but you can still
bridge the SDK to your Swift code. You can use the SDK on various Apple
platforms such as iOS, macOS, watchOS and tvOS.

If you are looking for a pure Swift SDK, please take a look at
[KKBOX Open API Swift SDK](https://github.com/KKBOX/OpenAPI-Swift).

For further information, please visit
[KKBOX Developer Site](https://developer.kkbox.com).

## Requirement

The SDK supports

- 📱 iOS 7.x or above
- 💻 Mac OS X 10.9 or above
- ⌚️ watchOS 2.x or above
- 📺 tvOS 9.x or above

## Build ⚒

You need the latest Xcode and macOS. Xcode 10 and macOS 10.14 Mojave are
recommended.

## Installation

### Swift Package Manager

You can install the library via Swift Package Manager (SPM). Just add the
following lines to your Package.swift file.

``` swift
dependencies: [
    .package(url: "https://github.com/KKBOX/OpenAPI-ObjectiveC.git", from: "0.1.0"),
],
```

Then run swift build.

Or, you can use the "Add Package Dependency" command under the "Swift Packages"
menu in Xcode 11.

### CocoaPods

The SDK supports CocoaPods. Please add `pod 'KKBOXOpenAPI'`
to your Podfile, and then call `pod install`.

## Usage

To start using the SDK, you need to create an instance of KKBOXOpenAPI.

```swift
let API = KKBOXOpenAPI(clientID: "YOUR_CLIENT_ID", secret: "YOUR_CLIENT_SECRET")
```

Then, ask the instance to fetch an access token by passing a client credential.

```swift
API.fetchAccessTokenByClientCredential { token, error in ... }
```

Finally, you can start to do the API calls. For example, you can fetch the details
of a song track by calling 'fetchTrack'.

```swift
self.API.fetchTrack(withTrackID: trackID, territory: .taiwan) { track, error in ... }
```

You can develop your app using the SDK with Swift or Objective-C programming
language, although we have only Swift sample code here.

The project contains a demo project. Please open KKBOXOpenAPI.xcodeproj
located in the "ExampleIOS" folder with Xcode and give it a try.

## API Documentation 📖

- Documentation for the SDK is available at https://kkbox.github.io/OpenAPI-ObjectiveC/ .
- KKBOX's Open API documentation is available at https://developer.kkbox.com/ .

## License

Copyright 2016-2019 KKBOX Technologies Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
