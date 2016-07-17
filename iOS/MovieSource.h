//
//  MovieSource.h
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"


@protocol MovieSourceDelegate;


@interface MovieSource : NSObject <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) id<MovieSourceDelegate> delegate;

@property (nonatomic, readonly) MovieRegion region;

- (instancetype)movieSourceForSingleRegion:(MovieRegion)region;

@end


@protocol MovieSourceDelegate <NSObject>

@required
- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults;
- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie;

@optional
- (void)movieSource:(MovieSource *)movieSource didSelectRegion:(MovieRegion)region;

@end
