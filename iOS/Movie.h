//
//  Movie.h
//  MovieDict
//
//  Created by Julian Raschke on 18.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieResults.h"


typedef id MovieRegion;
extern MovieRegion const kMovieRegionEnglish;
extern MovieRegion const kMovieRegionChinese;
extern MovieRegion const kMovieRegionTaiwan;
extern MovieRegion const kMovieRegionHongKong;
extern MovieRegion const kMovieRegionChina;
extern MovieRegion const kMovieRegionGerman;
extern MovieRegion const kMovieRegionJapanese;
extern MovieRegion const kMovieRegionRussia;
extern MovieRegion const kMovieRegionFrance;


@interface Movie : NSObject

@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSDictionary<MovieRegion, NSString *> *titles;
@property (nonatomic, readonly) NSURL *wikipediaURL;
@property (nonatomic, readonly) NSURL *imdbURL;

+ (NSArray<MovieRegion> *)allRegions;
+ (NSString *)nameOfRegion:(MovieRegion)region;
+ (MovieResults *)moviesMatchingString:(NSString *)string inRegion:(MovieRegion)region limit:(NSInteger)limit;
+ (Movie *)randomSuggestion;

@end
