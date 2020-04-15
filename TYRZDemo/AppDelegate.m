//
//  AppDelegate.m
//  TYRZDemo
//
//  Created by 承启通 on 2020/4/13.
//  Copyright © 2020 承启通. All rights reserved.
//

#import "AppDelegate.h"
#import <TYRZSDK/TYRZSDK.h>

#define appId @"APPID"
#define appKey @"APPKEY"


@interface AppDelegate ()

@end

@implementation AppDelegate
//如果想支持iOS 13一下的手机请取消注释
//@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UASDKLogin.shareLogin registerAppId:appId AppKey:appKey];
    [UASDKLogin.shareLogin printConsoleEnable:YES];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
