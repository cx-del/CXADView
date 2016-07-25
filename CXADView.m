//
//  CXADView.m
//  常用Category
//
//  Created by Ming on 16/1/12.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import "CXADView.h"
#import "Foundation_DCX.h"

@interface CXADView()<UIScrollViewDelegate>
{
    NSInteger _imageViewSelectIndex[3];
    
}

@property (nonatomic,copy) CXADViewBlock block;
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong) UIPageControl * pageControl;
@property (nonatomic,assign) NSTimer * timer; /**<- 定时器*/

@property (nonatomic,strong) UIImageView * leftImageView;
@property (nonatomic,strong) UIImageView * centerImageView;
@property (nonatomic,strong) UIImageView * rightImageView;

@property (nonatomic,assign) BOOL isInitTimer; /**<- 定时器是否开启*/

@end

NSInteger kMoveInterval = 3.f; /**<- 定时器触发间隔*/
CGFloat KPageControlHeight = 20.f; /**<- pageControl 高度*/

@implementation CXADView

- (instancetype )initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        self.isNeedStartTimer = YES; /**<- 默认开启定时器*/
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        self.isNeedStartTimer = YES; /**<- 默认开启定时器*/
    }
    return self;
}
 /**<- 初始化 滚动视图*/
- (UIScrollView *)scrollView {

    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.bounces = NO;  /**<- 取消弹性*/
        _scrollView.delegate = self; /**<- 设置代理*/
        _scrollView.pagingEnabled = YES; /**<- 分页*/
        _scrollView.backgroundColor = [UIColor whiteColor]; /**<- 设置背景色*/
        _scrollView.showsVerticalScrollIndicator = NO; /**<- 取消垂直滚动条显示*/
        _scrollView.showsHorizontalScrollIndicator = NO; /**<- 取消水平滚动条显示*/
        
        _scrollView.contentOffset = CGPointMake(_scrollView.width, 0.); /**<- 设置初始偏移量 一个宽度*/
        _scrollView.contentSize = CGSizeMake(_scrollView.width * 3, _scrollView.height); /**<- 设置滚动范围 宽度X3 */
        
        _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.width, _scrollView.height)];
        [_scrollView addSubview:_leftImageView]; /**<- 添加左 imageView*/
        
        _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollView.width, 0, _scrollView.width, _scrollView.height)];
        _centerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [_centerImageView addGestureRecognizer:singleTap]; /**<- centerImageView 添加点击事件*/
        [_scrollView addSubview:_centerImageView]; /**<- 添加中心 imageView*/
        
        _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_scrollView.width * 2, 0, _scrollView.width, _scrollView.height)];
        [_scrollView addSubview:_rightImageView];/**<- 添加右 imageView*/
    }
    return _scrollView;
}

 /**<- 懒加载 pageControl*/
- (UIPageControl *)pageControl {

    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectZero];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 0;
        _pageControl.enabled = NO;    }
    return _pageControl;
}

+ (CXADView *)CXADViewWithFrame:(CGRect )frame imageUrls:(NSArray <NSString *>*)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block{
    
    CXADView * cxADView = [[CXADView alloc]initWithFrame:frame];
    [cxADView setImageUrls:imageUrls pageControlStyle:pageControlStyle CXADViewBlock:block];
    return cxADView;
}

- (void)setImageUrls:(NSArray<NSString *> *)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block {
    
    CXAssert_true(imageUrls.count == 0, @"图片链接地址数目不可为零");

    self.imageUrls = imageUrls;
    self.pageControlStyle = pageControlStyle;
    if (block) {
        self.block = block;
    }
}

 /**<- 初始化图片*/
- (void)setImageUrls:(NSArray<NSString *> *)imageUrls {

    if (imageUrls.count == 1) {
        _scrollView.scrollEnabled = NO;  /**<- 一张图片 不可滑动*/
    }
    _imageUrls = imageUrls;
    _imageViewSelectIndex[0] = imageUrls.count - 1;  /**<- 最后一个字符串的索引*/
    _imageViewSelectIndex[1] = 0;
    _imageViewSelectIndex[2] = 1;
    [self setimageView];
    
     /**<- 确保定时器开启 */
    if (self.superview && self.isNeedStartTimer && !_isInitTimer) {
        [self initTimer];
    }
    
}
 /**<- 设置 pageControl 位置类型*/
