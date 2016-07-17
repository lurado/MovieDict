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
    
    if ([button respondsToSelector:@selector(setAttributedTitle:forState:)]) {
        // Prevent iOS from underlining this button with "Button Shapes" accessibility option turned on
        NSDictionary *attributes = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone) };
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:attributes];
        [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }
    else {
        [button setTitle:title forState:UIControlStateNormal];
    }
    
    button.titleLabel.font = [UIFont systemFontOfSize:size];
    [button sizeToFit];
    button.userInteractionEnabled = NO;
    [button setTitleColor:[Branding movieDictColor] forState:UIControlStateNormal];
    
    if ([button respondsToSelector:@selector(addMotionEffect:)]) {
        UIInterpolatingMotionEffect *effectX =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.minimumRelativeValue = @(-size +14);
        effectX.maximumRelativeValue = @(+size -14);
        [button addMotionEffect:effectX];
        
        UIInterpolatingMotionEffect *effectY =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.minimumRelativeValue = @((-size +14) * 1.4);
        effectY.maximumRelativeValue = @((+size -14) * 1.4);
        [button addMotionEffect:effectY];
    }
    
    return button;
}

- (NSString *)searchQuery
{
    return [self titleForState:UIControlStateNormal] ?:
        [self attributedTitleForState:UIControlStateNormal].string;
}

@end
