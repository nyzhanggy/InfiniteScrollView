//
//  ViewController.m

#import "ViewController.h"
#import "DDInfiniteScrollView.h"
#import "DDOffsetAnimationView.h"

@interface ViewController ()<DDInfiniteScrollViewDelegate>
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) DDInfiniteScrollView *infiniteScrollView;
@property (nonatomic, strong) UIButton *startButton;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"banner";
    self.automaticallyAdjustsScrollViewInsets = NO;
    _images = @[@"bg.jpg",@"大海.jpg",@"高山.jpg",@"森林.jpg",@"天空.jpg"];
    
    [self.view addSubview:self.infiniteScrollView];
    [self.view addSubview:self.startButton];
    
}
- (void)startInfiniteScrollView {
    if ([_startButton.titleLabel.text isEqualToString:@"开始"]) {
        [_infiniteScrollView startAutomaticScrollWithTimeInterval:2];
        [_startButton setTitle:@"结束" forState:UIControlStateNormal];
    } else {
        [_startButton setTitle:@"开始" forState:UIControlStateNormal];
        [_infiniteScrollView endAutomaticScroll];
    }
}
- (UIView *)infiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView itemViewForIndex:(NSInteger)index {
    DDOffsetAnimationView *itemView = [infiniteScrollView dequeueReusableItemView];
    
    if (!itemView) {
        itemView = [[DDOffsetAnimationView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 40, 120)];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        itemView.contentView = imageView;
    }
    itemView.contentView.frame = itemView.bounds;
    ((UIImageView *)itemView.contentView).image = [UIImage imageNamed:_images[index]];
    return itemView;
}
- (NSInteger)numberOfItemForInfiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView {
    return _images.count;
}

- (void)infiniteScrollView:(DDInfiniteScrollView *)infiniteScrollView didScrollWithItemView:(__kindof UIView *)itemView progress:(CGFloat)progress {
    [(DDOffsetAnimationView *)itemView updateWithProgress:progress];
    if (progress > 0) {
        [(DDOffsetAnimationView *)_infiniteScrollView.nextItem updateWithProgress:progress - 1];
    } else {
        [(DDOffsetAnimationView *)_infiniteScrollView.lastItem updateWithProgress:progress + 1];
    }
}

#pragma mark - setter && getter
- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startButton.frame = CGRectMake(60, 220, CGRectGetWidth(self.view.bounds) - 120, 44);
        [_startButton setTitle:@"开始" forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(startInfiniteScrollView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}
- (DDInfiniteScrollView *)infiniteScrollView {
    if (!_infiniteScrollView) {
         _infiniteScrollView = [[DDInfiniteScrollView alloc] initWithFrame:CGRectMake(20, 80, CGRectGetWidth(self.view.bounds) - 40, 120)];
         _infiniteScrollView.delegate = self;
    }
    return _infiniteScrollView;
}
@end
