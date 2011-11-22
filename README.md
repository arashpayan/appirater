Introduction
------------
Appirater is a class that you can drop into any iPhone app that will help remind your users
to review your app on the App Store. The code is released under the MIT/X11, so feel free to
modify and share your changes with the world. To find out more, check out the [project
homepage] [homepage].

Getting Started
---------------
1. Add the Appirater code into your project
2. Add the `CFNetwork` and `SystemConfiguration` frameworks to your project
3. Call `[Appirater appLaunchedWithAppStoreID:APPIRATER_APP_ID canPromptForRating:YES]` at the end of your app delegate's `application:didFinishLaunchingWithOptions:` method, where `APPIRATER_APP_ID` is your Apple provided software id.
4. Call `[Appirater appEnteredForeground:YES]` in your app delegate's `applicationWillEnterForeground:` method.
5. (OPTIONAL) Call `[Appirater userDidSignificantEvent:YES]` when the user does something 'significant' in the app.

License
-------
Copyright 2010. [Arash Payan] [arash].
This library is distributed under the terms of the MIT/X11.

While not required, I greatly encourage and appreciate any improvements that you make
to this library be contributed back for the benefit of all who use Appirater.

[homepage]: http://arashpayan.com/blog/index.php/2009/09/07/presenting-appirater/
[arash]: http://arashpayan.com