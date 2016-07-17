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


@protocol FindMoviesOperationDelegate;


@interface FindMoviesOperation : NSOperation

@property (nonatomic, weak) id<FindMoviesOperationDelegate> delegate;

@property (nonatomic) NSInteger regionLimit;
@property (nonatomic) NSInteger totalLimit;

@property (nonatomic, copy) MovieRegion region;
@property (nonatomic, copy) NSString *query;

@property (nonatomic, readonly) NSArray<MovieResults *> *results;

@end


@protocol FindMoviesOperationDelegate

@required
- (void)findMoviesOperationDidFinish:(FindMoviesOperation *)operation;

@end
