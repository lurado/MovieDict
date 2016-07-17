//
//  MoviesViewController.m
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieViewController.h"


@interface MoviesViewController () <MovieSourceDelegate>
@end


@implementation MoviesViewController

- (void)setMovieSource:(MovieSource *)movieSource
{
    _movieSource = movieSource;
    
    movieSource.delegate = self;
    
    [self loadView];
    self.navigationItem.title = [Movie nameOfRegion:movieSource.region];
    self.tableView.delegate = movieSource;
    self.tableView.dataSource = movieSource;
    [self.tableView reloadData];
}

#pragma mark - MovieSourceDelegate

- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults
{
    [self.tableView reloadData];
}

- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie
{
    MovieViewController *destination = [[MovieViewController alloc] initWithNibName:nil bundle:nil];
    destination.movie = movie;
    [self.navigationController pushViewController:destination animated:YES];
}

@end
