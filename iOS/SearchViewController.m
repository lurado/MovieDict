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


@interface SearchViewController () <UITableViewDelegate, MovieSourceDelegate, SuggestionsViewDelegate>

@property (nonatomic, strong) MovieSource *movieSource;

@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) SuggestionsView *suggestionsView;

@end


@implementation SearchViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    self.tableView = [self createTableView];
    self.suggestionsView = [self createSuggestionsView];
    self.searchBar = [self createSearchBar];
    
    [self adjustInsets:nil];
}

- (UITableView *)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    if ([tableView respondsToSelector:@selector(keyboardDismissMode)]) {
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return tableView;
}

- (SuggestionsView *)createSuggestionsView
{
    SuggestionsView *suggestionsView = [[SuggestionsView alloc] initWithFrame:self.view.bounds];
    suggestionsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:suggestionsView];
    return suggestionsView;
}

- (UISearchBar *)createSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:searchBar];
    [searchBar sizeToFit];
    return searchBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.placeholder = @"Search for movie titles in any language";
    self.navigationItem.title = @"MovieDict";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:NULL];
    
    self.movieSource = [MovieSource new];
    self.movieSource.delegate = self;
    self.suggestionsView.delegate = self;
    self.tableView.delegate = self.movieSource;
    self.tableView.dataSource = self.movieSource;
    self.searchBar.delegate = self.movieSource;
    
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
    // We don't remove ourselves from the defaultCenter in [dealloc]:
    // It's not necessary on iOS 9+, and -[UIViewController dealloc] implicitly did it in iOS 5-8.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        [self.tableView deselectRowAtIndexPath:selection animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Automatically focus the search bar on app launch.
    if (self.tableView.numberOfSections == 0) {
        [self.searchBar becomeFirstResponder];
    }
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

#pragma mark - MovieSourceDelegate

- (void)movieSource:(MovieSource *)movieSource resultsHaveChanged:(BOOL)haveResults;
{
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    
    // TODO the right half of this condition should be moved into MovieSource
    if (haveResults || self.searchBar.text.length > 0) {
        [self showSuggestions];
    }
    else {
        [self hideSuggestions];
    }
}

- (void)showSuggestions
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

- (void)hideSuggestions
{
    self.suggestionsView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.suggestionsView.alpha = 1;
    } completion:nil];
}

- (void)movieSource:(MovieSource *)movieSource didSelectMovie:(Movie *)movie
{
    MovieViewController *destination = [[MovieViewController alloc] initWithNibName:nil bundle:nil];
    destination.movie = movie;
    [self.navigationController pushViewController:destination animated:YES];
}

- (void)movieSource:(MovieSource *)movieSource didSelectRegion:(MovieRegion)region
{
    MoviesViewController *destination = [[MoviesViewController alloc] initWithNibName:nil bundle:nil];
    destination.movieSource = [self.movieSource movieSourceForSingleRegion:region];
    [self.navigationController pushViewController:destination animated:YES];
}

#pragma mark - SuggestionsViewDelegate

- (void)suggestionsView:(SuggestionsView *)suggestionsView didSelectSuggestion:(NSString *)suggestion
{
    self.searchBar.text = suggestion;
    [self.searchBar.delegate searchBar:self.searchBar textDidChange:self.searchBar.text];
}

@end
