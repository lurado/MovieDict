//
//  LanguageHelper.h
//  MovieDict
//
//  Created by Julian Raschke on 21.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// A static helper class that provides language-specific utility methods.
@interface LanguageHelper : NSObject

/// Returns YES if this title, found in this region, seems to be written in Chinese characters.
/// (In this case, the app will offer to look up this string in Pleco.)
+ (BOOL)isChineseTitle:(NSString *)title region:(MovieRegion)region;

/// Returns the romanized version of a title, found in this region, or nil.
+ (nullable NSString *)romanizationForTitle:(NSString *)title region:(MovieRegion)region;

@end

NS_ASSUME_NONNULL_END
