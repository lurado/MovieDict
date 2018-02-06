//
//  MovieDatabase.h
//  MovieDict
//
//  Created by Julian Raschke on 06.02.18.
//  Copyright © 2018 Julian Raschke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

/// This class wraps away our SQLite/FMDB backend by offering one method per database query.
@interface MovieDatabase : NSObject

+ (instancetype)sharedDatabase;

/// Returns search results that match a search string, ordered by relevance.
/// @param limit The maximum number of results that must be returned.
/// @warning This method is synchronous, so it must NOT be called on the UI thread.
- (MovieResults *)searchFor:(NSString *)string inRegion:(MovieRegion)region limit:(NSInteger)limit;

/// Returns a single random movie from the database. Used by SuggestionsView.
/// @warning This method is synchronous, so it must NOT be called on the UI thread.
- (Movie *)randomSuggestion;

@end

NS_ASSUME_NONNULL_END
