# CXADView

 这是一个 iOS 通用滚动广告视图

用法：1、如果你用的是SB或者XIB 需要调用 - (void)setImageUrls:(NSArray<NSString *> *)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block;
来设置图片名称 pageControl类型等属性，回调采用Block；

    2、如果你用的是代码，需要调用 + (CXADView *)CXADViewWithFrame:(CGRect)frame imageUrls:(NSArray <NSString *>*)imageUrls pageControlStyle:(UIPageControlStyle )pageControlStyle CXADViewBlock:(CXADViewBlock)block;
来设置图片Rect、名称、pageControl类型等属性，回调同样采用Block；