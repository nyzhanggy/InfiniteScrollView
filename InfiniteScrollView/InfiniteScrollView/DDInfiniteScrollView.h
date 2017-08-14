//
//  DDInfiniteScrollView.h


#import <UIKit/UIKit.h>
@class DDInfiniteScrollView;
@protocol DDInfiniteScrollViewDelegate <NSObject>

- (UIView *)infiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView itemViewForIndex:(NSInteger)index;
- (NSInteger)numberOfItemForInfiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView;

@optional
- (void)infiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView didEndScrollingAtIndex:(NSInteger)index;
- (void)infiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView didScrollWithItemView:(__kindof UIView *)itemView progress:(CGFloat)progress;

@end

@interface DDInfiniteScrollView : UIView
@property (nonatomic, weak) id<DDInfiniteScrollViewDelegate> delegate;
@property (nonatomic, strong,readonly) __kindof UIView *lastItem;
@property (nonatomic, strong,readonly) __kindof UIView *currentItem;
@property (nonatomic, strong,readonly) __kindof UIView *nextItem;

- (__kindof UIView *)dequeueReusableItemView;
- (void)reloadData;
- (void)startAutomaticScrollWithTimeInterval:(NSTimeInterval)timeInterval;
- (void)endAutomaticScroll;
@end
