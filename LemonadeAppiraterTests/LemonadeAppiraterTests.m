//
//  LemonadeAppiraterTests.m
//  LemonadeAppiraterTests
//
//  Created by Bassem Youssef on 7/6/17.
//  Copyright © 2017 Lemonade.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <LemonadeAppirater/Appirater.h>
@interface LemonadeAppiraterTests : XCTestCase

@end

@implementation LemonadeAppiraterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    [Appirater setAppId:@"770699556"];
    //TODO: create extensions to get app id and verify that it is set correctly.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
