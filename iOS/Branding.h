//
//  Branding.h
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// All app-specific colors, fonts etc. should be configured through this class.
@interface Branding : NSObject

/// The main branding color.
+ (UIColor *)movieDictColor;

/// The background color to be used for table headers.
+ (UIColor *)sectionHeaderBackgroundColor;

/// This method must be called once for the main window to configure app-wide branding settings.
+ (void)applyBranding:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
