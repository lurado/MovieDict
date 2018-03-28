//
//  MovieSearchOperation.m
//  MovieDict
//
//  Created by Julian Raschke on 31.05.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "MovieSearchOperation.h"
#import "MovieDatabase.h"


@implementation MovieSearchOperation
{
    NSMutableArray<MovieResults *> *_results;
}

- (void)main
{
    NSUInteger totalResults = 0;
    _results = [NSMutableArray new];
    
    NSArray<MovieRegion> *relevantRegions = (self.region ? @[self.region] : [Movie allRegions]);
    
    for (MovieRegion region in relevantRegions) {
        if (self.cancelled) {
            return;
        }
        
        MovieResults *resultsInRegion = [[MovieDatabase sharedDatabase] searchFor:self.searchText
                                                                         inRegion:region
                                                                            limit:self.regionLimit];
        if (resultsInRegion.movies.count > 0) {
            totalResults += resultsInRegion.movies.count;
            [_results addObject:resultsInRegion];
        }
    }
    
    [self trimResults:totalResults];
}


/// Removes entries from regional results until the number of total results matches the limit
/// configured via .totalLimit.
/// @param totalResults Current total number of results across all regions.
- (void)trimResults:(NSUInteger)totalResults
{
    // This algorithm is highly inefficient, but this doesn't matter since in the worst case it
    // has to trim down our results from .regionLimit to .totalLimit.
    
    while (totalResults > self.totalLimit) {
        MovieResults *resultsWithMostMovies = nil;

        for (MovieResults *results in self.results) {
            if (results.movies.count >= resultsWithMostMovies.movies.count) {
                resultsWithMostMovies = results;
            }
        }
        
        NSRange range = NSMakeRange(0, resultsWithMostMovies.movies.count - 1);
        resultsWithMostMovies.movies = [resultsWithMostMovies.movies subarrayWithRange:range];
        resultsWithMostMovies.haveMore = YES;
        totalResults -= 1;
    }
}

- (NSArray<MovieResults *> *)results
{
    NSAssert(_results != nil, @"finished operation must have at least an empty results array");
    
    return _results;
}

@end
