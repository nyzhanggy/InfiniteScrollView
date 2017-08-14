//
//  DDOffsetAnimationView.h

#import <UIKit/UIKit.h>

@interface DDOffsetAnimationView : UIView
@property (nonatomic, strong) UIView *contentView;
- (void)updateWithProgress:(CGFloat)progress;
@end
