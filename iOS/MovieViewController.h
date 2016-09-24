//
//  MovieViewController.h
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Movie;


@interface MovieViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic) Movie *movie;
@property (nonatomic) CGFloat currentKeyboardHeight;

@end
