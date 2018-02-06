//
//  SuggestionsButton.h
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A styled subclass of UIButton that typically across a SuggestionsView.
@interface SuggestionsButton : UIButton

+ (instancetype)buttonWithTitle:(NSString *)title fontSize:(CGFloat)size;

/// Returns the string that the app should search for when this button is tapped.
@property (nonatomic, readonly) NSString *searchQuery;

@end

NS_ASSUME_NONNULL_END
