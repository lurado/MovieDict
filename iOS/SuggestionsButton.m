//
//  SuggestionsButton.m
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "SuggestionsButton.h"
#import "Branding.h"


@implementation SuggestionsButton

+ (instancetype)buttonWithTitle:(NSString *)title fontSize:(CGFloat)size
{
    SuggestionsButton *button = [self buttonWithType:UIButtonTypeCustom];
    
    // Prevent iOS from underlining this button with "Button Shapes" accessibility option turned on
    NSDictionary *attributes = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone) };
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:attributes];
    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont systemFontOfSize:size];
    [button sizeToFit];
    button.userInteractionEnabled = NO;
    [button setTitleColor:[Branding movieDictColor] forState:UIControlStateNormal];
    
    [button setupMotionEffect:size];
    
    return button;
}

/// This methods configured an iOS 7-style motion effect when the phone is rotated in space.
- (void)setupMotionEffect:(CGFloat)size
{
    UIInterpolatingMotionEffect *effectX =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectX.minimumRelativeValue = @(-size +14);
    effectX.maximumRelativeValue = @(+size -14);
    [self addMotionEffect:effectX];
    
    UIInterpolatingMotionEffect *effectY =
    [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                    type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    effectY.minimumRelativeValue = @((-size +14) * 1.4);
    effectY.maximumRelativeValue = @((+size -14) * 1.4);
    [self addMotionEffect:effectY];
}

- (NSString *)searchQuery
{
    // Simply read the title back from the button.
    return [self attributedTitleForState:UIControlStateNormal].string;
}

@end
