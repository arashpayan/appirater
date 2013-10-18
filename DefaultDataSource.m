//
//  DefaultDataSource.m
//
//  Created by Bram Huenaerts on 17/10/13.
//  Copyright (c) 2013 chronux. All rights reserved.
//

#import "DefaultDataSource.h"
#import "Appirater.h"

@implementation DefaultDataSource

-(NSString *)appName {
    return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
}

-(NSString *)message {
    NSString *localizedMessage = NSLocalizedStringFromTableInBundle(@"If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", @"AppiraterLocalizable", [Appirater bundle], nil);
    
    return [NSString stringWithFormat:localizedMessage, self.appName];
}

-(NSString *)messageTitle {
    NSString *localizedMessage = NSLocalizedStringFromTableInBundle(@"Rate %@", @"AppiraterLocalizable", [Appirater bundle], nil);
    
    return [NSString stringWithFormat:localizedMessage, self.appName];
}

-(NSString *)cancelButtonTitle {
    return NSLocalizedStringFromTableInBundle(@"No, Thanks", @"AppiraterLocalizable", [Appirater bundle], nil);
}

-(NSString *)rateNowButtonTitle {
    NSString *localizedMessage = NSLocalizedStringFromTableInBundle(@"Rate %@", @"AppiraterLocalizable", [Appirater bundle], nil);
    
    return [NSString stringWithFormat:localizedMessage, self.appName];
}

-(NSString *)rateLaterButtonTitle {
    return NSLocalizedStringFromTableInBundle(@"Remind me later", @"AppiraterLocalizable", [Appirater bundle], nil);
}

@end
