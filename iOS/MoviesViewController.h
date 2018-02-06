//
//  MoviesViewController.h
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSource.h"

NS_ASSUME_NONNULL_BEGIN

/// This view controller shows search results from a MovieSource, but does not offer any UI to
/// change the search text.
/// It is used when drilling down into the search results for a single region.
@interface MoviesViewController : UITableViewController <MovieSourceDelegate>

/// The source of movies (search results) to show in this controller.
/// @warning This property must be set before showing this controller, and not modified afterwards.
@property (nullable, nonatomic) MovieSource *movieSource;

/// Helper property to keep the bottom inset consistent in split-screen use.
@property (nonatomic) CGFloat currentKeyboardHeight;

@end

NS_ASSUME_NONNULL_END
