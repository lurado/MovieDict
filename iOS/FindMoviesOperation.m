//
//  FindMoviesOperation.m
//  MovieDict
//
//  Created by Julian Raschke on 31.05.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "FindMoviesOperation.h"
#import "Movie.h"


@implementation FindMoviesOperation

- (void)main
{
    NSMutableArray<MovieResults *> *results = [NSMutableArray new];
    NSUInteger totalResults = 0;
    
    for (NSString *region in [Movie allRegions]) {
        if (self.cancelled) {
            return;
        }
        
        if (self.region && region != self.region) {
            [results addObject:[MovieResults new]];
        }
        else {
            MovieResults *resultsForRegion = [Movie moviesMatchingString:self.query inRegion:region limit:self.regionLimit];
            totalResults += resultsForRegion.movies.count;
            [results addObject:resultsForRegion];
        }
    }
    
    if (totalResults > 0) {
        _results = [results copy];
        [self trimResults:totalResults];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (! self.cancelled) {
            [self.delegate findMoviesOperationDidFinish:self];
        }
    });
}

- (void)trimResults:(NSUInteger)totalResults
{
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

@end
