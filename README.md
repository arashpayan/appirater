Introduction
------------
Appirater is a class that you can drop into any iPhone app (iOS 4.0 or later) that will help remind your users
to review your app on the App Store. The code is released under the MIT/X11, so feel free to
modify and share your changes with the world. To find out more, check out the [project
homepage] [homepage].


Getting Started
---------------
1. Add the Appirater code into your project.
2. Add the `CFNetwork` and `SystemConfiguration` frameworks to your project.
3. Call `[Appirater setAppId:@"yourAppId"]` with the app id provided by Apple. A good place to do this is at the beginning of your app delegate's `application:didFinishLaunchingWithOptions:` method.
4. Call `[Appirater appLaunched:YES]` at the end of your app delegate's `application:didFinishLaunchingWithOptions:` method.
5. Call `[Appirater appEnteredForeground:YES]` in your app delegate's `applicationWillEnterForeground:` method.
6. (OPTIONAL) Call `[Appirater userDidSignificantEvent:YES]` when the user does something 'significant' in the app.

Configuration
-------------

Appirater provides class methods to configure its behavior. See [`Appirater.h`] [Appirater.h] for more information.

    [Appirater setAppId:@"552035781"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:YES];

License
-------
Copyright 2012. [Arash Payan] [arash].
This library is distributed under the terms of the MIT/X11.

While not required, I greatly encourage and appreciate any improvements that you make
to this library be contributed back for the benefit of all who use Appirater.

MonoTouch Port
--------------
[Ivan Nikitin] [ivan] has ported Appirater to MonoTouch. You can find [it here on github] [monotouchport].

[homepage]: http://arashpayan.com/blog/index.php/2009/09/07/presenting-appirater/
[arash]: http://arashpayan.com
[ivan]: https://www.facebook.com/nikitinivan
[monotouchport]: https://github.com/chebum/Appirater-for-MonoTouch
[Appirater.h]: https://github.com/arashpayan/appirater/blob/master/Appirater.h