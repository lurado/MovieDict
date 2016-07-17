//
//  MovieViewController.m
//  MovieDict
//
//  Created by Julian Raschke on 17.09.13.
//  Copyright (c) 2013 Julian Raschke. All rights reserved.
//

#import "MovieViewController.h"
#import "Movie.h"
#import "LanguageHelper.h"
#import "Branding.h"


static CGFloat const kHorizontalPadding = 20;
static CGFloat const kVerticalPadding = 2 * kHorizontalPadding;
static CGFloat const kCaptionWidth = 115;
static CGFloat const kPlecoButtonOffset = 2;


@interface MovieViewController ()

@property (nonatomic) UIPopoverController *masterPopoverController;

@end


@implementation MovieViewController

#pragma mark - Managing the detail item

- (void)setMovie:(Movie *)movie
{
    if (_movie != movie) {
        _movie = movie;
        // on iPad: [self rebuildScrollView];
    }
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - UIViewController lifecycle

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
    self.view = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"What do they call it?";
    
    if (&UIContentSizeCategoryDidChangeNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (void)dealloc
{
    if (&UIContentSizeCategoryDidChangeNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Building subviews

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
    [self viewWillLayoutSubviews];
    [self viewDidLayoutSubviews];
}

- (void)viewWillLayoutSubviews
{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
}

- (void)viewDidLayoutSubviews
{
    UIView *bottomView = nil;
    
    for (MovieRegion region in [Movie allRegions]) {
        if (self.movie.titles[region]) {
            NSString *regionName = [Movie nameOfRegion:region];
            NSString *title = self.movie.titles[region];
            
            [self addCaptionLabel:regionName below:bottomView];
            bottomView = [self addTitleLabel:title region:region below:bottomView];
        }
    }
    
    NSArray<UIButton *> *buttons = [self addButtonsBelow:bottomView];
    bottomView = [buttons firstObject] ?: bottomView;

    CGSize viewSize = self.view.bounds.size;
    CGFloat contentHeight = MAX(viewSize.height, CGRectGetMaxY(bottomView.frame) + kVerticalPadding);
    ((UIScrollView *)self.view).contentSize = CGSizeMake(viewSize.width, contentHeight);
}

- (UILabel *)addCaptionLabel:(NSString *)string below:(UIView *)below
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [[string componentsSeparatedByString:@"/"] firstObject];
    if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [Branding movieDictColor];
    [label sizeToFit];
    
    CGRect frame = label.frame;
    frame.origin.x = kCaptionWidth - frame.size.width + kHorizontalPadding;
    frame.origin.y = CGRectGetMaxY(below.frame) + kVerticalPadding;
    label.frame = frame;
    
    [self.view addSubview:label];
    
    return label;
}

- (UILabel *)addTitleLabel:(NSString *)title region:(MovieRegion)region below:(UIView *)below
{
    NSString *romanization = [LanguageHelper romanizationForTitle:title region:region];
    
    UIView *plecoButton = [LanguageHelper plecoButtonOrNilForTitle:title region:region];
    
    CGRect frame = CGRectZero;
    frame.origin.x = 2 * kHorizontalPadding + kCaptionWidth;
    frame.origin.y = CGRectGetMaxY(below.frame) + kVerticalPadding;
    frame.size.width = self.view.bounds.size.width - 3 * kHorizontalPadding - kCaptionWidth;
    if (plecoButton) {
        frame.size.width -= (kHorizontalPadding + plecoButton.frame.size.width);
    }
    frame.size.height = 1000;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = romanization.length ? [NSString stringWithFormat:@"%@\n%@", title, romanization] : title;
    if ([[UIFont class] respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label sizeToFit];
    
    [self.view addSubview:label];
    
    if (plecoButton) {
        CGRect frame = plecoButton.frame;
        frame.origin.x = self.view.bounds.size.width - frame.size.width - kHorizontalPadding;
        frame.origin.y = label.frame.origin.y - kPlecoButtonOffset;
        plecoButton.frame = frame;
        
        [self.view addSubview:plecoButton];
    }
    
    return label;
}

- (NSArray<UIButton *> *)addButtonsBelow:(UIView *)below
{
    CGFloat buttonsTop = CGRectGetMaxY(below.frame) + kVerticalPadding;

    NSMutableArray<UIButton *> *buttons = [NSMutableArray new];
    
    if (self.movie.imdbURL) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(openIMDb:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"IMDb"] forState:UIControlStateNormal];
        [button sizeToFit];
        [self.view addSubview:button];
        [buttons addObject:button];
    }
    
    if (self.movie.wikipediaURL) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(openWikipedia:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"Wikipedia"] forState:UIControlStateNormal];
        [button sizeToFit];
        [self.view addSubview:button];
        [buttons addObject:button];
    }
    
    if (buttons.count == 1) {
        CGRect frame = buttons[0].frame;
        frame.origin.x = round((self.view.bounds.size.width - frame.size.width) / 2);
        frame.origin.y = buttonsTop;
        buttons[0].frame = frame;
    }
    else if (buttons.count == 2) {
        CGRect frame = buttons[0].frame;
        frame.origin.x = kHorizontalPadding + kCaptionWidth - frame.size.width;
        frame.origin.y = buttonsTop;
        buttons[0].frame = frame;
        
        frame = buttons[1].frame;
        frame.origin.x = kHorizontalPadding * 2 + kCaptionWidth;
        frame.origin.y = buttonsTop;
        buttons[1].frame = frame;
    }
    
    return [buttons copy];
}

#pragma mark - IBActions

- (void)openWikipedia:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.movie.wikipediaURL];
}

- (void)openIMDb:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.movie.imdbURL];
}

@end
