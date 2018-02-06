//
//  MovieSource.h
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MovieSourceDelegate;


/// The MovieSource objects is a UITableView data source and delegate that asynchronously responds
/// to a changing search text (see setSearchText:), and lets its delegate know when the search
/// results have changed.
@interface MovieSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nullable, nonatomic, weak) IBOutlet id<MovieSourceDelegate> delegate;

/// If this property is nil, this instance will search in all regions.
/// If it is not nil, then only movies from this region will be shown.
/// This property cannot be written to.
/// Instead, create a MovieSource for all regions using alloc/init, and then "split off" a
/// MovieSource for a single region using movieSourceForSingleRegion:.
@property (nullable, nonatomic, readonly) MovieRegion region;

/// While init will create a MovieSource that searches in all regions, this method will "split off"
/// a MovieSource for a single region.
/// The returned instance will automatically inherited the last searchText of this instance. There
/// is no need to call setSearchText: on it again.
- (instancetype)movieSourceForSingleRegion:(MovieRegion)region;

/// Updates the current search text, causing this MovieSource to stop its current search
/// operation (if any).
/// If the new searchText is not nil or empty, a new asynchronous search will begin.
- (void)setSearchText:(nullable NSString *)searchText;

@end


@protocol MovieSourceDelegate <NSObject>

@required
/// The delegate is expected to call –[UITableView reloadData] when it receives this message.
/// However, it can also display an empty state view if there are no results.
- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults;

/// Called when the user taps on a cell that corresponds to the given movie.
- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie;

@optional
/// In a MovieSource that searches for all regions, there will be cells that allow the user to
/// drill down into a specific region if there are too many search results.
/// In this case, this message will be sent. It is declared \@optional because it will only be
/// called by a MovieSource that searches in all regions (.region == nil).
- (void)movieSource:(MovieSource *)movieSource didSelectRegion:(MovieRegion)region;

@end

NS_ASSUME_NONNULL_END
