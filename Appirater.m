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
/*
 * Appirater.m
 * appirater
 *
 * Created by Arash Payan on 9/5/09.
 * http://arashpayan.com
 * Copyright 2012 Arash Payan. All rights reserved.
 */

#import "Appirater.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

NSString *const kAppiraterFirstUseDate				= @"kAppiraterFirstUseDate";
NSString *const kAppiraterUseCount					= @"kAppiraterUseCount";
NSString *const kAppiraterSignificantEventCount		= @"kAppiraterSignificantEventCount";
NSString *const kAppiraterCurrentVersion			= @"kAppiraterCurrentVersion";
NSString *const kAppiraterRatedCurrentVersion		= @"kAppiraterRatedCurrentVersion";
NSString *const kAppiraterDeclinedToRate			= @"kAppiraterDeclinedToRate";
NSString *const kAppiraterReminderRequestDate		= @"kAppiraterReminderRequestDate";
NSString *const kAppiraterDialogCount				= @"kAppiraterDialogCount";

NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";

NSString *const kConfigAppID                        = @"AppID";
NSString *const kConfigAppName                      = @"AppName";
NSString *const kConfigMessage                      = @"Message";
NSString *const kConfigMessageTitle                 = @"MessageTitle";
NSString *const kConfigCancelButton                 = @"CancelButton";
NSString *const kConfigRateButton                   = @"RateButton";
NSString *const kConfigRateLater                    = @"RateLater";
NSString *const kConfigDaysUntilPrompt              = @"DaysUntilPrompt";
NSString *const kConfigUsesUntilPrompt              = @"UsesUntilPrompt";
NSString *const kConfigSigEventsUntilPrompt         = @"SigEventsUntilPrompt";
NSString *const kConfigTimeBeforeReminding          = @"TimeBeforeReminding";
NSString *const kConfigLandscapeHideCancelCount     = @"LandscapeHideCancelCount";
NSString *const kConfigDebug                        = @"Debug";

@interface Appirater () {
@private
    NSDictionary *configuration;
    BOOL debug;
}

@property (nonatomic, readonly, getter = isDebug) BOOL debug;

- (BOOL)connectedToNetwork;
+ (Appirater*)sharedInstance;
- (void)showRatingAlert;
- (BOOL)ratingConditionsHaveBeenMet;
- (void)incrementUseCount;
- (void)hideRatingAlert;
- (NSString *)configurationStringForKey:(NSString *)key;
- (NSInteger)configurationIntegerForKey:(NSString *)key;

@end

@implementation Appirater

@synthesize ratingAlert;
@synthesize debug;

- (id)init {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];

        NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithCapacity:10];
        [defaults setObject:APPIRATER_APP_ID forKey:kConfigAppID];
        [defaults setObject:APPIRATER_APP_NAME forKey:kConfigAppName];
        [defaults setObject:APPIRATER_MESSAGE forKey:kConfigMessage];
        [defaults setObject:APPIRATER_MESSAGE_TITLE forKey:kConfigMessageTitle];
        [defaults setObject:APPIRATER_CANCEL_BUTTON forKey:kConfigCancelButton];
        [defaults setObject:APPIRATER_RATE_BUTTON forKey:kConfigRateButton];
        [defaults setObject:APPIRATER_RATE_LATER forKey:kConfigRateLater];
        [defaults setObject:[NSNumber numberWithInteger:APPIRATER_DAYS_UNTIL_PROMPT] forKey:kConfigDaysUntilPrompt];
        [defaults setObject:[NSNumber numberWithInteger:APPIRATER_USES_UNTIL_PROMPT] forKey:kConfigUsesUntilPrompt];
        [defaults setObject:[NSNumber numberWithInteger:APPIRATER_SIG_EVENTS_UNTIL_PROMPT] forKey:kConfigSigEventsUntilPrompt];
        [defaults setObject:[NSNumber numberWithInteger:APPIRATER_TIME_BEFORE_REMINDING] forKey:kConfigTimeBeforeReminding];
        [defaults setObject:[NSNumber numberWithInteger:APPIRATER_LANDSCAPE_HIDE_CANCEL_COUNT] forKey:kConfigLandscapeHideCancelCount];
        [defaults setObject:[NSNumber numberWithBool:APPIRATER_DEBUG] forKey:kConfigDebug];

        NSString *path = [bundle pathForResource:@"Appirater" ofType:@"plist"];
        NSDictionary *dict = path ? [NSDictionary dictionaryWithContentsOfFile:path] : nil;
        if (dict)
            [defaults addEntriesFromDictionary:dict];

        NSString *appName = [defaults objectForKey:kConfigAppName];
        for (NSString *key in [defaults allKeys]) {
            id value = [defaults objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                value = [value stringByReplacingOccurrencesOfString:@"%@" withString:appName];
                [defaults setObject:value forKey:key];
            }
        }

        configuration = [[NSDictionary alloc] initWithDictionary:defaults];
        debug = [[configuration objectForKey:kConfigDebug] boolValue];

        if (debug)
            NSLog(@"Appirater Config: %@", configuration);
    }
    return self;
}