- (void)setPageControlStyle:(UIPageControlStyle)pageControlStyle {
    _pageControlStyle = pageControlStyle;

    if (_pageControlStyle != UIPageControlStyleNone || _imageUrls.count >1) {
        _pageControl.bounds = CGRectMake(0, 0, 20 * _imageUrls.count, KPageControlHeight);
        _pageControl.bottom = _scrollView.height;
        _pageControl.numberOfPages = _imageUrls.count;
        switch (_pageControlStyle) {
            case UIPageControlStyleCenter:
            {
                _pageControl.centerX = _scrollView.centerX;
            }
                break;
            case UIPageControlStyleLeft:
            {
                _pageControl.left = 0.f;
            }
                break;
            case UIPageControlStyleRight:
            {
                _pageControl.right = _scrollView.width;
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - **************** UIScrollViewDelegate ****************

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];  /**<- 拖动时停止定时器*/
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self initTimer]; /**<- 拖动结束，开启定时器*/
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
     /**<- 滚动到左边到边*/
    if (_scrollView.contentOffset.x == 0) {
        _imageViewSelectIndex[0] = [self indexOfLContent:_imageViewSelectIndex[0]];
        _imageViewSelectIndex[1] = [self indexOfLContent:_imageViewSelectIndex[1]];
        _imageViewSelectIndex[2] = [self indexOfLContent:_imageViewSelectIndex[2]];
    }else if (_scrollView.contentOffset.x == _scrollView.width * 2) { /**<- 滚动到右边到边*/
        _imageViewSelectIndex[0] = [self indexOfRContent:_imageViewSelectIndex[0]];
        _imageViewSelectIndex[1] = [self indexOfRContent:_imageViewSelectIndex[1]];
        _imageViewSelectIndex[2] = [self indexOfRContent:_imageViewSelectIndex[2]];
    }else{
        return;
    }
    [self setimageView];
    [_pageControl setCurrentPage:_imageViewSelectIndex[1]];
}
- (NSInteger)indexOfRContent:(NSInteger)index {
    return index + 1 == _imageUrls.count ? 0 : index + 1;
}
- (NSInteger)indexOfLContent:(NSInteger)index {
    return index == 0 ? _imageUrls.count - 1 : index - 1;
}
- (void)setimageView {
    _leftImageView.image    = [UIImage imageNamed:_imageUrls[_imageViewSelectIndex[0]]];
    _centerImageView.image  = [UIImage imageNamed:_imageUrls[_imageViewSelectIndex[1]]];
    _rightImageView.image   = [UIImage imageNamed:_imageUrls[_imageViewSelectIndex[2]]];
    _scrollView.contentOffset = CGPointMake(_scrollView.width, 0);
}

#pragma mark - **************** 定时器操作处理 ****************
 /**<- 这个方法会在子视图添加到父视图或者离开父视图后调用 -> 此时开启定时器，视图必定存在 */
- (void)didMoveToSuperview {
    [self initTimer];
}

 /**<- 这个方法会在子视图添加到父视图或者离开父视图时调用 -> 判断父视图是否存在，if NO 则取消定时器 解决强引用无法删除定时器*/
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopTimer];
    }
}
 /**<- 初始化定时器操作*/
- (void)initTimer {
    if (_isNeedStartTimer && _imageUrls.count>=2 && !_isInitTimer) {
        _isInitTimer = YES;
        _timer = [NSTimer scheduledTimerWithTimeInterval:kMoveInterval target:self selector:@selector(imageMove) userInfo:nil repeats:YES];
    }
}

 /**<- 注销定时器*/
- (void)stopTimer {
    [self.timer invalidate];
    _isInitTimer = NO;
    _timer = nil;
}

 /**<- 定时器触发方法*/
- (void)imageMove {
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * 2, 0) animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(scrollViewDidEndDecelerating:) userInfo:nil repeats:NO];
}

#pragma mark - **************** 图片点击事件触发 ****************
- (void)imageTap:(UIImageView *)imageView {
    self.block(_imageViewSelectIndex[1]);
}


@end
