Introduction
---------------

Appirater is a class that you can drop into any iPhone app (iOS 4.0 or later) that will help remind your users to review your app on the App Store. The code is released under the MIT/X11, so feel free to modify and share your changes with the world. Read on below for how to get started. If you need any help using, the library, post your questions on [Stack Overflow] [stackoverflow] under the `appirater` tag.

Getting Started
---------------

### CocoaPods
To add Appirater to your app, add `pod "Appirater"` to your Podfile.

Configuration
-------------
1. Appirater provides class methods to configure its behavior. See [`Appirater.h`] [Appirater.h] for more information.

```objc
[Appirater setAppId:@"552035781"];
[Appirater setDaysUntilPrompt:1];
[Appirater setUsesUntilPrompt:10];
[Appirater setSignificantEventsUntilPrompt:-1];
[Appirater setTimeBeforeReminding:2];
[Appirater setDebug:YES];
```

2. Call `[Appirater setAppId:@"yourAppId"]` with the app id provided by Apple. A good place to do this is at the beginning of your app delegate's `application:didFinishLaunchingWithOptions:` method.
3. Call `[Appirater appLaunched:YES]` at the end of your app delegate's `application:didFinishLaunchingWithOptions:` method.
4. Call `[Appirater appEnteredForeground:YES]` in your app delegate's `applicationWillEnterForeground:` method.
5. (OPTIONAL) Call `[Appirater userDidSignificantEvent:YES]` when the user does something 'significant' in the app.

### Development
Setting `[Appirater setDebug:YES]` will ensure that the rating request is shown each time the app is launched.

### Production
Make sure you set `[Appirater setDebug:NO]` to ensure the request is not shown every time the app is launched. Also make sure that each of these components are set in the `application:didFinishLaunchingWithOptions:` method.

This example states that the rating request is only shown when the app has been launched 5 times **and** after 7 days.

```objc
[Appirater setAppId:@"770699556"];
[Appirater setDaysUntilPrompt:7];
[Appirater setUsesUntilPrompt:5];
[Appirater setSignificantEventsUntilPrompt:-1];
[Appirater setTimeBeforeReminding:2];
[Appirater setDebug:NO];
[Appirater appLaunched:YES];
```

If you wanted to show the request after 5 days only you can set the following:

```objc
[Appirater setAppId:@"770699556"];
[Appirater setDaysUntilPrompt:5];
[Appirater setUsesUntilPrompt:0];
[Appirater setSignificantEventsUntilPrompt:-1];
[Appirater setTimeBeforeReminding:2];
[Appirater setDebug:NO];
[Appirater appLaunched:YES];
```

SKStoreReviewController
----------------------
In iOS 10.3, [SKStoreReviewController](https://developer.apple.com/library/content/releasenotes/General/WhatsNewIniOS/Articles/iOS10_3.html) was introduced which allows rating directly within the app without any additional setup.

Appirater automatically uses `SKStoreReviewController` if available. You'll need to manually link `StoreKit` in your App however.

If `SKStoreReviewController` is used, Appirater is used only to decide when to show the rating dialog to the user. Keep in mind, that `SKStoreReviewController` automatically limits the number of impressions, so the dialog might be displayed less frequently than your configured conditions might suggest.

License
-------
Copyright 2017. [Arash Payan] [arash].
This library is distributed under the terms of the MIT/X11.

While not required, I greatly encourage and appreciate any improvements that you make
to this library be contributed back for the benefit of all who use Appirater.

Ports for other SDKs
--------------
A few people have ported Appirater to other SDKs. The ports are listed here in hopes that they may assist developers of those SDKs. I don't know how closesly (if at all) they track the Objective-C version of Appirater. If you need support for any of the libraries, please contact the maintainer of the port.

+ MonoTouch Binding (using native Appirater). [Github] [monotouchbinding]

[stackoverflow]: http://stackoverflow.com/
[homepage]: https://arashpayan.com/blog/2009/09/07/presenting-appirater/
[arash]: https://arashpayan.com
[Appirater.h]: https://github.com/arashpayan/appirater/blob/master/Appirater.h
[monotouchbinding]: https://github.com/theonlylawislove/MonoTouch.Appirater
