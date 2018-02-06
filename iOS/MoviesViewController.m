//
//  MoviesViewController.m
//  MovieDict
//
//  Created by Julian Raschke on 17.07.16.
//  Copyright © 2016 Julian Raschke. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieViewController.h"


@implementation MoviesViewController

- (void)setMovieSource:(MovieSource *)movieSource
{
    _movieSource = movieSource;
    
    movieSource.delegate = self;
    
    [self loadViewIfNeeded];
    self.navigationItem.title = [Movie nameOfRegion:movieSource.region];
    self.tableView.delegate = movieSource;
    self.tableView.dataSource = movieSource;
    [self.tableView reloadData];
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"showMovie"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MovieViewController *destination = (id) navigationController.topViewController;
        destination.movie = sender;
        destination.currentKeyboardHeight = self.currentKeyboardHeight;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - MovieSourceDelegate

- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults
{
    [self.tableView reloadData];
}

- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie
{
    [self performSegueWithIdentifier:@"showMovie" sender:movie];
}

@end
