//
//  AppDelegate.m
//  OrganizeBaiDuPan
//
//  Created by ixdtech on 14/11/6.
//  Copyright (c) 2014年 Ice. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController=[[ViewController alloc]init];
    [self.window makeKeyAndVisible];
    [self testCopy];
    return YES;
}

-(void)testCopy{
    NSArray *o1=[NSArray arrayWithObject:@"1"];
    NSArray *o2=[NSArray copy];
    NSMutableArray *o3=[NSArray mutableCopy];
    NSMutableArray *o4=[NSMutableArray arrayWithObject:@"2"];
    NSArray *o5=[o4 copy];
    NSMutableArray *o6=[o4 mutableCopy];
    NSLog(@"\nNSArrayo1:%p\nNSArrayo2:%p\nNSMutableArrayo3:%p\nNSMutableArrayo4:%pNSArrayo5:%p\nNSMutableArrayo6:%p",o1,o2,o3,o4,o5,o6);
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
