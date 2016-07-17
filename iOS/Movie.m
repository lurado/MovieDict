//
//  Movie.m
//  MovieDict
//
//  Created by Julian Raschke on 18.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "Movie.h"
#import "FMDB.h"


MovieRegion const kMovieRegionEnglish = @"en";
MovieRegion const kMovieRegionGerman = @"de";
MovieRegion const kMovieRegionFrance = @"fr";
MovieRegion const kMovieRegionRussia = @"ru";
MovieRegion const kMovieRegionJapanese = @"ja";
MovieRegion const kMovieRegionChina = @"cn";
MovieRegion const kMovieRegionChinese = @"zh";
MovieRegion const kMovieRegionTaiwan = @"tw";
MovieRegion const kMovieRegionHongKong = @"hk";


@implementation Movie

+ (NSArray<MovieRegion> *)allRegions
{
    // This order will be used to display search results, so things should be grouped and ordered by priority.
    return @[kMovieRegionEnglish, kMovieRegionGerman, kMovieRegionFrance, kMovieRegionRussia, kMovieRegionJapanese, kMovieRegionChinese, kMovieRegionChina, kMovieRegionTaiwan, kMovieRegionHongKong];
}

+ (NSString *)nameOfRegion:(MovieRegion)region
{
    return @{
             kMovieRegionEnglish: @"English/international",
             kMovieRegionGerman: @"German",
             kMovieRegionFrance: @"French",
             kMovieRegionRussia: @"Russian",
             kMovieRegionJapanese: @"Japanese",
             kMovieRegionChinese: @"Chinese",
             kMovieRegionChina: @"China",
             kMovieRegionTaiwan: @"Taiwan",
             kMovieRegionHongKong: @"Hong Kong",
    }[region];
}

+ (FMDatabaseQueue *)databaseQueue
{
    static FMDatabaseQueue *databaseQueue = nil;
    if (databaseQueue == nil) {
        NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"Movies" ofType:@"db"];
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    }
    return databaseQueue;
}

- (instancetype)initWithResultSet:(FMResultSet *)s
{
    if (self = [super init]) {
        NSMutableDictionary<NSString *, NSString *> *titles = [NSMutableDictionary new];
        for (MovieRegion region in [self.class allRegions]) {
            NSString *result = [s stringForColumn:region];
            if (result) {
                titles[region] = result;
            }
        }
        _titles = [titles copy];

        _year = [s intForColumn:@"year"];
        
        NSString *wikipediaURLString = [s stringForColumn:@"wikipedia"];
        if (wikipediaURLString) {
            _wikipediaURL = [NSURL URLWithString:wikipediaURLString];
        }
        NSString *imdbURLString = [s stringForColumn:@"imdb"];
        if (imdbURLString) {
            _imdbURL = [NSURL URLWithString:imdbURLString];
        }
    }
    
    return self;
}

+ (MovieResults *)moviesMatchingString:(NSString *)string inRegion:(MovieRegion)region limit:(NSInteger)limit
{
    NSMutableArray<Movie *> *movies = [NSMutableArray new];
    
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *s;
        
        if ([db tableExists:[@"fts_" stringByAppendingString:region]]) {
            NSString *escapedString = string;
            escapedString = [escapedString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            escapedString = [escapedString stringByReplacingOccurrencesOfString:@"*" withString:@"**"];
            
            NSString *innerSQL = [NSString stringWithFormat:@"SELECT docid FROM fts_%@ WHERE %@ MATCH '\"%@*\"'", region, region, escapedString];
            NSString *SQL = [NSString stringWithFormat:@"SELECT * FROM movies WHERE id in (%@) ORDER BY LENGTH(%@) LIMIT (?)", innerSQL, region];
            s = [db executeQuery:SQL, @(limit + 1)];
        }
        else {
            NSString *escapedString = string;
            escapedString = [escapedString stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
            
            NSString *SQL = [NSString stringWithFormat:@"SELECT * FROM movies WHERE %@ LIKE (?) ORDER BY LENGTH(%@) ASC LIMIT (?)", region, region];
            NSString *searchPattern = [NSString stringWithFormat:@"%%%@%%", escapedString];
            s = [db executeQuery:SQL, searchPattern, @(limit + 1)];
        }
        
        while ([s next]) {
            [movies addObject:[[self alloc] initWithResultSet:s]];
        }
    }];
    
    MovieResults *results = [MovieResults new];
    if (movies.count > limit) {
        results.movies = [movies subarrayWithRange:NSMakeRange(0, limit)];
        results.haveMore = YES;
    }
    else {
        results.movies = movies;
        results.haveMore = NO;
    }
    return results;
}

+ (Movie *)randomSuggestion
{
    static u_int32_t numberOfSuggestions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self databaseQueue] inDatabase:^(FMDatabase *db) {
            FMResultSet *s = [db executeQuery:@"SELECT MAX(suggestion) FROM movies"];
            if ([s next]) {
                numberOfSuggestions = [s intForColumnIndex:0];
            }
            [s close];
        }];
    });
    
    __block Movie *result = nil;
    [[self databaseQueue] inDatabase:^(FMDatabase *db) {
        NSInteger suggestion = arc4random_uniform(numberOfSuggestions);
        FMResultSet *s = [db executeQuery:@"SELECT * FROM movies WHERE suggestion = ?", @(suggestion)];
        if ([s next]) {
            result = [[self alloc] initWithResultSet:s];
        }
        [s close];
    }];
    return result;
}

@end
