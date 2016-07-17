//
//  AppDelegate.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "Branding.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SearchViewController *viewController = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [Branding applyBranding:self.window];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
