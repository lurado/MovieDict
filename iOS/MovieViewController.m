//
//  MovieViewController.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "MovieViewController.h"
#import "Movie.h"
#import "TranslationCell.h"


@interface MovieViewController () <UITableViewDataSource>

@property (nonatomic, copy) NSArray<MovieRegion> *regions;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *imdbButton;
@property (weak, nonatomic) IBOutlet UIButton *wikipediaButton;

@end


@implementation MovieViewController

#pragma mark - Managing the detail item

- (void)setMovie:(Movie *)movie
{
    if (_movie != movie) {
        _movie = movie;
        
        NSMutableArray<MovieRegion> *regions = [NSMutableArray new];
        for (MovieRegion region in [Movie allRegions]) {
            if (movie.titles[region]) {
                [regions addObject:region];
            }
        }
        self.regions = regions;
        
        self.imdbButton.hidden = (movie.imdbURL == nil);
        self.wikipediaButton.hidden = (movie.wikipediaURL == nil);
        
        [self.tableView reloadData];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // When these buttons are first (un)hidden, they might still be nil (view not loaded yet).
    self.imdbButton.hidden = (self.movie.imdbURL == nil);
    self.wikipediaButton.hidden = (self.movie.wikipediaURL == nil);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.regions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieRegion region = self.regions[indexPath.row];
    TranslationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Translation" forIndexPath:indexPath];
    [cell setupWithRegion:region title:self.movie.titles[region]];
    return cell;
}

#pragma mark - IBActions

- (IBAction)openIMDb:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.movie.imdbURL];
}

- (IBAction)openWikipedia:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.movie.wikipediaURL];
}

@end
