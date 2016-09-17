//
//  LanguageHelper.h
//  MovieDict
//
//  Created by Julian Raschke on 21.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"


@interface LanguageHelper : NSObject

+ (BOOL)isChineseTitle:(NSString *)title region:(MovieRegion)region;
+ (NSString *)romanizationForTitle:(NSString *)title region:(MovieRegion)region;

@end
