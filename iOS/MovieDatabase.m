//
//  MovieDatabase.m
//  MovieDict
//
//  Created by Julian Raschke on 06.02.18.
//  Copyright © 2018 Julian Raschke. All rights reserved.
//

#import "MovieDatabase.h"
#import "MovieResults.h"
#import "FMDB.h"


@interface MovieDatabase ()

@property (nonnull, nonatomic) FMDatabaseQueue *databaseQueue;
@property (nonatomic) NSInteger suggestionsCount;

@end


@implementation MovieDatabase

+ (instancetype)sharedDatabase
{
    static MovieDatabase *sharedDatabase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [MovieDatabase new];
    });
    return sharedDatabase;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"Movies" ofType:@"db"];
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        
        [_databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *s = [db executeQuery:@"SELECT MAX(suggestion) FROM movies"];
            if ([s next]) {
                _suggestionsCount = [s intForColumnIndex:0];
            }
            [s close];
        }];
    }
    return self;
}

/// A small helper to translate one row in our SQLite table into a Movie object.
- (Movie *)movieFromResultSet:(FMResultSet *)s
{
    NSMutableDictionary<NSString *, NSString *> *titles = [NSMutableDictionary new];
    for (MovieRegion region in [Movie allRegions]) {
        NSString *result = [s stringForColumn:region];
        if (result) {
            titles[region] = result;
        }
    }
    NSInteger year = [s intForColumn:@"year"];
    
    NSString *wikipediaURLString = [s stringForColumn:@"wikipedia"];
    NSAssert(wikipediaURLString != nil, @"every movie must have a Wikipedia link");
    NSURL *wikipediaURL = [NSURL URLWithString:wikipediaURLString];
    
    NSString *imdbURLString = [s stringForColumn:@"imdb"];
    NSURL *imdbURL = (imdbURLString ? [NSURL URLWithString:imdbURLString] : nil);
    
    return [[Movie alloc] initWithTitles:[titles copy]
                                    year:year
                            wikipediaURL:wikipediaURL
                                 imdbURL:imdbURL];
}

- (MovieResults *)searchFor:(NSString *)string inRegion:(MovieRegion)region limit:(NSInteger)limit
{
    NSMutableArray<Movie *> *movies = [NSMutableArray new];
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *s;
        
        // Dynamically use SQLite's full-text search if the corresponding table exists.
        if ([db tableExists:[@"fts_" stringByAppendingString:region]]) {
            NSString *safeString = string;
            safeString = [safeString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            safeString = [safeString stringByReplacingOccurrencesOfString:@"*" withString:@"**"];
            
            // This inner SQL query will find matching movie "docids" (movies.id) using full-text
            // search.
            NSString *ftsQuery = @"SELECT docid FROM fts_%@ WHERE %@ MATCH '\"%@*\"'";
            NSString *ftsSQL = [NSString stringWithFormat:ftsQuery, region, region, safeString];
            
            // This outer SQL query orders and limits search results.
            // When ordering, prefer short matches (= query is a higher percentage of the title)
            // and new movies.
            NSString *query = @"SELECT * FROM movies WHERE id in (%@)"
                               "ORDER BY LENGTH(%@) ASC, year DESC LIMIT (?)";
            NSString *SQL = [NSString stringWithFormat:query, ftsSQL, region];
            
            // Fetch one more result than actually asked for; see below.
            s = [db executeQuery:SQL, @(limit + 1)];
        }
        else {
            NSString *safeString = string;
            safeString = [safeString stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];

            // When there is no FTS table, just perform a standard SQL LIKE search.
            // The ORDER part here must be kept in sync with the if() branch above for consistency.
            NSString *query = @"SELECT * FROM movies WHERE %@ LIKE (?)"
                               "ORDER BY LENGTH(%@) ASC, year DESC LIMIT (?)";
            NSString *SQL = [NSString stringWithFormat:query, region, region];
            NSString *searchPattern = [NSString stringWithFormat:@"%%%@%%", safeString];

            // Fetch one more result than actually asked for; see below.
            s = [db executeQuery:SQL, searchPattern, @(limit + 1)];
        }
        
        while ([s next]) {
            [movies addObject:[self movieFromResultSet:s]];
        }
    }];

    BOOL haveMore = NO;
    // Truncate our search results if we found limit+1 entries (which is why we set the limit to
    // limit+1 in the code above).
    if (movies.count > limit) {
        [movies removeLastObject];
        haveMore = YES;
    }

    return [[MovieResults alloc] initWithRegion:region movies:[movies copy] haveMore:haveMore];
}

- (Movie *)randomSuggestion
{
    __block Movie *result = nil;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSInteger suggestion = arc4random_uniform((uint32_t) self.suggestionsCount);
        FMResultSet *s =
            [db executeQuery:@"SELECT * FROM movies WHERE suggestion = ?", @(suggestion)];
        BOOL haveResult = [s next];
        NSAssert(haveResult, @"the database must contain one suggestion for each index");
        result = [self movieFromResultSet:s];
        [s close];
    }];
    return result;
}

@end
