//
//  SearchViewController.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "SearchViewController.h"
#import "MovieViewController.h"
#import "MoviesViewController.h"
#import "MovieSource.h"
#import "SuggestionsView.h"


@interface SearchViewController () <MovieSourceDelegate, SuggestionsViewDelegate>

@property (strong, nonatomic) IBOutlet MovieSource *movieSource;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SuggestionsView *suggestionsView;

@end


@implementation SearchViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self adjustInsets:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustInsets:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustInsets:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustInsets:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selection = self.tableView.indexPathForSelectedRow;
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Automatically focus the search bar on app launch.
    if (! animated) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)adjustInsets:(NSNotification *)notification
{
    UIEdgeInsets insets = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
    
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    if (frameValue) {
        CGRect keyboardFrame = [self.view convertRect:frameValue.CGRectValue fromView:self.view.window];
        insets.bottom = self.view.bounds.size.height - CGRectGetMinY(keyboardFrame);
    }
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"showMovie"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        MovieViewController *destination = (id)navigationController.topViewController;
        destination.movie = sender;
    }
    else if ([segue.identifier isEqualToString:@"showMore"]) {
        MoviesViewController *destination = segue.destinationViewController;
        destination.movieSource = [self.movieSource movieSourceForSingleRegion:sender];
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - MovieSourceDelegate

- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults
{
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    
    // TODO the right half of this condition should be moved into MovieSource
    if (haveResults || self.searchBar.text.length > 0) {
        [self hideSuggestions];
    }
    else {
        [self showSuggestions];
    }
}

- (void)hideSuggestions
{
    self.suggestionsView.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.suggestionsView.alpha = 0;
    } completion:^(BOOL finished) {
        // Note: "finished" is "YES" even when the animation was cancelled
        if (self.suggestionsView.alpha == 0) {
            self.suggestionsView.hidden = YES;
        }
    }];
}

- (void)showSuggestions
{
    self.suggestionsView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.suggestionsView.alpha = 1;
    } completion:nil];
}

- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie
{
    [self performSegueWithIdentifier:@"showMovie" sender:movie];
}

- (void)movieSource:(MovieSource *)movieSource didSelectRegion:(MovieRegion)region
{
    [self performSegueWithIdentifier:@"showMore" sender:region];
}

#pragma mark - SuggestionsViewDelegate

- (void)suggestionsView:(SuggestionsView *)suggestionsView didSelectSuggestion:(NSString *)suggestion
{
    self.searchBar.text = suggestion;
    [self.searchBar.delegate searchBar:self.searchBar textDidChange:self.searchBar.text];
}

@end
