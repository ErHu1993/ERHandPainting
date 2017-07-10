//
//  HandPaintViewController.m
//  ErHuDemo
//
//  Created by 胡广宇 on 2017/6/1.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import "HandPaintViewController.h"
#import "HandPaintingImageView.h"

@interface HandPaintViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) HandPaintingImageView *paintingImageView;

@property (nonatomic, strong) UIScrollView *backGroundScrollerView;

@end

@implementation HandPaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
}

- (void)setupSubViews{
    //单指手绘 ， 双指滑动图片
    [self setMaxMinZoomScalesForCurrentBounds];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
    [backBtn setTitle:@"revoke" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(revoke) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80 -  20, 20, 80, 80)];
    [saveBtn setTitle:@"save" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    UIButton *changeBtn = [[UIButton alloc] initWithFrame:CGRectMake(saveBtn.frame.origin.x, 20 + 80 + 20, 80, 80)];
    [changeBtn setTitle:@"Color" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeBtn];
}

- (void)back{
    [self.paintingImageView hp_unchoose];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save{
    if ([self.paintingImageView hp_hasStocks]) {
        [self.paintingImageView hp_drawOnImage];
    }
    
    UIImageWriteToSavedPhotosAlbum(self.paintingImageView.image,self, @selector(resultImage:didFinishSavingWithError:contextInfo:), NULL);
}

//撤销
- (void)revoke{
    if ([self.paintingImageView hp_hasStocks]) {
        [self.paintingImageView hp_undo];
    }
}

- (void)changeColor{
    UIColor *color = [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1];
    [self.paintingImageView hp_chooseWithColor:color abstractScale:self.backGroundScrollerView.zoomScale];
}

//保存至相册
- (void)resultImage:(UIImage *)resultImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"save error : %@",error);
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.paintingImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustPictureImageViewScrollFrame];
    [self layoutPaintLayer];
}

/**
 重新设置手绘放大倍数
 */
- (void)layoutPaintLayer{
    [self.paintingImageView hp_setAbsoluteScale:self.backGroundScrollerView.zoomScale];
}


/**
 调整pictureImageView位置边界
 */
- (void)adjustPictureImageViewScrollFrame{
    
    CGSize scrollerBoundsSize = self.backGroundScrollerView.bounds.size;
    
    CGRect imageViewframe = self.paintingImageView.frame;
    
    if (imageViewframe.size.width > scrollerBoundsSize.width) {
        //图宽大于屏宽
        imageViewframe.origin.x = 0;
        if (!CGRectEqualToRect(self.paintingImageView.frame, imageViewframe))
            self.paintingImageView.frame = imageViewframe;
    }else{
        //图宽小于屏宽
        self.paintingImageView.center = CGPointMake(self.backGroundScrollerView.center.x, self.paintingImageView.center.y);
    }
    
    //使图片在缩小时保持居中显示(注意:不能改变pictureImageView.origin.y,如果改变则手绘的相对位置会改变,所以这里只改变center.y保持居中)
    if (imageViewframe.size.height <= scrollerBoundsSize.height) {
        self.paintingImageView.center = CGPointMake(self.paintingImageView.center.x, self.backGroundScrollerView.center.y);
    }
    
    [self.backGroundScrollerView setContentInset:UIEdgeInsetsZero];
    [self.backGroundScrollerView setContentSize:CGSizeMake(imageViewframe.size.width, imageViewframe.size.height)];
}


/**
 设置ScrollerView缩放比
 */
- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Sizes
    CGSize boundsSize = self.backGroundScrollerView.bounds.size;
    CGSize imageSize = self.paintingImageView.frame.size;
    
    /**Scale逻辑:
     1.理解:若图尺寸大,则scale < 1 需要缩小,所以选择scroller.size / imageSize;
     2.获取最小缩放比:宽高之比,取最小值即可作为最小缩放比;
     3.获取当前的缩放比,保证"恰好"铺满全屏:宽之比与高之比都需要判断,因为要"恰好"铺满全屏展示,所以需要选择二者中最短边对应的缩放比作为currentScale,保证最短的边"恰好"铺满全屏.
     若 scale都 < 1 都需要缩小 -> 则选择数值最大的 , 若 scale都 > 1 都需要放大 -> 则选择数值最大的 若有的边 scale < 1 有的 > 1 则选择数值大的,保证铺满全屏;
     4.最大缩放比:只要保证最大缩放比比最小缩放比和当前缩放比大即可,若最大缩放比小于当前缩放比,则系统会默认最大缩放比为当前缩放比
     */
    CGFloat xScale = (CGFloat)boundsSize.width / imageSize.width;
    CGFloat yScale = (CGFloat)boundsSize.height / imageSize.height;
    
    CGFloat minScale = MIN(xScale, yScale);//取最小倍数作为 scrollerView的最小缩放倍数
    CGFloat currentScale = MAX(xScale, yScale);
    CGFloat maxScale = minScale * 4 < currentScale ? currentScale * 2 : minScale * 4;
    
    self.backGroundScrollerView.maximumZoomScale = maxScale;
    self.backGroundScrollerView.minimumZoomScale = minScale;
    self.backGroundScrollerView.zoomScale = currentScale;
    
    [self adjustPictureImageViewScrollFrame];
}


#pragma mark - getter/setter

- (HandPaintingImageView *)paintingImageView {
    if (!_paintingImageView) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WechatIMG" ofType:@"jpeg"]];
        NSAssert(image,@"必须有图片");
        CGSize imageSize = image.size;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = imageSize.height / imageSize.width * width;
        _paintingImageView = [[HandPaintingImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _paintingImageView.image = image;
        [_paintingImageView hp_initWidthInMM:2.5];
        [_paintingImageView hp_chooseWithColor:[UIColor blueColor] abstractScale:self.backGroundScrollerView.zoomScale];
    }
    return _paintingImageView;
}

- (UIScrollView *)backGroundScrollerView {
    if (!_backGroundScrollerView) {
        _backGroundScrollerView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _backGroundScrollerView.backgroundColor = [UIColor whiteColor];
        _backGroundScrollerView.delegate = self;
        _backGroundScrollerView.showsHorizontalScrollIndicator = NO;
        _backGroundScrollerView.showsVerticalScrollIndicator = NO;
        _backGroundScrollerView.delaysContentTouches = false;
        _backGroundScrollerView.decelerationRate = UIScrollViewDecelerationRateFast;
        _backGroundScrollerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_backGroundScrollerView addSubview:self.paintingImageView];
        _backGroundScrollerView.panGestureRecognizer.minimumNumberOfTouches = 2;
        [self.view addSubview:_backGroundScrollerView];
    }
    return _backGroundScrollerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
