//
//  LanguageHelper.m
//  MovieDict
//
//  Created by Julian Raschke on 21.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "LanguageHelper.h"
#import "Movie.h"


@implementation LanguageHelper

/// Returns an NSCharacterSet that contains all Chinese characters found in Unicode.
+ (nonnull NSCharacterSet *)chineseCharacters
{
    static NSMutableCharacterSet *chineseCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chineseCharacters = [NSMutableCharacterSet new];
        // Taken from Wikipedia. This doesn't have to be 100% accurate, false positives are okay.
        // Parts of plane 0 / BMP:
        // CJK Radicals Supplement (2E80–2EFF)
        // Kangxi Radicals (2F00–2FDF)
        // Ideographic Description Characters (2FF0–2FFF)
        // CJK Symbols and Punctuation (3000–303F)
        [chineseCharacters addCharactersInRange:NSMakeRange(0x2e80, 0x303f)];
        // CJK Strokes (31C0–31EF)
        // CJK Compatibility (3300–33FF)
        // CJK Unified Ideographs Extension A (3400–4DBF)
        // CJK Unified Ideographs (4E00–9FFF)
        [chineseCharacters addCharactersInRange:NSMakeRange(0x31c0, 0x9fff)];
        //  CJK Compatibility Ideographs (F900–FAFF)
        [chineseCharacters addCharactersInRange:NSMakeRange(0xf900, 0xfaff)];
        // The whole plane 2 is reserved for CJK ideographs:
        // CJK Unified Ideographs Extension B (20000–2A6DF)
        // CJK Unified Ideographs Extension C (2A700–2B73F)
        // CJK Unified Ideographs Extension D (2B740–2B81F)
        // CJK Compatibility Ideographs Supplement (2F800–2FA1F); not Unified
        // ...
        [chineseCharacters addCharactersInRange:NSMakeRange(0x20000, 0x2ffff)];
    });
    return chineseCharacters;
}

+ (BOOL)isChineseTitle:(NSString *)title region:(MovieRegion)region
{
    // Do not consider e.g. Japanese Kanji titles "Chinese" because looking them up inside Pleco
    // doesn't make sense.
    NSArray *chineseRegions =
        @[kMovieRegionChinese, kMovieRegionTaiwan, kMovieRegionHongKong, kMovieRegionChina];

    return [chineseRegions containsObject:region] &&
        [title rangeOfCharacterFromSet:[self chineseCharacters]].length > 0;
}

+ (nullable NSString *)romanizationForTitle:(NSString *)title region:(MovieRegion)region
{    
    // Do not romanise Hong Kong titles, they're Cantonese.
    if (region == kMovieRegionHongKong || ! [self isChineseTitle:title region:region]) {
        return nil;
    }
    
    NSMutableString *result = [title.uppercaseString mutableCopy];
    
    // Ensure that the former character is romanized in the same way as the latter (ni3, not nai3).
    [result replaceOccurrencesOfString:@"妳"
                            withString:@"你"
                               options:0
                                 range:NSMakeRange(0, result.length)];
    // 曲 is usually pronounced qu3, not qu1, in movie titles.
    [result replaceOccurrencesOfString:@"曲"
                            withString:@"取"
                               options:0
                                 range:NSMakeRange(0, result.length)];

    if (CFStringTransform((__bridge CFMutableStringRef)result, NULL,
                          kCFStringTransformMandarinLatin, NO)) {
        return [result copy];
    } else {
        return nil;
    }
}

@end
