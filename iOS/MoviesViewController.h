//
//  MoviesViewController.h
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieSource.h"


@interface MoviesViewController : UITableViewController

@property (nonatomic) MovieSource *movieSource;

@end