- (void)dealloc {
    [configuration release];
    [super dealloc];
}

- (NSString *)configurationStringForKey:(NSString *)key {
    return [configuration objectForKey:key];
}

- (NSInteger)configurationIntegerForKey:(NSString *)key {
    return [[configuration objectForKey:key] integerValue];
}

- (BOOL)connectedToNetwork {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
	NSURLConnection *testConnection = [[[NSURLConnection alloc] initWithRequest:testRequest delegate:self] autorelease];
	
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}

+ (Appirater*)sharedInstance {
	static Appirater *appirater = nil;
	if (appirater == nil)
	{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            appirater = [[Appirater alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:
                UIApplicationWillResignActiveNotification object:nil];
        });
	}
	
	return appirater;
}

- (void)showRatingAlert {
	// Increment dialog count
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger count = [defaults integerForKey:kAppiraterDialogCount] + 1;
	[defaults setInteger:count forKey:kAppiraterDialogCount];
	[defaults synchronize];

	// Hide one of cancel/reminder button if in landscape mode
	NSString *cancelButtonTitle = [self configurationStringForKey:kConfigCancelButton];
	NSString *reminderButtonTitle = [self configurationStringForKey:kConfigRateLater];
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
	if (isLandscape) {
		if (count <= [self configurationIntegerForKey:kConfigLandscapeHideCancelCount])
			cancelButtonTitle = nil;
		else
			reminderButtonTitle = nil;
	}

	if (debug)
		NSLog(@"APPIRATER Show dialog. Count=%d Orientation=%d Landscape=%d", count, orientation, isLandscape);

	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[self configurationStringForKey:kConfigMessageTitle]
														 message:[self configurationStringForKey:kConfigMessage]
														delegate:self
											   cancelButtonTitle:cancelButtonTitle
											   otherButtonTitles:[self configurationStringForKey:kConfigRateButton], reminderButtonTitle, nil] autorelease];
	self.ratingAlert = alertView;
	[alertView show];
}

- (BOOL)ratingConditionsHaveBeenMet {
	if (debug)
		return YES;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSDate *dateOfFirstLaunch = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterFirstUseDate]];
	NSTimeInterval timeSinceFirstLaunch = [[NSDate date] timeIntervalSinceDate:dateOfFirstLaunch];
	NSTimeInterval timeUntilRate = 60 * 60 * 24 * [self configurationIntegerForKey:kConfigDaysUntilPrompt];
	if (timeSinceFirstLaunch < timeUntilRate)
		return NO;
	
	// check if the app has been used enough
	int useCount = [userDefaults integerForKey:kAppiraterUseCount];
	if (useCount <= [self configurationIntegerForKey:kConfigUsesUntilPrompt])
		return NO;
	
	// check if the user has done enough significant events
	int sigEventCount = [userDefaults integerForKey:kAppiraterSignificantEventCount];
	if (sigEventCount <= [self configurationIntegerForKey:kConfigSigEventsUntilPrompt])
		return NO;
	
	// has the user previously declined to rate this version of the app?
	if ([userDefaults boolForKey:kAppiraterDeclinedToRate])
		return NO;
	
	// has the user already rated the app?
	if ([userDefaults boolForKey:kAppiraterRatedCurrentVersion])
		return NO;
	
	// if the user wanted to be reminded later, has enough time passed?
	NSDate *reminderRequestDate = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterReminderRequestDate]];
	NSTimeInterval timeSinceReminderRequest = [[NSDate date] timeIntervalSinceDate:reminderRequestDate];
	NSTimeInterval timeUntilReminder = 60 * 60 * 24 * [self configurationIntegerForKey:kConfigTimeBeforeReminding];
	if (timeSinceReminderRequest < timeUntilReminder)
		return NO;
	
	return YES;
}

- (void)incrementUseCount {
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

	// get the version number that we've been tracking
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *trackingVersion = [userDefaults stringForKey:kAppiraterCurrentVersion];
	if (trackingVersion == nil)
	{
		trackingVersion = version;
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
	}
	
	if (debug)
		NSLog(@"APPIRATER Tracking version: %@", trackingVersion);
	
	if ([trackingVersion isEqualToString:version])
	{
		// check if the first use date has been set. if not, set it.
		NSTimeInterval timeInterval = [userDefaults doubleForKey:kAppiraterFirstUseDate];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kAppiraterFirstUseDate];
		}
		
		// increment the use count
		int useCount = [userDefaults integerForKey:kAppiraterUseCount];
		useCount++;
		[userDefaults setInteger:useCount forKey:kAppiraterUseCount];
		if (debug)
			NSLog(@"APPIRATER Use count: %d", useCount);
	}
	else
	{
		// it's a new version of the app, so restart tracking
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
		[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterFirstUseDate];
		[userDefaults setInteger:1 forKey:kAppiraterUseCount];
		[userDefaults setInteger:0 forKey:kAppiraterSignificantEventCount];
		[userDefaults setBool:NO forKey:kAppiraterRatedCurrentVersion];
		[userDefaults setBool:NO forKey:kAppiraterDeclinedToRate];
		[userDefaults setDouble:0 forKey:kAppiraterReminderRequestDate];
		[userDefaults setInteger:0 forKey:kAppiraterDialogCount];
	}

	[userDefaults synchronize];
}

