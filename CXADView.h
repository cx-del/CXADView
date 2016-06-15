//
//  CXADView.h
//  常用Category
//
//  Created by Ming on 16/1/12.
//  Copyright © 2016年 戴晨惜. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPageControlStyle)
{
    UIPageControlStyleNone = 0,
    UIPageControlStyleLeft,
    UIPageControlStyleCenter,
    UIPageControlStyleRight,
};

typedef void(^CXADViewBlock)(NSInteger imageIndex);
IB_DESIGNABLE
@interface CXADView : UIView


@property (nonatomic,assign) IBInspectable BOOL isNeedStartTimer; /**<- 是否开启定时器 deful is YES */

@property (nonatomic,strong) NSArray <NSString *>* imageUrls; /**<- 图片名 数组*/

@property (nonatomic,assign) UIPageControlStyle pageControlStyle; /**<- pageControl 位置*/

/**
 *  @author CX, 2016年01月13日 - 15时01分
 *
 *  初始化
 *
 *  @param frame
 *  @param imageURLs        图片链接
 *  @param pageControlStyle UIPageControl 类型
 *
 *  @return CXADView 对象
 */
+ (CXADView *)CXADViewWithFrame:(CGRect)frame imageUrls:(NSArray <NSString *>*)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block;


- (void)setImageUrls:(NSArray<NSString *> *)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block;


@end
