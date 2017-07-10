# ERHandPainting

## 在imageView上进行手绘
![](http://upload-images.jianshu.io/upload_images/2773241-d175888444283b95.gif?imageMogr2/auto-orient/strip)

## 使用方法:

#### ``` pod 'ERHandPainting' ```

#### ``` #import <ERHandPainting/HandPaintingImageView.h> ```

#### 创建一个HandPaintingImageView 
``` @property (nonatomic, strong) HandPaintingImageView *paintingImageView; ```

#### 初始化并赋值Image后,再初始化画笔
```
[_paintingImageView hp_initWidthInMM:2.5];//初始化画笔宽度
[_paintingImageView hp_chooseWithColor:[UIColor blueColor] abstractScale:self.backGroundScrollerView.zoomScale];//选中颜色和放大倍数(一般用于和UIScrollerView混合用,如果没有直接传1.0)

```

#### 提供以下方法供调用

```
/**
 只需调用一次，必须先设置Image（重要），

 @param widthInMM 标注的宽度，单位毫米
 */
- (void)hp_initWidthInMM:(double)widthInMM;


/**
 绘图时选中某种颜色

 @param color color
 @param abstractScale 当前缩放倍数，默认1.0
 */
- (void)hp_chooseWithColor:(UIColor *)color abstractScale:(CGFloat)abstractScale;

/**
 当图片缩放比发生变化时，传入绝对的缩放比

 @param scale 当前缩放倍数
 */
- (void)hp_setAbsoluteScale:(CGFloat)scale;

/**
 离开绘图页面时取消选中颜色
 */
- (void)hp_unchoose;

/**
 撤销绘图
 */
- (void)hp_undo;

/**
 是否进行过标注(用于结束时判断是否需要将标注draw到image上)

 @return bool
 */
- (BOOL)hp_hasStocks;

/**
 标注过的图片需要通过此方法将标注与原图混合
 */
- (void)hp_drawOnImage;
```


