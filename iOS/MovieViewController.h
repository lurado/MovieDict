//
//  MovieViewController.h
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// This view controller displays information about a single movie, i.e. all translations for its
/// title and relevant links.
@interface MovieViewController : UIViewController <UISplitViewControllerDelegate>

/// The movie to present.
/// @warning This property must be set before showing this controller, and not modified afterwards.
@property (nullable, nonatomic) Movie *movie;

/// Helper property to keep the bottom inset consistent in split-screen use.
@property (nonatomic) CGFloat currentKeyboardHeight;

@end

NS_ASSUME_NONNULL_END
