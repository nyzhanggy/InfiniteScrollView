//
//  DDInfiniteScrollView.m


#import "DDInfiniteScrollView.h"

@interface DDInfiniteScrollView ()<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL willScrolling;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *reusableItemView;
@property (nonatomic, assign) NSInteger numberOfItem;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) UIView *controlView;
@end

@implementation DDInfiniteScrollView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self renderUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

#pragma mark - events


#pragma mark ---UI && data
- (void)loadData {
    _numberOfItem = [_delegate numberOfItemForInfiniteScrollView:self];
    for (NSInteger i = -1; i <= 1; i ++) {
        UIView *view = [_delegate infiniteScrollView:self itemViewForIndex:[self rectificationOffset:i]];
        [_itemArray addObject:view];
        [_scrollView addSubview:view];
    }
}

- (void)renderUI {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.controlView];
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    
    _numberOfItem = [self.delegate numberOfItemForInfiniteScrollView:self];
    
    // _itemArray中始终只有三个视图
    _itemArray = [NSMutableArray arrayWithCapacity:3];
}

- (void)updateFrame {
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.bounds) * 3, 0);
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds), 0);
    for (NSInteger i = 0; i < _itemArray.count; i ++) {
        UIView *view = _itemArray[i];
        if (view) {
            view.frame  = (CGRect){ CGRectGetWidth(_scrollView.bounds) * i ,0,view.frame.size};
        }
    }
}

- (UIView *)dequeueReusableItemView {
    return _reusableItemView;
}
- (void)reloadData {
    [_itemArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemArray removeAllObjects];
    _reusableItemView = nil;
    _offset = 0;
    [self loadData];
    for (NSInteger i = 0; i < _itemArray.count; i ++) {
        UIView *view = _itemArray[i];
        if (view) {
            view.frame  = (CGRect){ CGRectGetWidth(_scrollView.bounds) * i ,0,view.frame.size};
        }
    }
}

#pragma mark ---timer
- (void)startAutomaticScrollWithTimeInterval:(NSTimeInterval)timeInterval {
    NSAssert(timeInterval >= 1.0, @"间隔时间过短");
    __weak typeof(self) wSelf = self;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.displayLink.paused = NO;
        _controlView.center = CGPointMake(CGRectGetWidth(_scrollView.bounds) * 2, 0);
           [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
               _controlView.center = CGPointMake(CGRectGetWidth(_scrollView.bounds) , 0);
               wSelf.scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds) * 2, 0);
           } completion:^(BOOL finished) {
               _controlView.center = CGPointMake(CGRectGetWidth(_scrollView.bounds) * 2, 0);
               self.displayLink.paused = YES;
               [wSelf resetContentOffset];
           }];
    }];
}

- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}
- (void)endAutomaticScroll {
    [self invalidateTimer];
}
- (void)calculatePath {
    CALayer *layer = self.controlView.layer.presentationLayer;
    CGFloat peogress = 2 - layer.position.x/CGRectGetWidth(_scrollView.frame);
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didScrollWithItemView:progress:)]) {
        [self.delegate infiniteScrollView:self didScrollWithItemView:self.currentItem progress:peogress];
    }
    
}
#pragma mark - deleagte
#pragma mark ---UIScorllViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (!_willScrolling) {
        return;
    }
    CGFloat offset = (_scrollView.contentOffset.x - CGRectGetWidth(_scrollView.bounds))/CGRectGetWidth(_scrollView.bounds);
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didScrollWithItemView:progress:)]) {
        [self.delegate infiniteScrollView:self didScrollWithItemView:_itemArray[1] progress:[self rectificationProgress:offset]];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _willScrolling = YES;
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self resetContentOffset];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetContentOffset];
}
- (void)resetContentOffset {
    _willScrolling = NO;
    if (_scrollView.contentOffset.x >= 2.0 *CGRectGetWidth(_scrollView.bounds)) { // 向左滑动结束 
        _offset ++;
        UIView *view0 = _itemArray[1];
        view0.frame = CGRectMake(0, CGRectGetMinY(view0.frame), CGRectGetWidth(view0.bounds), CGRectGetHeight(view0.bounds));
        
        UIView *view1 = _itemArray[2];
        view1.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds), CGRectGetMinY(view1.frame), CGRectGetWidth(view1.bounds), CGRectGetHeight(view1.bounds));
        
        _reusableItemView = _itemArray[0];
        [_itemArray removeObject:_reusableItemView];
        [_reusableItemView removeFromSuperview];
        UIView *newView = [self.delegate infiniteScrollView:self itemViewForIndex:[self rectificationOffset:_offset + 1]];
        newView.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds)*2, CGRectGetMinY(newView.frame), CGRectGetWidth(newView.bounds), CGRectGetHeight(newView.bounds));
        [_scrollView addSubview:newView];
        
        _itemArray[0] = view0;
        _itemArray[1] = view1;
        _itemArray[2] = newView;
        
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds), 0);
        
    } else if (_scrollView.contentOffset.x < CGRectGetWidth(_scrollView.bounds)) { // 向右滑动结束
        _offset --;
        
        UIView *view1 = _itemArray[0];
        view1.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds), CGRectGetMinY(view1.frame), CGRectGetWidth(view1.bounds), CGRectGetHeight(view1.bounds));
        
        UIView *view2 = _itemArray[1];
        view2.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds)*2, CGRectGetMinY(view2.frame), CGRectGetWidth(view2.bounds), CGRectGetHeight(view2.bounds));
        
        _reusableItemView = _itemArray[2];
        [_itemArray removeObject:_reusableItemView];
        [_reusableItemView removeFromSuperview];
        
        UIView *newView = [self.delegate infiniteScrollView:self itemViewForIndex:[self rectificationOffset:_offset - 1]];
        newView.frame = CGRectMake(0, CGRectGetMinY(newView.frame), CGRectGetWidth(newView.bounds), CGRectGetHeight(newView.bounds));
        [_scrollView addSubview:newView];
        _itemArray[0] = newView;
        _itemArray[1] = view1;
        _itemArray[2] = view2;
        
        
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.bounds), 0);
        
        
    } else {
        
        UIView *view0 = _itemArray[0];
        view0.frame = CGRectMake(0, CGRectGetMinY(view0.frame), CGRectGetWidth(view0.bounds), CGRectGetHeight(view0.bounds));
        
        UIView *view1 = _itemArray[1];
        view1.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds), CGRectGetMinY(view1.frame), CGRectGetWidth(view1.bounds), CGRectGetHeight(view1.bounds));
        
        UIView *view2 = _itemArray[2];
        view2.frame = CGRectMake(CGRectGetWidth(_scrollView.bounds)*2, CGRectGetMinY(view2.frame), CGRectGetWidth(view2.bounds), CGRectGetHeight(view2.bounds));
    }
    
    if ([self.delegate respondsToSelector:@selector(infiniteScrollView:didEndScrollingAtIndex:)]) {
        [self.delegate infiniteScrollView:self didEndScrollingAtIndex:[self rectificationOffset:_offset]];
    }
}

#pragma mark - setter && getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}
- (void)setDelegate:(id<DDInfiniteScrollViewDelegate>)delegate {
    __weak typeof (delegate) wDelegate = delegate;
    _delegate = wDelegate;
    [self loadData];
}


- (UIView *)lastItem {
    return _itemArray[0];
}
- (UIView *)currentItem {
    return _itemArray[1];
}
- (UIView *)nextItem {
    return _itemArray[2];
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

- (UIView *)controlView {
    if (!_controlView) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _controlView.backgroundColor = [UIColor blueColor];
    }
    return _controlView;
}

#pragma mark - private method
- (NSUInteger)rectificationOffset:(NSInteger)offset {
    NSInteger index = offset%_numberOfItem;
    index = index < 0 ? index + _numberOfItem : index;
    return index;
}
- (CGFloat)rectificationProgress:(CGFloat)progress {
    CGFloat newProgress = ((NSInteger)(progress * 10000) % (_numberOfItem * 10000))/10000.0;
    return newProgress;
}
@end
