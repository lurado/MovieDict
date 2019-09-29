//
//  SuggestionsView.m
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import "SuggestionsView.h"
#import "SuggestionsButton.h"
#import "Movie.h"
#import "MovieDatabase.h"


/// How many suggestions should be visible at all times?
static NSInteger const kSuggestionsCount = 5;

/// When a suggestion is tapped, this is how long it takes for the button to animate towards the
/// view's top.
static NSTimeInterval const kMoveToTopDuration = 0.3;

/// See the comment for SuggestionsView.occupiedSlots.
static CGFloat const kSlotHeight = 44;


@interface SuggestionsView ()

/// The SuggestionView is divided into slots of this height to prevent multiple suggestions from
/// colliding. If a slot is in this NSIndexSet, it is considered occupied.
@property (nonatomic) NSMutableIndexSet *occupiedSlots;

@end


@implementation SuggestionsView

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSuggestionsView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSuggestionsView];
    }
    return self;
}

- (void)setupSuggestionsView
{
    if (@available(iOS 13, *)) {
        self.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self.occupiedSlots = [NSMutableIndexSet new];
    
    // Get this party started! It is important to call this right here, because addSuggestion will
    // call itself (with a delay) to continuously spawn new floating suggestion buttons.
    [self addSuggestion];
}

/// Asynchronously finds a new suggestion and then adds the corresponding button to the view.
- (void)addSuggestion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        Movie *movie = [[MovieDatabase sharedDatabase] randomSuggestion];
        NSArray *allTitles = movie.titles.allValues;
        NSString *anyTitle = allTitles[arc4random_uniform((uint32_t) allTitles.count)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addButtonWithTitle:anyTitle];
            
            // If we don't have enough suggestions on our screen, immediately find the next one.
            // Otherwise, take your time...
            NSTimeInterval delay = (self.subviews.count < kSuggestionsCount ? 0.0 : 0.5);
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
            [self performSelector:_cmd withObject:nil afterDelay:delay];
        });
    });
}

/// Finds a vertical slot in this view that still is still free.
/// @return NSNotFound if there was no free slot
- (NSInteger)allocateSlot
{
    NSRange slotsRange = NSMakeRange(0, self.bounds.size.height / kSlotHeight);
    NSMutableIndexSet *availableSlots = [NSMutableIndexSet indexSetWithIndexesInRange:slotsRange];
    [availableSlots removeIndexes:self.occupiedSlots];
    
    if (availableSlots.count == 0) {
        return NSNotFound;
    }
    
    NSUInteger slots[availableSlots.count];
    [availableSlots getIndexes:slots maxCount:availableSlots.count inIndexRange:NULL];
    NSInteger slot = slots[arc4random_uniform((uint32_t) availableSlots.count)];
    
    [self.occupiedSlots addIndex:slot];
    
    return slot;
}

/// Adds a new button for the given suggestion, but only if there is a free slot.
- (void)addButtonWithTitle:(NSString *)title
{
    NSInteger slot = [self allocateSlot];
    
    if (slot == NSNotFound) {
        // This view is full!
        return;
    }
    
    // Pick a random button height...
    CGFloat size = 15 + arc4random_uniform(30);
    UIButton *button = [SuggestionsButton buttonWithTitle:title fontSize:size];
    
    __block CGRect buttonFrame = button.frame;
    // Translucency: larger views have a higher opacity.
    CGFloat alpha = (size + 5) / 100.0;
    // This is the time it takes for a view to fade in.
    NSTimeInterval duration = (100 - size) / 5.0 + arc4random_uniform(3);

    if (self.subviews.count < kSuggestionsCount) {
        // When initially filling the view with floating buttons (e.g. at app start), suggestions
        // spawn all over the place and do so much faster.
        buttonFrame.origin.x = arc4random_uniform(CGRectGetMaxX(self.bounds));
        button.titleLabel.alpha = 0;
        duration *= 0.8;
    } else {
        // After the initial fill, all suggestions float into view from the right-hand side.
        buttonFrame.origin.x = arc4random_uniform(CGRectGetMaxX(self.bounds))
                             + CGRectGetMaxX(self.bounds)
                             + size;
        button.titleLabel.alpha = alpha;
    }
    // Position the view somewhere inside its slot.
    buttonFrame.origin.y = slot * kSlotHeight + arc4random_uniform(kSlotHeight / 2) - kSlotHeight / 4;
    
    button.frame = buttonFrame;
    
    [self addSubview:button];
    
    [UIView animateWithDuration:duration animations:^{
        // Move the view left until it leaves the screen/view...
        buttonFrame.origin.x = -buttonFrame.size.width - size;
        button.frame = buttonFrame;
        button.titleLabel.alpha = alpha;
    } completion:^(BOOL finished) {
        // ...then take it out of the view hierarchy.
        if (finished) {
            [button removeFromSuperview];
        } else {
            // If this animation wasn't finished, that means the view was tapped by the user and we
            // should only remove it after the move-to-top animation has finished.
            [button performSelector:@selector(removeFromSuperview)
                         withObject:nil
                         afterDelay:kMoveToTopDuration];
        }
        [self.occupiedSlots removeIndex:slot];
    }];
}

/// This method performs manual, opacity-based hit-testing across all currently visible suggestions
/// to determine which one the user tapped.
/// This prevents the awkward phenomenon where the user taps are barely visible (fresh) suggestion
/// when they meant to tap on an existing, fully visible suggestion.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *keyPath = @"titleLabel.layer.presentationLayer.opacity";
    NSSortDescriptor *byOpacity = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:NO];
    NSArray *subviewsByOpacity = [self.subviews sortedArrayUsingDescriptors:@[byOpacity]];

    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView:self];
        
        for (SuggestionsButton *button in subviewsByOpacity) {
            if ([button.layer.presentationLayer hitTest:touchLocation]) {
                [self.delegate suggestionsViewDidSelectSuggestion:button.searchQuery];
                [self moveButtonToTop:button];
                // Each tap must only trigger one suggestion -> return now.
                return;
            }
        }
    }
}

/// Starts an animation that moves a button to the top of this view (= its superview), and then
/// removes the button from the view hierarchy.
- (void)moveButtonToTop:(UIButton *)button
{
    // This hack is necessary on iOS 8+ (maybe 7+) to stop the button right where it is.
    // Without the following three lines, the button will move to the wrong position in the
    // animation block.
    CGPoint position = [button.layer.presentationLayer position];
    [button.layer removeAllAnimations];
    button.layer.position = position;
    
    [UIView animateWithDuration:kMoveToTopDuration animations:^{
        CGRect frame = button.frame;
        // This roughly moves the button to the right of the UISearchBar's looking-glass icon.
        frame.origin.x = 38;
        frame.origin.y = 0;
        button.frame = frame;
        button.titleLabel.alpha = 0.5;
     } completion:^(BOOL finished) {
        [button removeFromSuperview];
     }];
}

@end
