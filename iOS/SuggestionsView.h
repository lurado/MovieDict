//
//  SuggestionsView.h
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SuggestionsViewDelegate;


// A rectangular view that will regularly create moving, tappable SuggestionButtons.
// When one of these buttons is tapped, the delegate is notified.
@interface SuggestionsView : UIView

@property (nullable, nonatomic, weak) IBOutlet id<SuggestionsViewDelegate> delegate;

@end


@protocol SuggestionsViewDelegate

- (void)suggestionsViewDidSelectSuggestion:(NSString *)suggestion;

@end

NS_ASSUME_NONNULL_END
