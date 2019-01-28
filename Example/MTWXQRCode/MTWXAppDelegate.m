//
//  VKWXAppDelegate.m
//  VKWXTimePicker
//
//  Created by MTTGCC on 12/03/2018.
//  Copyright (c) 2018 MTTGCC. All rights reserved.
//

#import "MTWXAppDelegate.h"
#import <WeexSDK/WeexSDK.h>
#import "MTDemoViewController.h"
#import "MTWXQRCode.h"


@interface MTWXAppDelegate ()

@end


@implementation MTWXAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始化weexSDK
    [self initWeexSDK];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
   
    
    //获取js路径
    NSURL * sourceUrl = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"js"];
    //生成weex页面容器
    MTDemoViewController *wxDemoVC = [[MTDemoViewController alloc] initWithSourceURL:sourceUrl];
    //设置窗口根视图
    self.window.rootViewController = [[WXRootViewController alloc] initWithRootViewController:wxDemoVC];
    
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 初始化weexSDK
 */
- (void)initWeexSDK {
    
    //设置APP信息
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setAppVersion:@"1.8.3"];
    
    //初始weex环境
    [WXSDKEngine initSDKEnvironment];
    //注册图片加载协议
    [WXSDKEngine registerHandler:[VKWXQRCode new] withProtocol:@protocol(WXImgLoaderProtocol)];
    //注册组件
    [WXSDKEngine registerModule:@"wxQRCode" withClass:[VKWXQRCode class]];
    
    //打印设置
    [WXLog setLogLevel:WXLogLevelLog];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
