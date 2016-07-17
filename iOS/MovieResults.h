//
//  MovieResults.h
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Movie;


@interface MovieResults : NSObject

@property (nonatomic, copy) NSArray<Movie *> *movies;
@property (nonatomic) BOOL haveMore;

@end
