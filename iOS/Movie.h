//
//  Movie.h
//  MovieDict
//
//  Created by Julian Raschke on 18.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MovieResults;


/// This is an opaque type that identifies a cultural region in which a movie can have a distinct
/// title.
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


/// A simple struct-like data class that represents information about one movie in our database.
@interface Movie : NSObject

/// A dictionary containing the movie's title in each region.
/// This dictionary must have at least one entry.
@property (nonatomic, readonly) NSDictionary<MovieRegion, NSString *> *titles;
/// The year in which the movie debuted, or 0 if unknown.
@property (nonatomic, readonly) NSInteger year;
/// The link to the English Wikipedia article about this movie.
/// Since all movies in this app are extracted from the English Wikipedia database, this link can
/// never be nil.
@property (nonatomic, readonly) NSURL *wikipediaURL;
/// Link to the IMDb page for this movie, or nil.
@property (nullable, nonatomic, readonly) NSURL *imdbURL;

- (instancetype)initWithTitles:(NSDictionary<MovieRegion, NSString *> *)titles
                          year:(NSInteger)year
                  wikipediaURL:(NSURL *)wikipediaURL
                       imdbURL:(nullable NSURL *)imdbURL NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// This helper lists all movie regions in the order in which they should be displayed throughout
/// the app for consistency.
+ (NSArray<MovieRegion> *)allRegions;

/// The human-readable name of a region.
+ (NSString *)nameOfRegion:(MovieRegion)region;

@end

NS_ASSUME_NONNULL_END

