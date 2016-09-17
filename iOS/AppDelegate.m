//
//  AppDelegate.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "AppDelegate.h"
#import "Branding.h"
#import "MovieViewController.h"


@interface AppDelegate () <UISplitViewControllerDelegate>

@end


@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Branding applyBranding:self.window];

    UISplitViewController *splitViewController = (id)self.window.rootViewController;
    splitViewController.delegate = self;
    splitViewController.maximumPrimaryColumnWidth = 400;
    splitViewController.preferredPrimaryColumnWidthFraction = 0.5;
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    return YES;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    NSParameterAssert([secondaryViewController isKindOfClass:[UINavigationController class]]);
    
    UINavigationController *navigationController = (id)secondaryViewController;
    if ([navigationController.topViewController isKindOfClass:[MovieViewController class]]) {
        // If the MovieViewController does not show a movie, then do discard it while collapsing.
        return ((MovieViewController *)navigationController.topViewController).movie == nil;
    }
    
    return NO;
}

@end
