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

@end


@implementation TranslationCell

- (void)setupWithRegion:(NSString *)region title:(NSString *)title
{
    self.regionLabel.textColor = [Branding movieDictColor];
    
    // Skip everything after "International"
    self.regionLabel.text = [[[Movie nameOfRegion:region] componentsSeparatedByString:@"/"] firstObject];
    
    NSString *romanization = [LanguageHelper romanizationForTitle:title region:region];
    self.titleLabel.text = romanization.length ? [@[title, romanization] componentsJoinedByString:@"\n"] : title;

    // TODO: Bring back Pleco buttons.
    // UIView *plecoButton = [LanguageHelper plecoButtonOrNilForTitle:title region:region];
    // static CGFloat const kPlecoButtonOffset = 2;
}

@end
