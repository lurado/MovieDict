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

+ (UIColor *)sectionHeaderColor
{
    return [[self movieDictColor] colorWithAlphaComponent:0.9];
}

+ (void)applyBranding:(UIWindow *)window
{
    if ([window respondsToSelector:@selector(setTintColor:)]) {
        window.tintColor = [self movieDictColor];
        
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [UINavigationBar appearance].barTintColor = [self movieDictColor];
        [UINavigationBar appearance].titleTextAttributes = @{ UITextAttributeTextColor: [UIColor whiteColor] };
        [UINavigationBar appearance].barStyle = UIBarStyleBlackOpaque;
    }
    else {
        [UINavigationBar appearance].titleTextAttributes = @{ UITextAttributeTextColor: [UIColor whiteColor] };
        [UINavigationBar appearance].tintColor = [self movieDictColor];
    }
}

@end
