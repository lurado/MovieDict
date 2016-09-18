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


static NSInteger const kSuggestionsCount = 5;
static NSTimeInterval const kMoveToTopDuration = 0.3;
static CGFloat const kSlotHeight = 44;


@interface SuggestionsView ()

@property (nonatomic) NSMutableIndexSet *occupiedSlots;

@end


@implementation SuggestionsView

- (id)initWithCoder:(NSCoder *)aDecoder
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
    self.backgroundColor = [UIColor whiteColor];
    
    self.occupiedSlots = [NSMutableIndexSet new];
    
    // Get this party started!
    [self addSuggestion];
}

- (void)addSuggestion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        Movie *movie = [Movie randomSuggestion];
        NSArray *allTitles = [movie.titles allValues];
        NSString *anyTitle = allTitles[arc4random_uniform((u_int32_t)allTitles.count)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addButtonWithTitle:anyTitle];
            
            NSTimeInterval delay = (self.subviews.count < kSuggestionsCount ? 0.0 : 0.5);
            
            // TODO - this loop should be moved into addButtonWithTitle:, so that we can do something useful when the view is full.
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
            [self performSelector:_cmd withObject:nil afterDelay:delay];
        });
    });
}

- (NSInteger)allocateSlot
{
    NSInteger slotsCount = self.bounds.size.height / kSlotHeight;
    NSMutableIndexSet *availableSlots = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, slotsCount)];
    [availableSlots removeIndexes:self.occupiedSlots];
    
    if (availableSlots.count == 0) {
        return NSNotFound;
    }
    
    NSUInteger slots[availableSlots.count];
    [availableSlots getIndexes:slots maxCount:availableSlots.count inIndexRange:NULL];
    NSInteger slot = slots[arc4random_uniform((u_int32_t)availableSlots.count)];
    
    [self.occupiedSlots addIndex:slot];
    
    return slot;
}

- (void)addButtonWithTitle:(NSString *)title
{
    NSInteger slot = [self allocateSlot];
    
    if (slot == NSNotFound) {
        // SuggestionsView is full!
        return;
    }
    
    CGFloat size = 15 + arc4random_uniform(30);
    
    UIButton *button = [SuggestionsButton buttonWithTitle:title fontSize:size];
    
    __block CGRect buttonFrame = button.frame;
    CGFloat alpha = (size + 5) / 100.0;
    NSTimeInterval duration = (100 - size) / 5.0 + arc4random_uniform(3);

    if (self.subviews.count < kSuggestionsCount) {
        buttonFrame.origin.x = arc4random_uniform(CGRectGetMaxX(self.bounds));
        button.titleLabel.alpha = 0;
        duration *= 0.8;
    }
    else {
        buttonFrame.origin.x = arc4random_uniform(CGRectGetMaxX(self.bounds)) + CGRectGetMaxX(self.bounds) + size;
        button.titleLabel.alpha = alpha;
    }
    buttonFrame.origin.y = slot * kSlotHeight + arc4random_uniform(kSlotHeight / 2) - kSlotHeight / 4;
    button.frame = buttonFrame;
    
    [self addSubview:button];
    
    [UIView animateWithDuration:duration animations:^{
        buttonFrame.origin.x = -buttonFrame.size.width - size;
        button.frame = buttonFrame;
        button.titleLabel.alpha = alpha;
    } completion:^(BOOL finished) {
        if (finished) {
            [button removeFromSuperview];
        }
        else {
            [button performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kMoveToTopDuration];
        }
        [self.occupiedSlots removeIndex:slot];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *keyPath = @"titleLabel.layer.presentationLayer.opacity";
    NSSortDescriptor *byOpacity = [[NSSortDescriptor alloc] initWithKey:keyPath ascending:NO];
    NSArray *subviewsByOpacity = [self.subviews sortedArrayUsingDescriptors:@[byOpacity]];

    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView:self];
        
        for (SuggestionsButton *button in subviewsByOpacity) {
            if ([button.layer.presentationLayer hitTest:touchLocation]) {
                [self.delegate suggestionsView:self didSelectSuggestion:button.searchQuery];
                [self moveButtonToTop:button];
                return;
            }
        }
    }
}

- (void)moveButtonToTop:(UIButton *)button
{
    // This hack is necessary on iOS 8+ (maybe 7+) to stop the button right where it is.
    // Without the following three lines, the button will move to the wrong position in the animation block.
    CGPoint position = [button.layer.presentationLayer position];
    [button.layer removeAllAnimations];
    button.layer.position = position;
    
    [UIView animateWithDuration:kMoveToTopDuration animations:^{
         CGRect frame = button.frame;
         frame.origin.x = 38;
         frame.origin.y = 0;
         button.frame = frame;
         button.titleLabel.alpha = 0.5;
     } completion:^(BOOL finished) {
         [button removeFromSuperview];
     }];
}

@end
