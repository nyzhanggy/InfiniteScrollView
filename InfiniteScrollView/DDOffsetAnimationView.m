//
//  DDOffsetAnimationView.m


#import "DDOffsetAnimationView.h"

@interface DDOffsetAnimationView ()
@property (nonatomic, strong) UIView *topMaskView;
@end

@implementation DDOffsetAnimationView

- (void)updateWithProgress:(CGFloat)progress {
    self.topMaskView.alpha = fabs(progress) * 0.5;
    self.contentView.frame = CGRectMake(CGRectGetWidth(self.bounds) * progress * 0.50, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}


- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    self.clipsToBounds = YES;
    if (![self.subviews containsObject:_contentView]) {
        [self addSubview:_contentView];
    }
    
    if (!_topMaskView) {
        _topMaskView = [[UIView alloc] initWithFrame:self.bounds];
        _topMaskView.backgroundColor = [UIColor blackColor];
        _topMaskView.alpha = 0;
        
        [self addSubview:_topMaskView];
    }
}


@end
