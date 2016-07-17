//
//  Branding.h
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Branding : NSObject

+ (UIColor *)movieDictColor;
+ (UIColor *)sectionHeaderColor;

+ (void)applyBranding:(UIWindow *)window;

@end
