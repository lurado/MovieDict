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

- (void)setupWithRegion:(NSString *)region title:(NSString *)title
{
    self.regionLabel.textColor = [Branding movieDictColor];
    
    // Skip everything after "International"
    self.regionLabel.text = [[[Movie nameOfRegion:region] componentsSeparatedByString:@"/"] firstObject];
    
    NSString *romanization = [LanguageHelper romanizationForTitle:title region:region];
    self.titleLabel.text = romanization.length ? [@[title, romanization] componentsJoinedByString:@"\n"] : title;

    NSString *escapedTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.plecoURL = [NSURL URLWithString:[NSString stringWithFormat:@"plecoapi://x-callback-url/s?q=%@&x-source=MovieDict", escapedTitle]];
    
    if ([LanguageHelper isChineseTitle:title region:region] && [[UIApplication sharedApplication] canOpenURL:self.plecoURL]) {
        self.plecoButton.backgroundColor = [UIColor clearColor];
        [self.plecoButton setBackgroundImage:[self.class plecoButtonBackground] forState:UIControlStateNormal];
        self.plecoButton.hidden = NO;
    }
    else {
        self.plecoButton.hidden = YES;
    }
}

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
