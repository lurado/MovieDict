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


typedef enum {
    SectionTranslations,
    SectionButtons,
    kSections
} Section;


@interface MovieViewController () <UITableViewDataSource>

@property (nonatomic, copy) NSArray<MovieRegion> *regions;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionTranslations:
            return self.regions.count;
        // TODO: Bring back IMDb/Wikipedia buttons.
        // case SectionButtons:
        //     return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTranslations: {
            MovieRegion region = self.regions[indexPath.row];
            TranslationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Translation" forIndexPath:indexPath];
            [cell setupWithRegion:region title:self.movie.titles[region]];
            return cell;
        }
        case SectionButtons: {
            return [tableView dequeueReusableCellWithIdentifier:@"Buttons" forIndexPath:indexPath];
        }
        default: {
            return nil;
        }
    }
}

// TODO: Bring back IMDb/Wikipedia buttons.
// 
//    if (self.movie.imdbURL) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self action:@selector(openIMDb:) forControlEvents:UIControlEventTouchUpInside];
//        [button setImage:[UIImage imageNamed:@"IMDb"] forState:UIControlStateNormal];
//        [button sizeToFit];
//        [self.view addSubview:button];
//        [buttons addObject:button];
//    }
//    
//    if (self.movie.wikipediaURL) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self action:@selector(openWikipedia:) forControlEvents:UIControlEventTouchUpInside];
//        [button setImage:[UIImage imageNamed:@"Wikipedia"] forState:UIControlStateNormal];
//        [button sizeToFit];
//        [self.view addSubview:button];
//        [buttons addObject:button];
//    }

//#pragma mark - IBActions
//
//- (void)openWikipedia:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:self.movie.wikipediaURL];
//}
//
//- (void)openIMDb:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:self.movie.imdbURL];
//}

@end
