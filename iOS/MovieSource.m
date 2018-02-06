//
//  MovieSource.m
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import "MovieSource.h"
#import "Movie.h"
#import "FindMoviesOperation.h"
#import "Branding.h"


/// Max. number of search results per region in an all-region search.
NSUInteger const kRegionLimit = 20;

/// Max. number of search results across all regions in an all-region search.
NSUInteger const kTotalLimit = 50;

/// Max. number of search results in a single-region search.
NSUInteger const kRegionShowMoreLimit = 250;


@interface MovieSource ()

@property (nonatomic, copy) MovieRegion region;
@property (nonatomic) NSOperationQueue *searchQueue;
@property (atomic, copy) NSString *currentSearchText;
@property (atomic, copy) NSString *finishedSearchText;
@property (nonatomic, copy) NSArray<MovieResults *> *results;

@end


@implementation MovieSource

- (instancetype)init
{
    if (self = [super init]) {
        self.searchQueue = [NSOperationQueue new];
        self.searchQueue.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.results == nil && self.finishedSearchText.length > 0) {
        // Single section with single "no results" cell.
        return 1;
    } else {
        return self.results.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.results == nil && self.finishedSearchText.length > 0) {
        // "No results" cell.
        return 1;
    } else {
        MovieResults *resultsForRegion = self.results[section];
        // +1 for "more results from this region" cell.
        return resultsForRegion.movies.count + (resultsForRegion.haveMore ? 1 : 0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.results == nil && self.finishedSearchText.length > 0) {
        // "No results" cell
        return [self noResultsCellInTableView:tableView];
    } else if (indexPath.row >= self.results[indexPath.section].movies.count) {
        if (self.region == nil) {
            // If we are showing movies from all regions, let the user drill down into every region
            // which has more movies available:
            return [self showMoreResultsCellForRegion:self.results[indexPath.section].region
                                          inTableView:tableView];
        } else {
            // If the user has already filtered by region, we can't drill down any further:
            return [self tooManyResultsCellInTableView:tableView];
        }
    }

    // The boring default case: A search result!
    return [self cellForMovieInTableView:tableView indexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.results == nil) {
        // The "no results" cell does not have a header.
        return nil;
    }
    
    if (self.region != nil) {
        // If this MovieSource targets a specific region, then we don't need headers at all.
        return nil;
    }
    
    MovieRegion region = self.results[section].region;
    return [[Movie nameOfRegion:region] stringByAppendingString:@" movie titles"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section] == nil) {
        return 0.0;
    }

    // Enough vertical place for the view returned by tableView:viewForHeaderInSection:
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title == nil) {
        // The "no results" cell does not have a header.
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [label sizeToFit];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectInset(label.frame, -8, 0)];
    label.frame = CGRectOffset(label.frame, 16, 0);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [container addSubview:label];
    container.backgroundColor = [Branding sectionHeaderBackgroundColor];
    
    return container;
}

- (UITableViewCell *)cellForMovieInTableView:(UITableView *)tableView
                                   indexPath:(NSIndexPath *)indexPath
{
    // Only cells created by this method can be recycled in this method.
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier];
    }
    
    MovieResults *results = self.results[indexPath.section];
    Movie *movie = results.movies[indexPath.row];
    NSString *englishTitle = movie.titles[kMovieRegionEnglish];
    
    cell.textLabel.text = movie.titles[results.region];
    
    // Determine what to do with the detailTextLabel.
    if (englishTitle == nil || results.region == kMovieRegionEnglish) {
        if (movie.year) {
            // Don't show international title, but year.
            cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", @(movie.year)];
        } else {
            // Nothing to show.
            cell.detailTextLabel.text = nil;
        }
    } else {
        // International title...
        cell.detailTextLabel.text = [NSString stringWithFormat:@"International title: %@",
                                     englishTitle];
        if (movie.year) {
            // ...plus optional year, with space between both strings.
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                         cell.detailTextLabel.text, @(movie.year)];
        }
    }
    
    return cell;
}

- (UITableViewCell *)noResultsCellInTableView:(UITableView *)tableView
{
    // Only cells created by this method can be recycled in this method.
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"No results.";
        cell.detailTextLabel.text = @"Please try different search terms.";
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (UITableViewCell *)tooManyResultsCellInTableView:(UITableView *)tableView
{
    // Only cells created by this method can be recycled in this method.
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"Too many results.";
        cell.detailTextLabel.text = @"Please refine your search terms.";
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (UITableViewCell *)showMoreResultsCellForRegion:(MovieRegion)region inTableView:(UITableView *)tableView
{
    // Only cells created by this method can be recycled in this method.
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"More %@ results",
                           [Movie shortNameOfRegion:region]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieResults *results = self.results[indexPath.section];
    if (indexPath.row < results.movies.count) {
        [self.delegate movieSource:self didSelectMovie:results.movies[indexPath.row]];
    } else if ([self.delegate respondsToSelector:@selector(movieSource:didSelectRegion:)]) {
        [self.delegate movieSource:self didSelectRegion:results.region];
    }
}

#pragma mark - Asynchronous searching

- (void)setSearchText:(NSString *)searchText
{
    if (searchText.length == 0) {
        self.currentSearchText = nil;
        self.finishedSearchText = nil;
        [self.delegate movieSource:self resultsHaveChanged:NO];
        return;
    }

    self.currentSearchText = searchText;
    
    [self.searchQueue cancelAllOperations];
    
    FindMoviesOperation *operation = [FindMoviesOperation new];
    operation.regionLimit = kRegionLimit;
    operation.totalLimit = kTotalLimit;
    operation.searchText = searchText;
    
    FindMoviesOperation __weak *weakOperation = operation;
    operation.completionBlock = ^{
        [self findMoviesOperationDidFinish:weakOperation];
    };
    
    [self.searchQueue addOperation:operation];
}

- (void)findMoviesOperationDidFinish:(FindMoviesOperation *)operation
{
    // Ignore cancelled operations as they might have inconsistent results.
    if (operation.cancelled) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // If these results are still what the user is looking for, let our delegate know:
        if ([self.currentSearchText isEqual:operation.searchText]) {
            self.finishedSearchText = operation.searchText;
            self.results = operation.results;
            BOOL haveMovies = (self.results != nil);
            [self.delegate movieSource:self resultsHaveChanged:haveMovies];
        }
    });
}

#pragma mark - Splitting off into a single-region data source

- (instancetype)movieSourceForSingleRegion:(MovieRegion)region
{
    MovieSource *source = [MovieSource new];
    source.currentSearchText = self.finishedSearchText;
    source.region = region;

    FindMoviesOperation *operation = [FindMoviesOperation new];
    operation.regionLimit = operation.totalLimit = kRegionShowMoreLimit;
    operation.region = region;
    operation.searchText = source.currentSearchText;
    
    FindMoviesOperation __weak *weakOperation = operation;
    operation.completionBlock = ^{
        [source findMoviesOperationDidFinish:weakOperation];
    };
    
    [source.searchQueue addOperation:operation];

    return source;
}

@end
