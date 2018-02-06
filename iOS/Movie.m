//
//  Movie.m
//  MovieDict
//
//  Created by Julian Raschke on 18.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "Movie.h"


// These constants map directly to column names in our SQLite database.
MovieRegion const kMovieRegionEnglish  = @"en";
MovieRegion const kMovieRegionGerman   = @"de";
MovieRegion const kMovieRegionFrance   = @"fr";
MovieRegion const kMovieRegionRussia   = @"ru";
MovieRegion const kMovieRegionJapanese = @"ja";
MovieRegion const kMovieRegionChina    = @"cn";
MovieRegion const kMovieRegionChinese  = @"zh";
MovieRegion const kMovieRegionTaiwan   = @"tw";
MovieRegion const kMovieRegionHongKong = @"hk";


@implementation Movie

- (instancetype)initWithTitles:(NSDictionary<MovieRegion, NSString *> *)titles
                          year:(NSInteger)year
                  wikipediaURL:(NSURL *)wikipediaURL
                       imdbURL:(nullable NSURL *)imdbURL
{
    if (self = [super init]) {
        _titles = titles;
        _year = year;
        _wikipediaURL = wikipediaURL;
        _imdbURL = imdbURL;
    }
    return self;
}

+ (NSArray<MovieRegion> *)allRegions
{
    // This order will be used to display search results, so things should be grouped and ordered by
    // priority.
    return @[
             // Europe
             kMovieRegionEnglish,
             kMovieRegionGerman,
             kMovieRegionFrance,
             // Eurasia
             kMovieRegionRussia,
             // East Asia
             kMovieRegionJapanese,
             kMovieRegionChinese,
             kMovieRegionChina,
             kMovieRegionTaiwan,
             kMovieRegionHongKong,
    ];
}

+ (NSString *)nameOfRegion:(MovieRegion)region
{
    return @{
             kMovieRegionEnglish:  @"English/international",
             kMovieRegionGerman:   @"German",
             kMovieRegionFrance:   @"French",
             kMovieRegionRussia:   @"Russian",
             kMovieRegionJapanese: @"Japanese",
             kMovieRegionChinese:  @"Chinese",
             kMovieRegionChina:    @"China",
             kMovieRegionTaiwan:   @"Taiwan",
             kMovieRegionHongKong: @"Hong Kong",
    }[region];
}

@end
