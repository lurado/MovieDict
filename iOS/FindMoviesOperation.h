//
//  FindMoviesOperation.h
//  MovieDict
//
//  Created by Julian Raschke on 31.05.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieResults.h"
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// This operation wraps the synchronous database search found in the Movie class.
@interface FindMoviesOperation : NSOperation

/// The maximum number of results per region.
@property (nonatomic) NSInteger regionLimit;
/// The maximum number of results in total.
@property (nonatomic) NSInteger totalLimit;

/// The region that movies will be searched in, or nil for all regions.
@property (nullable, nonatomic) MovieRegion region;

/// The string to search for.
@property (nullable, nonatomic, copy) NSString *query;

/// After the operation has finished, this array will entries for each MovieRegion for which results
/// could be found.
@property (nonnull, nonatomic, readonly) NSArray<MovieResults *> *results;

@end

NS_ASSUME_NONNULL_END
