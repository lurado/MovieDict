//
//  TranslationCell.h
//  MovieDict
//
//  Created by Julian Raschke on 17.09.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// A table cell that contains the translation for a movie, as shown on the MovieViewController.
@interface TranslationCell : UITableViewCell

- (void)setupWithRegion:(MovieRegion)region title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
