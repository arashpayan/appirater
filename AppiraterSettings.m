//
//  AppiraterSettings.m
//  OP22
//
//  Created by Yann-Cyril PELUD on 17/07/12.
//  Copyright (c) 2012 Yann-Cyril PELUD. All rights reserved.
//

#import "AppiraterSettings.h"
#import "Appirater.h"

@interface AppiraterSettings()

@property (nonatomic, strong) NSDictionary *settings;


@end

@implementation AppiraterSettings

@synthesize appId = __appId;
@synthesize daysUntilPrompt = __daysUntilPrompt;
@synthesize timeBeforeReminding = __timeBeforeReminding;
@synthesize usesUntilPrompt = __usesUntilPrompt;
@synthesize sigEventsUntilPrompt = __sigEventsUntilPrompt;
@synthesize urlStore = __urlStore;

@synthesize settings;

- (id) init {
    self = [super init];
    
    NSBundle* bundle = [NSBundle mainBundle];
        
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSString* plistPath = [bundle pathForResource:@"Appirater" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    self.settings = (NSDictionary *)[NSPropertyListSerialization
                              propertyListFromData:plistXML
                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                              format:&format
                              errorDescription:&errorDesc];
    if (!settings) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    return self;
}

- (NSInteger) objectForKey:(NSString *)key withDefault:(NSInteger)defaut {
    NSInteger retValue = defaut;
    if (settings != nil) {
        NSNumber *number = [settings objectForKey:key];
        if (number!=nil)
            retValue = [number intValue];
    }
    return retValue;

}


- (NSInteger) appId{
    return [self objectForKey:@"AppId" withDefault: APPIRATER_APP_ID];
}

- (NSInteger) daysUntilPrompt{
    return [self objectForKey:@"DaysUntilPrompt" withDefault: APPIRATER_DAYS_UNTIL_PROMPT];
}

- (NSInteger) usesUntilPrompt{
    return [self objectForKey:@"UsesUntilPrompt" withDefault: APPIRATER_USES_UNTIL_PROMPT];
}

- (NSInteger) sigEventsUntilPrompt{
    return [self objectForKey:@"SigEventsUntilPrompt" withDefault: APPIRATER_SIG_EVENTS_UNTIL_PROMPT];
}

- (NSInteger) timeBeforeReminding{
    return [self objectForKey:@"TimeBeforeReminding" withDefault: APPIRATER_TIME_BEFORE_REMINDING];
}

- (NSString *) urlStore {
    NSArray *array = [NSArray arrayWithObjects: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID", @"http://itunes.apple.com/us/app/idAPP_ID?mt=8", nil];

    NSInteger idx = [self objectForKey:@"UrlStore" withDefault: 1];
    if (idx<0 || idx >= array.count)
        idx = 0;
    
    return [array objectAtIndex:idx];
}


@end
