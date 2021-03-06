//
//  Branding.m
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "Branding.h"


@implementation Branding

+ (UIColor *)movieDictColor
{
    return [UIColor colorWithRed:0xa4/255.0 green:0x11/255.0 blue:0xcc/255.0 alpha:1];
}

+ (UIColor *)sectionHeaderBackgroundColor
{
    return [[self movieDictColor] colorWithAlphaComponent:0.9];
}

+ (void)applyBranding:(UIWindow *)window
{
    window.tintColor = [self movieDictColor];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [self movieDictColor];
    [UINavigationBar appearance].barStyle = UIBarStyleBlackOpaque;
    [UINavigationBar appearance].titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
}

@end
