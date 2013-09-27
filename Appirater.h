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
 * Appirater.h
 * appirater
 *
 * Created by Arash Payan on 9/5/09.
 * http://arashpayan.com
 * Copyright 2012 Arash Payan. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AppiraterDelegate.h"
#import <StoreKit/StoreKit.h>

extern NSString *const kAppiraterFirstUseDate;
extern NSString *const kAppiraterUseCount;
extern NSString *const kAppiraterSignificantEventCount;
extern NSString *const kAppiraterCurrentVersion;
extern NSString *const kAppiraterRatedCurrentVersion;
extern NSString *const kAppiraterDeclinedToRate;
extern NSString *const kAppiraterReminderRequestDate;

/*
 Your localized app's name.
 */
#define APPIRATER_LOCALIZED_APP_NAME    [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]

/*
 Your app's name.
 */
#define APPIRATER_APP_NAME				APPIRATER_LOCALIZED_APP_NAME ? APPIRATER_LOCALIZED_APP_NAME : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

/*
 This is the message your users will see once they've passed the day+launches
 threshold.
 */
#define APPIRATER_LOCALIZED_MESSAGE     NSLocalizedStringFromTableInBundle(@"If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", @"AppiraterLocalizable", [Appirater bundle], nil)
#define APPIRATER_MESSAGE				[NSString stringWithFormat:APPIRATER_LOCALIZED_MESSAGE, APPIRATER_APP_NAME]

/*
 This is the title of the message alert that users will see.
 */
#define APPIRATER_LOCALIZED_MESSAGE_TITLE   NSLocalizedStringFromTableInBundle(@"Rate %@", @"AppiraterLocalizable", [Appirater bundle], nil)
#define APPIRATER_MESSAGE_TITLE             [NSString stringWithFormat:APPIRATER_LOCALIZED_MESSAGE_TITLE, APPIRATER_APP_NAME]

/*
 The text of the button that rejects reviewing the app.
 */
#define APPIRATER_CANCEL_BUTTON			NSLocalizedStringFromTableInBundle(@"No, Thanks", @"AppiraterLocalizable", [Appirater bundle], nil)

/*
 Text of button that will send user to app review page.
 */
#define APPIRATER_LOCALIZED_RATE_BUTTON NSLocalizedStringFromTableInBundle(@"Rate %@", @"AppiraterLocalizable", [Appirater bundle], nil)
#define APPIRATER_RATE_BUTTON			[NSString stringWithFormat:APPIRATER_LOCALIZED_RATE_BUTTON, APPIRATER_APP_NAME]

/*
 Text for button to remind the user to review later.
 */
#define APPIRATER_RATE_LATER			NSLocalizedStringFromTableInBundle(@"Remind me later", @"AppiraterLocalizable", [Appirater bundle], nil)

@interface Appirater : NSObject <UIAlertViewDelegate, SKStoreProductViewControllerDelegate> {

	UIAlertView		*ratingAlert;
}

@property(nonatomic, strong) UIAlertView *ratingAlert;
@property(nonatomic) BOOL openInAppStore;
#if __has_feature(objc_arc_weak)
@property(nonatomic, weak) NSObject <AppiraterDelegate> *delegate;
#else
@property(nonatomic, unsafe_unretained) NSObject <AppiraterDelegate> *delegate;
#endif

/*
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
+ (void)appLaunched:(BOOL)canPromptForRating;

/*
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
+ (void)appEnteredForeground:(BOOL)canPromptForRating;

/*
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
+ (void)userDidSignificantEvent:(BOOL)canPromptForRating;

/*
 Tells Appirater to show the prompt (a rating alert). The prompt will be showed
 if there is connection available, the user hasn't declined to rate
 or hasn't rated current version.
 
 You could call to show the prompt regardless Appirater settings,
 e.g., in case of some special event in your app.
 */
+ (void)showPrompt;

/*
 Tells Appirater to open the App Store page where the user can specify a
 rating for the app. Also records the fact that this has happened, so the
 user won't be prompted again to rate the app.

 The only case where you should call this directly is if your app has an
 explicit "Rate this app" command somewhere.  In all other cases, don't worry
 about calling this -- instead, just call the other functions listed above,
 and let Appirater handle the bookkeeping of deciding when to ask the user
 whether to rate the app.
 */
+ (void)rateApp;

/*
 Tells Appirater to immediately close any open rating modals (e.g. StoreKit rating VCs).
*/
+ (void)closeModal;

@end

@interface Appirater(Configuration)

/*
 Set your Apple generated software id here.
 */
+ (void) setAppId:(NSString*)appId;

/*
 Users will need to have the same version of your app installed for this many
 days before they will be prompted to rate it.
 */
+ (void) setDaysUntilPrompt:(double)value;

/*
 An example of a 'use' would be if the user launched the app. Bringing the app
 into the foreground (on devices that support it) would also be considered
 a 'use'. You tell Appirater about these events using the two methods:
 [Appirater appLaunched:]
 [Appirater appEnteredForeground:]
 
 Users need to 'use' the same version of the app this many times before
 before they will be prompted to rate it.
 */
+ (void) setUsesUntilPrompt:(NSInteger)value;

/*
 A significant event can be anything you want to be in your app. In a
 telephone app, a significant event might be placing or receiving a call.
 In a game, it might be beating a level or a boss. This is just another
 layer of filtering that can be used to make sure that only the most
 loyal of your users are being prompted to rate you on the app store.
 If you leave this at a value of -1, then this won't be a criterion
 used for rating. To tell Appirater that the user has performed
 a significant event, call the method:
 [Appirater userDidSignificantEvent:];
 */
+ (void) setSignificantEventsUntilPrompt:(NSInteger)value;


/*
 Once the rating alert is presented to the user, they might select
 'Remind me later'. This value specifies how long (in days) Appirater
 will wait before reminding them.
 */
+ (void) setTimeBeforeReminding:(double)value;

/*
 'YES' will show the Appirater alert everytime. Useful for testing how your message
 looks and making sure the link to your app's review page works.
 */
+ (void) setDebug:(BOOL)debug;

/*
 Set the delegate if you want to know when Appirater does something
 */
+ (void)setDelegate:(id<AppiraterDelegate>)delegate;

/*
 Set whether or not Appirater uses animation (currently respected when pushing modal StoreKit rating VCs).
 */
+ (void)setUsesAnimation:(BOOL)animation;

/*
 If set to YES, Appirater will open App Store link (instead of SKStoreProductViewController on iOS 6). Default NO.
 */
+ (void)setOpenInAppStore:(BOOL)openInAppStore;

/*
 If set to YES, the main bundle will always be used to load localized strings.
 Set this to YES if you have provided your own custom localizations in AppiraterLocalizable.strings
 in your main bundle.  Default is NO.
 */
+ (void)setAlwaysUseMainBundle:(BOOL)useMainBundle;

@end


/*
 Methods in this interface are public out of necessity, but may change without notice
 */
@interface Appirater(Unsafe)

/*
 The bundle localized strings will be loaded from.
*/
+(NSBundle *)bundle;

@end

@interface Appirater(Deprecated)

/*
 DEPRECATED: While still functional, it's better to use
 appLaunched:(BOOL)canPromptForRating instead.
 
 Calls [Appirater appLaunched:YES]. See appLaunched: for details of functionality.
 */
+ (void)appLaunched __attribute__((deprecated)); 

@end
