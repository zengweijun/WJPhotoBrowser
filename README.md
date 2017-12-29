
# WJPhotoBrowser
* An easy way to browse image
* 用法简单的图片浏览器，可以浏览网络图片和本地图片

* 内部使用UICollectionView实现，摒弃一般第三方常用的scrollView添加子视图循环利用的方式，滑动流畅无比。个人比较信任苹果的工程师，因此觉得collection view 实现方式性能更好。

##Animation Display
![fade](https://github.com/ZengWeiJun/Resource/blob/master/WJPhotoBrowser/1.gif)

## Contents
* Getting Started
    * [System 【iOS7+】]

## Installation
    * cocoapods导入：`pod 'WJPhotoBrowser'` 
    * 手动导入：将`WJPhotoBrowser`文件夹中的所有文件拽入项目中

## Usage
## 使用介绍:步骤1、2、3、4为必须实现的步骤(对照Demo)
```
    // 1.请在此处构造数据源,数据源需遵循 'WJPhotoItem' 协议
    NSMutableArray<id<WJPhotoItem>> *photos = [NSMutableArray<id<WJPhotoItem>> array];
    [imageViews enumerateObjectsUsingBlock:^(UIImageView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WJPhoto *photo = [WJPhoto new];
        photo.sourceImageView = obj;
        // Set your other properties
        // ...
        [photos addObject:photo];
    }];
```

```
    // 2.展示大图
    wj_weakify(self)
    WJPhotoBrowser *browser = [WJPhotoBrowser show:photos currentIndex:currentIndex].loadImageCb(^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImageView *imageView, void(^loadFinished)(NSUInteger atIndex, UIImage *image)){
        // __strong __typeof(&*ws) sf = ws;

        // 3.加载图片(选择各自模块的加载方式)。eg.
        WJPhoto *photo = theBrowser.photos[atIndex];

        // 4.加载完成后请回调(网络or本地)
        loadFinished(atIndex, photo.sourceImageView.image);

    }).longPressCb(^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image){
        wj_strongify(self)
        // 长按图片手势回调
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"保存图片");
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:NULL];
    }).didDismissCb(^{
        // __strong __typeof(&*ws) sf = ws;

        // 图片浏览器销毁回调
    });
```

```
    // 5.自定义底部条
    [browser setSetupToolBar:^UIView *(WJPhotoBrowser *theBrowser, UIView *spuerView) {
        if (theBrowser.photos.count <= 1) {
            return nil;
        }
        CGFloat pageControlW = 200;
        CGFloat pageControlH = 20;
        CGFloat pageControlX = ([UIScreen mainScreen].bounds.size.width - pageControlW)*0.5;
        CGFloat pageControlY = [UIScreen mainScreen].bounds.size.height - pageControlH - 20;
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(pageControlX, pageControlY, pageControlW, pageControlH)];
        pageControl.numberOfPages = theBrowser.photos.count;
        pageControl.currentPage = theBrowser.currentIndex;
        pageControl.userInteractionEnabled = NO;
        [spuerView addSubview:pageControl];
        return pageControl;
    }];
    
    [browser setPageDidChangeToIndex:^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image) {
        UIPageControl *pageControl = (UIPageControl *)theBrowser.toolBar;
        pageControl.currentPage = atIndex;
    }];
```

```
    // 6自定义顶部条
    [browser setSetupNavBar:^UIView *(WJPhotoBrowser *theBrowser, UIView *superView) {
        // custom the view and return it
        return nil;
    }];
```

## Demo
    *如果Demo报错无法运行，打开终端cd到该项目Example文件夹，更新pod，使用命令运行`$pod install` 或者 `$pod update`

## License
WJPhotoBrowser is released under the MIT license. See LICENSE for details.
