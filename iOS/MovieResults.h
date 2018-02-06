//
//  MovieResults.h
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// A simple struct-like data class that groups search results for a single region together.
@interface MovieResults : NSObject

/// The region for which this object contains search results.
@property (nonatomic, copy) MovieRegion region;
/// The movies found in this region.
@property (nonatomic, copy) NSArray<Movie *> *movies;
/// Indicates that there are more search results in this region, and that the movies array had to
/// be truncated to not exceed the search result limit.
@property (nonatomic) BOOL haveMore;

- (instancetype)initWithRegion:(MovieRegion)region
                        movies:(NSArray<Movie *> *)movies
                      haveMore:(BOOL)haveMore NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
