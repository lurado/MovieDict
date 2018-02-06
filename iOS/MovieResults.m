//
//  MovieResults.m
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "MovieResults.h"


@implementation MovieResults

- (instancetype)initWithRegion:(MovieRegion)region
                        movies:(NSArray<Movie *> *)movies
                      haveMore:(BOOL)haveMore
{
    if (self = [super init]) {
        _region = region;
        _movies = [movies copy];
        _haveMore = haveMore;
    }
    return self;
}

@end
