//
//  SuggestionsView.h
//  MovieDict
//
//  Created by Julian Raschke on 24.12.14. Happy Holidays!
//  Copyright (c) 2014 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SuggestionsView;


@protocol SuggestionsViewDelegate

@required
- (void)suggestionsView:(SuggestionsView *)suggestionsView didSelectSuggestion:(NSString *)suggestion;

@end


@interface SuggestionsView : UIView

@property (nonatomic, weak) IBOutlet id<SuggestionsViewDelegate> delegate;

@end
