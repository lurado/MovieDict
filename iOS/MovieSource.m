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


NSUInteger const kRegionLimit = 20;
NSUInteger const kTotalLimit = 50;
NSUInteger const kRegionShowMoreLimit = 250;


@interface MovieSource ()

@property (nonatomic, copy) MovieRegion region;
@property (nonatomic) NSOperationQueue *searchQueue;
@property (atomic, copy) NSString *currentQuery;
@property (atomic, copy) NSString *finishedQuery;
@property (nonatomic, copy) NSArray<MovieResults *> *results;

@end


@implementation MovieSource

- (id)init
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
    if (self.results == nil && self.finishedQuery.length > 0) {
        // "No results" cell
        return 1;
    }
    else {
        return self.results.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.results == nil && self.finishedQuery.length > 0) {
        // "No results" cell
        return 1;
    }
    else {
        MovieResults *resultsForRegion = self.results[section];
        return resultsForRegion.movies.count + (resultsForRegion.haveMore ? 1 : 0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.results == nil && self.finishedQuery.length > 0) {
        // "No results" cell
        return [self noResultsCellInTableView:tableView];
    }
    else if (indexPath.row >= self.results[indexPath.section].movies.count) {
        if (self.region == nil) {
            return [self showMoreResultsCellForRegion:[Movie allRegions][indexPath.section] inTableView:tableView];
        }
        else {
            return [self tooManyResultsCellInTableView:tableView];
        }
    }
    else {
        return [self cellForMovieInTableView:tableView indexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        return 20.0;
    }
    else {
        return 0.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.results == nil || self.results[section].movies.count == 0) {
        // "No results" cell, or no movies found for this region
        return nil;
    }
    
    if (self.region != nil) {
        // If this MovieSource targets a specific region, then we don't need headers
        return nil;
    }
    
    MovieRegion region = self.results[section].region;
    return [[Movie nameOfRegion:region] stringByAppendingString:@" movie titles"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title == nil) {
        // "No results" cell, or no movies found for this region
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

- (UITableViewCell *)cellForMovieInTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    MovieResults *results = self.results[indexPath.section];
    Movie *movie = results.movies[indexPath.row];
    NSString *englishTitle = movie.titles[kMovieRegionEnglish];
    
    cell.textLabel.text = movie.titles[results.region];
    if (englishTitle == nil || results.region == kMovieRegionEnglish) {
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"International title: %@ ", englishTitle];
    }
    if (movie.year) {
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingFormat:@"(%@)", @(movie.year)];
    }
    
    return cell;
}

- (UITableViewCell *)noResultsCellInTableView:(UITableView *)tableView
{
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"No results.";
        cell.detailTextLabel.text = @"Please try different search terms.";
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (UITableViewCell *)tooManyResultsCellInTableView:(UITableView *)tableView
{
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"Too many results.";
        cell.detailTextLabel.text = @"Please refine your search terms.";
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (UITableViewCell *)showMoreResultsCellForRegion:(MovieRegion)region inTableView:(UITableView *)tableView
{
    NSString *identifier = NSStringFromSelector(_cmd);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"More %@ results", [Movie nameOfRegion:region]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieResults *results = self.results[indexPath.section];
    if (indexPath.row < results.movies.count) {
        [self.delegate movieSource:self didSelectMovie:results.movies[indexPath.row]];
    }
    else if ([self.delegate respondsToSelector:@selector(movieSource:didSelectRegion:)]) {
        [self.delegate movieSource:self didSelectRegion:[Movie allRegions][indexPath.section]];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        self.currentQuery = nil;
        self.finishedQuery = nil;
        [self.delegate movieSource:self resultsHaveChanged:NO];
    }
    else {
        [self startSearchingFor:searchText];
    }
}

#pragma mark - Asynchronous searching

- (void)startSearchingFor:(NSString *)query
{
    self.currentQuery = query;
    
    [self.searchQueue cancelAllOperations];
    
    FindMoviesOperation *operation = [FindMoviesOperation new];
    operation.regionLimit = kRegionLimit;
    operation.totalLimit = kTotalLimit;
    operation.query = query;
    
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
        if ([self.currentQuery isEqual:operation.query]) {
            self.finishedQuery = operation.query;
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
    source.currentQuery = self.finishedQuery;
    source.region = region;

    FindMoviesOperation *operation = [FindMoviesOperation new];
    operation.regionLimit = operation.totalLimit = kRegionShowMoreLimit;
    operation.region = region;
    operation.query = source.currentQuery;
    
    FindMoviesOperation __weak *weakOperation = operation;
    operation.completionBlock = ^{
        [source findMoviesOperationDidFinish:weakOperation];
    };
    
    [source.searchQueue addOperation:operation];

    return source;
}

@end
