//
//  SuggestionsButton.h
//  MovieDict
//
//  Created by Julian Raschke on 10.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SuggestionsButton : UIButton

+ (instancetype)buttonWithTitle:(NSString *)title fontSize:(CGFloat)size;

- (NSString *)searchQuery;

@end
