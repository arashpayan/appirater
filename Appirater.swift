/*
This file is part of Appirater.

Copyright (c) 2012, Arash Payan
All rights reserved.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
//
//  Appirater.swift
//
//  Created by SeokWon Cheul on 2016. 1. 9..
//  Copyright © 2016년 won cheulseok. All rights reserved.
//

import Foundation
import SystemConfiguration
import StoreKit

@objc
protocol AppiraterDelegate : class {
    optional func appiraterShouldDisplayAlert(appirater : Appirater) -> Bool
    optional func appiraterDidDisplayAlert(appirater : Appirater)
    optional func appiraterDidDeclineToRate(appirater : Appirater)
    optional func appiraterDidOptToRate(appirater : Appirater)
    optional func appiraterDidOptToRemindLater(appirater : Appirater)
    optional func appiraterWillPresentModalView(appirater : Appirater, animated:Bool)
    optional func appiraterDidDismissModalView(appirater : Appirater, animated:Bool)
}

class Appirater: NSObject, UIAlertViewDelegate, SKStoreProductViewControllerDelegate {
    
    private static let kFirstUseDate            = "kFirstUseDate"
    private static let kUseCount				= "kUseCount"
    private static let kSignificantEventCount	= "kSignificantEventCount"
    private static let kCurrentVersion			= "kCurrentVersion"
    private static let kRatedCurrentVersion		= "kRatedCurrentVersion"
    private static let kDeclinedToRate			= "kDeclinedToRate"
    private static let kReminderRequestDate		= "kReminderRequestDate"

    private static var templateReviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID"
    private static var templateReviewURLiOS7 = "itms-apps://itunes.apple.com/app/idAPP_ID"
    private static var templateReviewURLiOS8 = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"

    /*!
    Your localized app's name.
    */
    static var LOCALIZED_APP_NAME : String? {
        get {
            return NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String
        }
    }
    
    /*!
    Your app's name.
    */
    static var APP_NAME : String {
        get {
            if let localizedAppName = self.LOCALIZED_APP_NAME
            {
                return localizedAppName
                
            }else if let displayName = NSBundle.mainBundle().infoDictionary?["CFBundleDisplayName"]
            {
                return displayName as! String
            }else
            {
                return NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
            }
        }
    }
    /*!
    This is the message your users will see once they've passed the day+launches
    threshold.
    */
    static var LOCALIZED_MESSAGE : String {
        
        get {
            return NSLocalizedString("If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", tableName: "AppiraterLocalizable", bundle: Appirater.bundle(), comment: "")
        }
    }
    private static var APPIRATER_MESSAGE : String {
        get {
            return String(format: self.LOCALIZED_MESSAGE, self.APP_NAME)
        }
    }
    
    /*!
    This is the title of the message alert that users will see.
    */
    static var LOCALIZED_MESSAGE_TITLE : String {
        get {
            return NSLocalizedString("Rate %", tableName: "AppiraterLocalizable", bundle: Appirater.bundle(), comment: "")
        }
    }
    private static var APPIRATER_MESSAGE_TITLE : String {
        get {
            return String(format: self.LOCALIZED_MESSAGE_TITLE, self.APP_NAME)
        }
    }
    
    /*!
    The text of the button that rejects reviewing the app.
    */
    static var CANCEL_BUTTON : String {
        get {
            return NSLocalizedString("No, Thanks", tableName: "AppiraterLocalizable", bundle: Appirater.bundle(), comment: "")
        }
    }

    /*!
    Text of button that will send user to app review page.
    */
    static var LOCALIZED_RATE_BUTTON : String {
        get {
            return NSLocalizedString("Rate %@", tableName: "AppiraterLocalizable", bundle: Appirater.bundle(), comment: "")
        }
    }
    private static var RATE_BUTTON : String {
        get {
            return String(format: self.LOCALIZED_RATE_BUTTON, self.APP_NAME)
        }
    }
    
    /*!
    Text for button to remind the user to review later.
    */
    static var RATE_LATER : String {
        get {
            return NSLocalizedString("Remind me later", tableName: "AppiraterLocalizable", bundle: Appirater.bundle(), comment: "")
        }
    }
    private class func bundle() -> NSBundle
    {
        var bundle : NSBundle
        
        if self._alwaysUseMainBundle
        {
            bundle = NSBundle.mainBundle()
        } else if let appiraterBundleURL = NSBundle.mainBundle().URLForResource("Appirater", withExtension:"bundle")
        {
            // Appirater.bundle will likely only exist when used via CocoaPods
            bundle = NSBundle(URL:appiraterBundleURL)!
        } else
        {
            bundle = NSBundle.mainBundle()
        }
        
        return bundle
    }
    
    // Shared Instance
    private static var _appirater : Appirater? = nil
    private static var onceToken : dispatch_once_t = 0
    static var sharedInstance : Appirater {
        
        get {
            
            if (self._appirater == nil)
            {
                dispatch_once(&(self.onceToken), { () -> Void in
                    self._appirater = Appirater()
                    self._appirater!.delegate = self._delegate
                    NSNotificationCenter.defaultCenter().addObserver(self, selector:"appWillResignActive", name:UIApplicationWillResignActiveNotification, object:nil)
                })
            }
            
            return self._appirater!
        }
    }
    /*!
    Set customized title for alert view.
    */
    class func setCustomAlertTitle(title:String) {
        self.sharedInstance.alertTitle = title
    }
    
    /*!
    Set customized message for alert view.
    */
    class func setCustomAlertMessage(message : String) {
        self.sharedInstance.alertMessage = message
    }
   
    /*!
    Set customized cancel button title for alert view.
    */
    class func setCustomAlertCancelButtonTitle(title : String) {
        self.sharedInstance.alertCancelTitle = title
    }
    
    /*!
    Set customized rate button title for alert view.
    */
    class func setCustomAlertRateButtonTitle(title : String) {
        self.sharedInstance.alertRateLaterTitle = title
    }
    /*!
    Set customized rate later button title for alert view.
    */
    class func setCustomAlertRateLaterButtonTitle(title : String) {
        self.sharedInstance.alertRateLaterTitle = title
    }
   
    /*!
    If set to YES, Appirater will open App Store link (instead of SKStoreProductViewController on iOS 6). Default YES.
    */
    class func setOpenInAppStore(openInStore : Bool) {
        self.sharedInstance.openInAppStore = openInStore
    }
    
    private static var _appId : String?
    /*!
    Set your Apple generated software id here.
    */
    class func setAppId(appId : String) {
        self._appId = appId
    }

    private static var _daysUntilPrompt : Double = 30
    /*!
    Users will need to have the same version of your app installed for this many
    days before they will be prompted to rate it.
    */
    class func setDaysUntilPrompt(days:Double) {
        self._daysUntilPrompt = days
    }

    
    private static var _usesUntilPrompt : Int = 20
    /*!
    An example of a 'use' would be if the user launched the app. Bringing the app
    into the foreground (on devices that support it) would also be considered
    a 'use'. You tell Appirater about these events using the two methods:
    [Appirater appLaunched:]
    [Appirater appEnteredForeground:]
    
    Users need to 'use' the same version of the app this many times before
    before they will be prompted to rate it.
    */
    class func setUsesUntilPrompt(count : Int) {
        self._usesUntilPrompt = count
    }

    private static var _significantEventsUntilPrompt : Int = -1
    /*!
    A significant event can be anything you want to be in your app. In a
    telephone app, a significant event might be placing or receiving a call.
    In a game, it might be beating a level or a boss. This is just another
    layer of filtering that can be used to make sure that only the most
    loyal of your users are being prompted to rate you on the app store.
    If you leave this at a value of -1, then this won't be a criterion
    used for rating. To tell Appirater that the user has performed
    a significant event, call the method:
    [Appirater userDidSignificantEvent:]
    */
    class func setSignificantEventsUntilPrompt(count : Int) {
        self._significantEventsUntilPrompt = count
    }
    
    private static var _timeBeforeReminding : Double = 1
    /*!
    Once the rating alert is presented to the user, they might select
    'Remind me later'. This value specifies how long (in days) Appirater
    will wait before reminding them.
    */
    class func setTimeBeforeReminding(count : Double) {
        self._timeBeforeReminding = count
    }
    
    private static var _debug : Bool = false
    /*!
    'YES' will show the Appirater alert everytime. Useful for testing how your message
    looks and making sure the link to your app's review page works.
    */
    class func setDebug(debug : Bool) {
        self._debug = debug
    }
    
    private static weak var _delegate : AppiraterDelegate?
    /*!
    Set the delegate if you want to know when Appirater does something
    */
    class func setDelegate(delegate : AppiraterDelegate) {
        self._delegate = delegate
    }

    private static var _usesAnimation : Bool = true
    /*!
    Set whether or not Appirater uses animation (currently respected when pushing modal StoreKit rating VCs).
    */
    class func setUsesAnimation(animate : Bool) {
        self._usesAnimation = animate
    }

    private static var _statusBarStyle : UIStatusBarStyle = .Default
    private class func setStatusBarStyle(style : UIStatusBarStyle) {
        self._statusBarStyle = style
    }

    private static var _modalOpen : Bool = false
    private class func setModalOpen(modalOpen : Bool) {
        self._modalOpen = modalOpen
    }

    private static var _alwaysUseMainBundle : Bool = false
    /*!
    If set to YES, the main bundle will always be used to load localized strings.
    Set this to YES if you have provided your own custom localizations in AppiraterLocalizable.strings
    in your main bundle.  Default is NO.
    */
    class func setAlwaysUseMainBundle(alwaysUseMainBundle : Bool) {
        self._alwaysUseMainBundle = alwaysUseMainBundle
    }

    var ratingAlert : UIAlertView?
    var openInAppStore : Bool
    weak var delegate : AppiraterDelegate?

    // TODO: Obj-C implements has these properties with copy attribute but swift doesn't
    private var _alertTitle : String?
    private var alertTitle : String {
        get
        {
            return self._alertTitle != nil ? self._alertTitle! : Appirater.APPIRATER_MESSAGE_TITLE
        }
        set {
            self._alertTitle = newValue
        }
    }

    // TODO: Obj-C implements has these properties with copy attribute but swift doesn't
    private var _alertMessage : String?
    private var alertMessage : String {
        get
        {
            return self._alertMessage != nil ? self._alertMessage! : Appirater.APPIRATER_MESSAGE
        }
        set
        {
            self._alertMessage = newValue
        }
    }

    // TODO: Obj-C implements has these properties with copy attribute but swift doesn't
    private var _alertCancelTitle : String?
    private var alertCancelTitle : String {
        get
        {
            return self._alertCancelTitle != nil ? self._alertCancelTitle! : Appirater.CANCEL_BUTTON
        }
        set
        {
            self._alertCancelTitle = newValue
        }
    }

    // TODO: Obj-C implements has these properties with copy attribute but swift doesn't
    private var _alertRateTitle : String?
    private var alertRateTitle : String {
        get
        {
            return self._alertRateTitle != nil ? self._alertRateTitle! : Appirater.RATE_BUTTON
        }
        set
        {
            self._alertRateTitle = newValue
        }
    }
    // TODO: Obj-C implements has these properties with copy attribute but swift doesn't
    private var _alertRateLaterTitle : String?
    private var alertRateLaterTitle : String {
        get
        {
            return self._alertRateLaterTitle != nil ? self._alertRateLaterTitle! : Appirater.RATE_LATER
        }
        set
        {
            self._alertRateLaterTitle = newValue
        }
    }

    override init() {
        let systemVersion = UIDevice.currentDevice().systemVersion as NSString
        if systemVersion.floatValue >= 7.0 {
            self.openInAppStore = true
        } else {
            self.openInAppStore = false
        }

        super.init()
    }
   
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let reachabilityRef = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return false }

        var flags = SCNetworkReachabilityFlags()
        let didRetrieveFlags = withUnsafeMutablePointer(&flags) {
            SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
        }
    
        if (!didRetrieveFlags)
        {
            print("Error. Could not recover network reachability flags")
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        let nonWiFi = flags.contains(.TransientConnection)

        let testURL = NSURL(string:"http://www.apple.com/")
        let testRequest = NSURLRequest(URL:testURL!,  cachePolicy:NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval:20.0)
        let testConnection = NSURLConnection(request:testRequest, delegate:self)
        
        return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection != nil ? true : false) : false
    }
    
    
    private func showRatingAlert(displayRateLaterButton: Bool)
    {
        var alertView: UIAlertView?
        let delegate = self.delegate
        if delegate?.appiraterShouldDisplayAlert?(self) == false {
            return
        }
        
        if displayRateLaterButton {
           
            alertView = UIAlertView(title:self.alertTitle,
                message:self.alertMessage,
                delegate:self,
                cancelButtonTitle:self.alertCancelTitle,
                otherButtonTitles:self.alertRateTitle, self.alertRateLaterTitle)
        } else {
            alertView = UIAlertView(title:self.alertTitle,
                message:self.alertMessage,
                delegate:self,
                cancelButtonTitle:self.alertCancelTitle,
                otherButtonTitles:self.alertRateTitle)
        }
        
        self.ratingAlert = alertView!
        alertView!.show()
        
        delegate?.appiraterDidDisplayAlert?(self)
    }
    
    private func showRatingAlert()
    {
        self.showRatingAlert(true)
    }
    
    // is this an ok time to show the alert? (regardless of whether the rating conditions have been met)
    //
    // things checked here:
    // * connectivity with network
    // * whether user has rated before
    // * whether user has declined to rate
    // * whether rating alert is currently showing visibly
    // things NOT checked here:
    // * time since first launch
    // * number of uses of app
    // * number of significant events
    // * time since last reminder
    private func ratingAlertIsAppropriate() -> Bool
    {
        return self.connectedToNetwork()
            && !self.userHasDeclinedToRate()
            && !self.ratingAlert!.visible
            && !self.userHasRatedCurrentVersion()
    }
    
    // have the rating conditions been met/earned? (regardless of whether this would be a moment when it's appropriate to show a new rating alert)
    //
    // things checked here:
    // * time since first launch
    // * number of uses of app
    // * number of significant events
    // * time since last reminder
    // things NOT checked here:
    // * connectivity with network
    // * whether user has rated before
    // * whether user has declined to rate
    // * whether rating alert is currently showing visibly
    private func ratingConditionsHaveBeenMet() -> Bool
    {
        if Appirater._debug {
            return true
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let dateOfFirstLaunch = NSDate(timeIntervalSince1970:userDefaults.doubleForKey(Appirater.kFirstUseDate))
        let timeSinceFirstLaunch = NSDate().timeIntervalSinceDate(dateOfFirstLaunch)
        let timeUntilRate = 60 * 60 * 24 * Appirater._daysUntilPrompt
        if timeSinceFirstLaunch < timeUntilRate {return false}
        
        // check if the app has been used enough
        let useCount = userDefaults.integerForKey(Appirater.kUseCount)
        if useCount < Appirater._usesUntilPrompt { return false }
        
        // check if the user has done enough significant events
        let sigEventCount = userDefaults.integerForKey(Appirater.kSignificantEventCount)
        if (sigEventCount < Appirater._significantEventsUntilPrompt) { return false }
        
        // if the user wanted to be reminded later, has enough time passed?
        let reminderRequestDate = NSDate(timeIntervalSince1970:userDefaults.doubleForKey(Appirater.kReminderRequestDate))
        let timeSinceReminderRequest = NSDate().timeIntervalSinceDate(reminderRequestDate)
        let timeUntilReminder = 60 * 60 * 24 * Appirater._timeBeforeReminding
        if timeSinceReminderRequest < timeUntilReminder {return false}
        
        return false
    }
    
    private func incrementUseCount() {
        // get the app's version
        let version = NSBundle.mainBundle().infoDictionary![kCFBundleVersionKey as String]! as! String
        
        // get the version number that we've been tracking
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var trackingVersion = userDefaults.stringForKey(Appirater.kCurrentVersion)
        if trackingVersion == nil
        {
            trackingVersion = version
            userDefaults.setObject(version, forKey:Appirater.kCurrentVersion)
        }
        
        if Appirater._debug
        {
            print("APPIRATER Tracking version: \(trackingVersion)")
        }
        
        if trackingVersion == version
        {
            // check if the first use date has been set. if not, set it.
            var timeInterval = userDefaults.doubleForKey(Appirater.kFirstUseDate)
            if timeInterval == 0
            {
                timeInterval = NSDate().timeIntervalSince1970
                userDefaults.setDouble(timeInterval, forKey:Appirater.kFirstUseDate)
            }
            
            // increment the use count
            var useCount = userDefaults.integerForKey(Appirater.kUseCount)
            useCount++
            userDefaults.setInteger(useCount, forKey:Appirater.kUseCount)
            if Appirater._debug
            {
                print("APPIRATER Use count: \(useCount)")
            }
        }
        else
        {
            // it's a new version of the app, so restart tracking
            userDefaults.setObject(version, forKey:Appirater.kCurrentVersion)
            userDefaults.setDouble(NSDate().timeIntervalSince1970, forKey:Appirater.kFirstUseDate)
            userDefaults.setInteger(1, forKey:Appirater.kUseCount)
            userDefaults.setInteger(0, forKey:Appirater.kSignificantEventCount)
            userDefaults.setBool(false, forKey:Appirater.kRatedCurrentVersion)
            userDefaults.setBool(false, forKey:Appirater.kDeclinedToRate)
            userDefaults.setDouble(0, forKey:Appirater.kReminderRequestDate)
        }
        
        userDefaults.synchronize()
    }
    
    private func incrementSignificantEventCount() {
        // get the app's version
        let version = NSBundle.mainBundle().infoDictionary![kCFBundleVersionKey as String] as! String
        
        // get the version number that we've been tracking
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var trackingVersion = userDefaults.stringForKey(Appirater.kCurrentVersion)
        if trackingVersion == nil
        {
            trackingVersion = version
            userDefaults.setObject(version, forKey:Appirater.kCurrentVersion)
        }
        
        if Appirater._debug
        {
            NSLog("APPIRATER Tracking version: \(trackingVersion)")
        }
        if trackingVersion == version
        {
            // check if the first use date has been set. if not, set it.
            var timeInterval = userDefaults.doubleForKey(Appirater.kFirstUseDate)
            if timeInterval == 0
            {
                timeInterval = NSDate().timeIntervalSince1970
                userDefaults.setDouble(timeInterval, forKey:Appirater.kFirstUseDate)
            }
            
            // increment the significant event count
            var sigEventCount = userDefaults.integerForKey(Appirater.kSignificantEventCount)
            sigEventCount++
            userDefaults.setInteger(sigEventCount, forKey:Appirater.kSignificantEventCount)
            if Appirater._debug
            {
                print("APPIRATER Significant event count: \(sigEventCount)")
            }
        }
        else
        {
            // it's a new version of the app, so restart tracking
            userDefaults.setObject(version, forKey:Appirater.kCurrentVersion)
            userDefaults.setDouble(0, forKey:Appirater.kFirstUseDate)
            userDefaults.setInteger(0, forKey:Appirater.kUseCount)
            userDefaults.setInteger(1, forKey:Appirater.kSignificantEventCount)
            userDefaults.setBool(false, forKey:Appirater.kRatedCurrentVersion)
            userDefaults.setBool(false, forKey:Appirater.kDeclinedToRate)
            userDefaults.setDouble(0, forKey:Appirater.kReminderRequestDate)
        }
        
        userDefaults.synchronize()
    }
    
    private func incrementAndRate(canPromptForRating : Bool)
    {
        self.incrementUseCount()
        
        if canPromptForRating &&
            self.ratingConditionsHaveBeenMet() &&
            self.ratingAlertIsAppropriate()
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showRatingAlert()
            })
        }
    }
    
    private func incrementSignificantEventAndRate(canPromptForRating:Bool)
    {
        self.incrementSignificantEventCount()
        
        if canPromptForRating &&
            self.ratingConditionsHaveBeenMet() &&
            self.ratingAlertIsAppropriate()
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showRatingAlert()
            })
        }
    }
    /*!
    Asks Appirater if the user has declined to rate
    */

    func userHasDeclinedToRate() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(Appirater.kDeclinedToRate)
    }
    /*!
    Asks Appirater if the user has rated the current version.
    Note that this is not a guarantee that the user has actually rated the app in the
    app store, but they've just clicked the rate button on the Appirater dialog.
    */
    func userHasRatedCurrentVersion() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(Appirater.kRatedCurrentVersion)
    }
    
    
    /*!
    Tells Appirater that the app has launched, and on devices that do NOT
    support multitasking, the 'uses' count will be incremented. You should
    call this method at the end of your application delegate's
    application:didFinishLaunchingWithOptions: method.
    
    If the app has been used enough to be rated (and enough significant events),
    you can suppress the rating alert
    by passing NO for canPromptForRating. The rating alert will simply be postponed
    until it is called again with YES for canPromptForRating. The rating alert
    can also be triggered by appEnteredForeground: and userDidSignificantEvent:
    (as long as you pass YES for canPromptForRating in those methods).
    */

    class func appLaunched(canPromptForRating : Bool)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            
            let a = Appirater.sharedInstance
            if Appirater._debug
            {
                dispatch_async(dispatch_get_main_queue(), {
                    a.showRatingAlert()
                })
            } else {
                a.incrementAndRate(canPromptForRating)
            }
        })
    }
    private func hideRatingAlert()
    {
        if (self.ratingAlert!.visible) {
            if Appirater._debug
            {
                print("APPIRATER Hiding Alert")
            }
            self.ratingAlert!.dismissWithClickedButtonIndex(-1, animated:false)
        }
    }
    
    private class func appWillResignActive()
    {
        if Appirater._debug
        {
            print("APPIRATER appWillResignActive")
        }
        Appirater.sharedInstance.hideRatingAlert()
    }
    /*!
    Tells Appirater that the app was brought to the foreground on multitasking
    devices. You should call this method from the application delegate's
    applicationWillEnterForeground: method.
    
    If the app has been used enough to be rated (and enough significant events),
    you can suppress the rating alert
    by passing NO for canPromptForRating. The rating alert will simply be postponed
    until it is called again with YES for canPromptForRating. The rating alert
    can also be triggered by appLaunched: and userDidSignificantEvent:
    (as long as you pass YES for canPromptForRating in those methods).
    */

    class func appEnteredForeground(canPromptForRating:Bool)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            Appirater.sharedInstance.incrementAndRate(canPromptForRating)
        })
    }
    
    /*!
    Tells Appirater that the user performed a significant event. A significant
    event is whatever you want it to be. If you're app is used to make VoIP
    calls, then you might want to call this method whenever the user places
    a call. If it's a game, you might want to call this whenever the user
    beats a level boss.
    
    If the user has performed enough significant events and used the app enough,
    you can suppress the rating alert by passing NO for canPromptForRating. The
    rating alert will simply be postponed until it is called again with YES for
    canPromptForRating. The rating alert can also be triggered by appLaunched:
    and appEnteredForeground: (as long as you pass YES for canPromptForRating
    in those methods).
    */

    class func userDidSignificantEvent(canPromptForRating : Bool)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            Appirater.sharedInstance.incrementSignificantEventAndRate(canPromptForRating)
        })
    }
    
    
    /*!
    Tells Appirater to try and show the prompt (a rating alert). The prompt will be showed
    if there is connection available, the user hasn't declined to rate
    or hasn't rated current version.
    
    You could call to show the prompt regardless Appirater settings,
    e.g., in case of some special event in your app.
    */
    class func tryToShowPrompt()
    {
        Appirater.sharedInstance.showPromptWithChecks(true,
            displayRateLaterButton:true)
    }
    /*!
    Tells Appirater to show the prompt (a rating alert).
    Similar to tryToShowPrompt, but without checks (the prompt is always displayed).
    Passing false will hide the rate later button on the prompt.
    
    The only case where you should call this is if your app has an
    explicit "Rate this app" command somewhere. This is similar to rateApp,
    but instead of jumping to the review directly, an intermediary prompt is displayed.
    */

    class func forceShowPrompt(displayRateLaterButton:Bool)
    {
        Appirater.sharedInstance.showPromptWithChecks(false,
            displayRateLaterButton:displayRateLaterButton)
    }
    private class func showPrompt()
    {
        Appirater.tryToShowPrompt()
    }
    private func showPromptWithChecks(withChecks:Bool, displayRateLaterButton:Bool) {
        if (withChecks == false) || self.ratingAlertIsAppropriate() {
            self.showRatingAlert(displayRateLaterButton)
        }
    }
    
    private class func getRootViewController() -> AnyObject?
    {
        let window = UIApplication.sharedApplication().keyWindow
        if window!.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.sharedApplication().windows
            for window in windows {
                if window.windowLevel == UIWindowLevelNormal {
                    break
                }
            }
        }
        
        return Appirater.iterateSubViewsForViewController(window!) // iOS 8+ deep traverse
    }
    
    private class func iterateSubViewsForViewController(parentView:UIView) -> AnyObject?
    {
        for subView in parentView.subviews
        {
            let responder = subView.nextResponder
            if responder is UIViewController {
                return self.topMostViewController(responder as! UIViewController)
            }
            
            if let found = Appirater.iterateSubViewsForViewController(subView) {
                return found
            }
        }
        return nil
    }
    
    private class func topMostViewController(var controller : UIViewController) -> UIViewController {
        var isPresenting = false
        repeat {
            // this path is called only on iOS 6+, so -presentedViewController is fine here.
            let presented = controller.presentedViewController
            isPresenting = presented != nil
            if(presented != nil) {
                controller = presented!
            }
            
        } while (isPresenting)
        
        return controller
    }
    /*!
    Tells Appirater to open the App Store page where the user can specify a
    rating for the app. Also records the fact that this has happened, so the
    user won't be prompted again to rate the app.
    
    The only case where you should call this directly is if your app has an
    explicit "Rate this app" command somewhere.  In all other cases, don't worry
    about calling this -- instead, just call the other functions listed above,
    and let Appirater handle the bookkeeping of deciding when to ask the user
    whether to rate the app.
    */

    class func rateApp()
    {
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey:kRatedCurrentVersion)
        userDefaults.synchronize()
        
        //Use the in-app StoreKit view if available (iOS 6) and imported. This works in the simulator.

        if !Appirater.sharedInstance.openInAppStore
        //&& (NSStringFromClass(SKStoreProductViewController.class) != nil)
        {
            
            let storeViewController = SKStoreProductViewController()
            let appId = NSNumber(integer:(Appirater._appId! as NSString).integerValue)
            storeViewController.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier:appId], completionBlock:nil)
            storeViewController.delegate = self.sharedInstance
            
            let delegate = self.sharedInstance.delegate
            delegate?.appiraterWillPresentModalView?(self.sharedInstance, animated: Appirater._usesAnimation)
            
            
            self.getRootViewController()!.presentViewController(storeViewController, animated:Appirater._usesAnimation, completion:{ () -> Void in
                
                self.setModalOpen(true)
                
                //Temporarily use a black status bar to match the StoreKit view.
                self.setStatusBarStyle(UIApplication.sharedApplication().statusBarStyle)
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent,  animated:Appirater._usesAnimation)
            })
            
            //Use the standard openUrl method if StoreKit is unavailable.
        }
        else
        {
            
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                print("APPIRATER NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.")
            #else
                var reviewURL = Appirater.templateReviewURL.stringByReplacingOccurrencesOfString("APP_ID", withString:String(format:"%@", Appirater._appId!))
                
                // iOS 7 needs a different templateReviewURL @see https://github.com/arashpayan/appirater/issues/131
                // Fixes condition @see https://github.com/arashpayan/appirater/issues/205
                let version = (UIDevice.currentDevice().systemVersion as NSString).floatValue
                if version >= 7.0 && version < 8.0 {
                    reviewURL = Appirater.templateReviewURLiOS7.stringByReplacingOccurrencesOfString("APP_ID", withString:String(format:"%@", Appirater._appId!))
                }
                    // iOS 8 needs a different templateReviewURL also @see https://github.com/arashpayan/appirater/issues/182
                else if version >= 8.0
                {
                    reviewURL = Appirater.templateReviewURLiOS8.stringByReplacingOccurrencesOfString("APP_ID", withString:String(format:"%@", Appirater._appId!))
                }
                
                UIApplication.sharedApplication().openURL(NSURL(string:reviewURL)!)
            #endif
        }
    }
    internal func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let delegate = Appirater._delegate
        
        switch (buttonIndex)
        {
        case 0:
            // they don't want to rate it
            userDefaults.setBool(true, forKey:Appirater.kDeclinedToRate)
            userDefaults.synchronize()
            delegate?.appiraterDidDeclineToRate?(self)
        case 1:
            // they want to rate it
            Appirater.rateApp()
            delegate?.appiraterDidOptToRate?(self)
        case 2:
            // remind them later
            userDefaults.setDouble(NSDate().timeIntervalSince1970, forKey:Appirater.kReminderRequestDate)
            userDefaults.synchronize()
            delegate?.appiraterDidOptToRemindLater?(self)
        default:
            break
        }
    }
    internal func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        Appirater.closeModal()
    }
    
    /*!
    Tells Appirater to immediately close any open rating modals (e.g. StoreKit rating VCs).
    */
    //Close the in-app rating (StoreKit) view and restore the previous status bar style.
    class func closeModal()
    {
        if Appirater._modalOpen
        {
            UIApplication.sharedApplication().setStatusBarStyle(Appirater._statusBarStyle, animated:Appirater._usesAnimation)
            let usedAnimation = Appirater._usesAnimation
            self.setModalOpen(false)
            
            // get the top most controller (= the StoreKit Controller) and dismiss it
            var presentingController = UIApplication.sharedApplication().keyWindow!.rootViewController
            presentingController = self.topMostViewController(presentingController!)
            presentingController!.dismissViewControllerAnimated(Appirater._usesAnimation, completion:{ () -> Void in
                let delegate = self.sharedInstance.delegate
                delegate?.appiraterDidDismissModalView?(self.sharedInstance, animated: usedAnimation)
            })
            Appirater.setStatusBarStyle(UIStatusBarStyle.Default)
        }
    }
    @available(*, deprecated=0.1)
    class func appLaunched()
    {
        Appirater.appLaunched(true)
    }
}
