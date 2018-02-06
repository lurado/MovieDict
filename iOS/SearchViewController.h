//
//  SearchViewController.h
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// This is the app's main (but not root) view controller.
/// It shows a UISearchBar at the top and below it, either a SuggestionsView or a table with search
/// results.
@interface SearchViewController : UIViewController

/// Helper property to keep the bottom inset consistent in split-screen use.
@property (nonatomic) CGFloat currentKeyboardHeight;

@end

NS_ASSUME_NONNULL_END
