//
//  LanguageHelper.m
//  MovieDict
//
//  Created by Julian Raschke on 21.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "LanguageHelper.h"
#import "Movie.h"
#import "Branding.h"


static NSString *const kOpenInPleco = @"魚";


@interface NSString (MovieDictHacks)

- (NSURL *)URLToOpenInPleco;
- (void)openInPleco:(id)sender;

@end


@implementation LanguageHelper

+ (NSCharacterSet *)chineseCharacters {
    static NSMutableCharacterSet *chineseCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chineseCharacters = [NSMutableCharacterSet new];
        // Taken from Wikipedia. This doesn't have to be super accurate; a few false positives are okay.
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
    NSArray *chineseRegions = @[kMovieRegionChinese, kMovieRegionTaiwan, kMovieRegionHongKong, kMovieRegionChina];
    return [chineseRegions containsObject:region] &&
        [title rangeOfCharacterFromSet:[self chineseCharacters]].length > 0;
}

+ (UIImage *)plecoButtonBackgroundImage
{
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize const size = CGSizeMake(27, 27);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){ CGPointZero, size }];
        UIColor *movieDictColor = [Branding movieDictColor];
        [movieDictColor setFill];
        [path fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIView *)plecoButtonOrNilForTitle:(NSString *)title region:(MovieRegion)region
{
    if (! [self isChineseTitle:title region:region]) {
        return nil;
    }
    
    if (! [[UIApplication sharedApplication] canOpenURL:[title URLToOpenInPleco]]) {
        return nil;
    }
    
    UIImage *backgroundImage = [self plecoButtonBackgroundImage];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    button.frame = (CGRect){ CGPointZero, backgroundImage.size };

    if ([button respondsToSelector:@selector(tintColor)]) {
        button.tintColor = [UIColor whiteColor];
    }
    else {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    [button setTitle:kOpenInPleco forState:UIControlStateNormal];
    [button addTarget:title action:@selector(openInPleco:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (NSString *)romanizationForTitle:(NSString *)title region:(MovieRegion)region
{
    // Do not romanise Hong Kong titles; they're Cantonese
    if (region == kMovieRegionHongKong || ![self isChineseTitle:title region:region]) {
        return nil;
    }
    
    NSMutableString *result = [title.uppercaseString mutableCopy];
    if (CFStringTransform((__bridge CFMutableStringRef)result, NULL, kCFStringTransformMandarinLatin, NO)) {
        return [result copy];
    }
    else {
        return nil;
    }
}

@end


@implementation NSString (MovieDictHacks)

- (NSURL *)URLToOpenInPleco
{
    NSString *escapedSelf = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:[NSString stringWithFormat:@"plecoapi://x-callback-url/s?q=%@&x-source=MovieDict", escapedSelf]];
}

- (void)openInPleco:(id)sender
{
    [[UIApplication sharedApplication] openURL:[self URLToOpenInPleco]];
}

@end
