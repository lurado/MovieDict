//
//  TranslationCell.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "TranslationCell.h"
#import "Branding.h"
#import "LanguageHelper.h"


@interface TranslationCell ()

@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *plecoButton;
@property (nonatomic, copy) NSURL *plecoURL;

@end


@implementation TranslationCell

- (void)setupWithRegion:(MovieRegion)region title:(NSString *)title
{
    self.regionLabel.textColor = [Branding movieDictColor];
    
    // Use the short name to make the caption fit on narrow iPhones.
    self.regionLabel.text = [Movie shortNameOfRegion:region];
    
    NSString *romanization = [LanguageHelper romanizationForTitle:title region:region];
    self.titleLabel.text = romanization
                         ? [@[title, romanization] componentsJoinedByString:@"\n"]
                         : title;

    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *escapedTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    NSString *URLFormat = @"plecoapi://x-callback-url/s?q=%@&x-source=MovieDict";
    self.plecoURL = [NSURL URLWithString:[NSString stringWithFormat:URLFormat, escapedTitle]];
    
    if ([LanguageHelper isChineseTitle:title region:region]
            && [[UIApplication sharedApplication] canOpenURL:self.plecoURL]) {
        self.plecoButton.backgroundColor = [UIColor clearColor];
        [self.plecoButton setBackgroundImage:[self.class plecoButtonBackground]
                                    forState:UIControlStateNormal];
        self.plecoButton.hidden = NO;
    } else {
        self.plecoButton.hidden = YES;
    }
}

/// A local helper that returns an UIImage background for a round button.
+ (UIImage *)plecoButtonBackground
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

- (IBAction)openInPleco:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.plecoURL];
}

@end