- (void)incrementSignificantEventCount {
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the version number that we've been tracking
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *trackingVersion = [userDefaults stringForKey:kAppiraterCurrentVersion];
	if (trackingVersion == nil)
	{
		trackingVersion = version;
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
	}
	
	if (debug)
		NSLog(@"APPIRATER Tracking version: %@", trackingVersion);
	
	if ([trackingVersion isEqualToString:version])
	{
		// check if the first use date has been set. if not, set it.
		NSTimeInterval timeInterval = [userDefaults doubleForKey:kAppiraterFirstUseDate];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kAppiraterFirstUseDate];
		}
		
		// increment the significant event count
		int sigEventCount = [userDefaults integerForKey:kAppiraterSignificantEventCount];
		sigEventCount++;
		[userDefaults setInteger:sigEventCount forKey:kAppiraterSignificantEventCount];
		if (debug)
			NSLog(@"APPIRATER Significant event count: %d", sigEventCount);
	}
	else
	{
		// it's a new version of the app, so restart tracking
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
		[userDefaults setDouble:0 forKey:kAppiraterFirstUseDate];
		[userDefaults setInteger:0 forKey:kAppiraterUseCount];
		[userDefaults setInteger:1 forKey:kAppiraterSignificantEventCount];
		[userDefaults setBool:NO forKey:kAppiraterRatedCurrentVersion];
		[userDefaults setBool:NO forKey:kAppiraterDeclinedToRate];
		[userDefaults setDouble:0 forKey:kAppiraterReminderRequestDate];
		[userDefaults setInteger:0 forKey:kAppiraterDialogCount];
	}
	
	[userDefaults synchronize];
}

- (void)incrementAndRate:(BOOL)canPromptForRating {
	[self incrementUseCount];
	
	if (canPromptForRating &&
		[self ratingConditionsHaveBeenMet] &&
		[self connectedToNetwork])
	{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self showRatingAlert];
                       });
	}
}

- (void)incrementSignificantEventAndRate:(BOOL)canPromptForRating {
	[self incrementSignificantEventCount];
	
	if (canPromptForRating &&
		[self ratingConditionsHaveBeenMet] &&
		[self connectedToNetwork])
	{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self showRatingAlert];
                       });
	}
}

+ (void)appLaunched {
	[Appirater appLaunched:YES];
}

+ (void)appLaunched:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [[Appirater sharedInstance] incrementAndRate:canPromptForRating];
                   });
}

- (void)hideRatingAlert {
	if (self.ratingAlert.visible) {
		if (debug)
			NSLog(@"APPIRATER Hiding Alert");
		[self.ratingAlert dismissWithClickedButtonIndex:-1 animated:NO];
	}	
}

+ (void)appWillResignActive {
	if ([[self sharedInstance] isDebug])
		NSLog(@"APPIRATER appWillResignActive");
	[[Appirater sharedInstance] hideRatingAlert];
}

+ (void)appEnteredForeground:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [[Appirater sharedInstance] incrementAndRate:canPromptForRating];
                   });
}

+ (void)userDidSignificantEvent:(BOOL)canPromptForRating {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       [[Appirater sharedInstance] incrementSignificantEventAndRate:canPromptForRating];
                   });
}

+ (void)rateApp {
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"APPIRATER NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.");
#else
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *reviewURL = [NSString stringWithFormat:templateReviewURL, [[self sharedInstance] configurationStringForKey:kConfigAppID]];
	[userDefaults setBool:YES forKey:kAppiraterRatedCurrentVersion];
	[userDefaults synchronize];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	if (buttonIndex == alertView.cancelButtonIndex) {
		// they don't want to rate it
		[userDefaults setBool:YES forKey:kAppiraterDeclinedToRate];
		[userDefaults synchronize];
	}
	else if (buttonIndex == alertView.firstOtherButtonIndex) {
		// they want to rate it
		[Appirater rateApp];
	}
	else if (buttonIndex == alertView.firstOtherButtonIndex + 1) {
		// remind them later
		[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterReminderRequestDate];
		[userDefaults synchronize];
	}
}

@end
