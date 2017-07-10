//
//  HandPaintingImageView.m
//  ErHuDemo
//
//  Created by 胡广宇 on 2017/6/2.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import "HandPaintingImageView.h"
#import "Stroke.h"

#ifndef nob_defer_h
#define nob_defer_h

// some helper declarations
#define _nob_macro_concat(a, b) a##b
#define nob_macro_concat(a, b) _nob_macro_concat(a, b)
typedef void(^nob_defer_block_t)();
NS_INLINE void nob_deferFunc(__strong nob_defer_block_t *blockRef)
{
    nob_defer_block_t actualBlock = *blockRef;
    actualBlock();
}

// the core macro
#define nob_defer(deferBlock) \
__strong nob_defer_block_t nob_macro_concat(__nob_stack_defer_block_, __LINE__) __attribute__((cleanup(nob_deferFunc), unused)) = deferBlock

#endif /* nob_defer_h */

@interface PanWithStartGestureRecognizer : UIPanGestureRecognizer
// 开始点击的点位
@property (nonatomic, assign) CGPoint start;
// 拖动后的点位
@property (nonatomic, assign) CGPoint point;

@end

@implementation PanWithStartGestureRecognizer

@end

@interface TapWithStartGestureRecognizer : UITapGestureRecognizer
// 开始点击的点位
@property (nonatomic, assign) CGPoint start;

@end

@implementation TapWithStartGestureRecognizer

@end

@interface HandPainting : NSObject<CALayerDelegate>

@property (nonatomic, strong) NSMutableArray<Stroke *>* redoList;

@property (nonatomic, strong) NSMutableArray<Stroke *>* strokes;

@property (nonatomic, strong) PanWithStartGestureRecognizer *pan;

@property (nonatomic, strong) TapWithStartGestureRecognizer *tap;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) double widthInMM;

@property (nonatomic, strong) Stroke *currentStroke;

@property (nonatomic, strong) CALayer *drawLayer;

@property (nonatomic, strong) UIColor *currColor;

@property (nonatomic, assign) CGFloat currScale;

@property (nonatomic, assign) CGFloat abstractScale;


- (instancetype)initWithImageView:(UIImageView *)imageView widthInMM:(double)widthInMM;

@end

@implementation HandPainting

- (instancetype)initWithImageView:(UIImageView *)imageView widthInMM:(double)widthInMM{
    if (self = [super init]) {
        
        self.imageView = imageView;
        self.widthInMM = widthInMM;
        
        self.redoList = [NSMutableArray array];
        self.strokes = [NSMutableArray array];
        self.currColor = [UIColor redColor];
        self.currScale = 1.0;
        self.abstractScale = 1.0;
        
        self.pan = [[PanWithStartGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        self.pan.maximumNumberOfTouches = 1;
        
        self.tap = [[TapWithStartGestureRecognizer alloc] initWithTarget:self action:@selector(tapping:)];
        
        [self.tap requireGestureRecognizerToFail:self.pan];
        
        self.pan.cancelsTouchesInView = false;//重要
    }
    return self;
}

#pragma mark - 行为识别回调

//行为识别回调
- (void)dragging:(PanWithStartGestureRecognizer *)p{
    switch (p.state) {
        case UIGestureRecognizerStateChanged:
        {
            if (!self.currentStroke) {
                self.currentStroke = [[Stroke alloc] initWithColor:self.currColor width:[self mm2pt:self.widthInMM] / self.currScale / self.abstractScale];
            }
            
            if (!self.currentStroke.points.count) {
                // 将所画点的坐标按比例缩放
                CGPoint np = [self.drawLayer convertPoint:p.start fromLayer:self.imageView.layer];
                [self.currentStroke pass:CGPointMake(np.x / self.currScale, np.y / self.currScale)];
            }
            
            CGPoint np = [self.drawLayer convertPoint:p.point fromLayer:self.imageView.layer];
            // 将所画点的坐标按比例缩放
            [self.currentStroke pass:CGPointMake(np.x / self.currScale, np.y / self.currScale)];
            [self.drawLayer setNeedsDisplay];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (!self.currentStroke) {
                self.currentStroke = [[Stroke alloc] initWithColor:self.currColor width:[self mm2pt:self.widthInMM] / self.currScale / self.abstractScale];
            }
            // 无论是结束还是取消， 都算绘制成功
            CGPoint np = [self.drawLayer convertPoint:p.point fromLayer:self.imageView.layer];
            [self.currentStroke pass:CGPointMake(np.x / self.currScale, np.y / self.currScale)];
            [self.strokes addObject:self.currentStroke];
            self.currentStroke = nil;
            [self.drawLayer setNeedsDisplay];
        }
            break;
        default:
            break;
    }
}

- (void)tapping:(TapWithStartGestureRecognizer *)p{
    switch (p.state) {
        case UIGestureRecognizerStateEnded:
        {
            if (!self.currentStroke) {
                self.currentStroke = [[Stroke alloc] initWithColor:self.currColor width:[self mm2pt:self.widthInMM] / self.currScale / self.abstractScale];
            }
            CGPoint np = [self.drawLayer convertPoint:p.start fromLayer:self.imageView.layer];
            [self.currentStroke pass:CGPointMake(np.x / self.currScale, np.y / self.currScale)];
            [self.strokes addObject:self.currentStroke];
            self.currentStroke = nil;
            [self.drawLayer setNeedsDisplay];
        }
            break;
        default:
            break;
    }
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    UIGraphicsPushContext(ctx);
    
    nob_defer(^{
        UIGraphicsPopContext();
    });
    
    CGContextScaleCTM(ctx, self.currScale, self.currScale);
    [self drawStockes];
}

- (void)drawStockes{
    [self drawInit];
    for (Stroke *storke in self.strokes) {
        [storke draw];
    }
    
    if (self.currentStroke && self.currentStroke.points.count) {
        [self.currentStroke draw];
    }
}

- (void)drawInit{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsFontSmoothing(context, true);
        CGContextSetShouldSmoothFonts(context, true);
    }
}

- (void)reset4Painting{
    CGFloat width = self.imageView.image.size.width;
    CGFloat height = self.imageView.image.size.height;
    
    // 检测纵向填满
    CGFloat newHeight = self.imageView.layer.bounds.size.height;
    CGFloat newWidth = width * self.imageView.layer.bounds.size.height / height;
    
    if (newWidth > self.imageView.layer.bounds.size.width) {
        // 检测横向填满
        newHeight = height * self.imageView.layer.bounds.size.width / width;
        newWidth = self.imageView.layer.bounds.size.width;
    }
    
    self.currScale = newWidth / width;
    
    [self skipAnimation:^{
        self.drawLayer.contentsScale = self.abstractScale * [UIScreen mainScreen].scale;
        self.drawLayer.position = CGPointMake(CGRectGetMidX(self.imageView.layer.bounds), CGRectGetMidY(self.imageView.layer.bounds));
        self.drawLayer.bounds = CGRectMake(0, 0, newWidth, newHeight);
    }];
    [self.drawLayer setNeedsDisplay];
}

- (void)setAbsoluteScale:(CGFloat)scale{
    self.abstractScale = scale;
}

#pragma mark - 扩展方法

//毫米转PT
- (CGFloat)mm2pt:(double)mm{
    
    /// 英寸比毫米
    static CGFloat MM_PER_IN = 25.4;
    /// PT比英寸
    static CGFloat PT_PRE_IN = 72.0;
    
    return (mm / MM_PER_IN * PT_PRE_IN);
}

- (void)skipAnimation:(void (^)())completion{
    [CATransaction begin];
    nob_defer(^{
        [CATransaction commit];
    });
    [CATransaction setDisableActions:true];
    if (completion) {
        completion();
    }
}

@end

@interface HandPaintingImageView ()

@property (nonatomic, strong) HandPainting *handPating;

@end

@implementation HandPaintingImageView

- (void)hp_initWidthInMM:(double)widthInMM{
    
    self.userInteractionEnabled = true;
    self.clipsToBounds = true;
    
    self.handPating = [[HandPainting alloc] initWithImageView:self widthInMM:widthInMM];
    CALayer *drawLayer = [[CALayer alloc] init];
    drawLayer.delegate = self.handPating;
    self.handPating.drawLayer = drawLayer;
    [self.layer addSublayer:self.handPating.drawLayer];
    [self.handPating reset4Painting];
}

// 进入绘图页面时选中某种颜色
- (void)hp_chooseWithColor:(UIColor *)color abstractScale:(CGFloat)abstractScale{
    if (self.handPating) {
        [self removeGestureRecognizer:self.handPating.pan];
        [self removeGestureRecognizer:self.handPating.tap];
        [self addGestureRecognizer:self.handPating.pan];
        [self addGestureRecognizer:self.handPating.tap];
        self.handPating.currColor = color;
        [self.handPating setAbsoluteScale:abstractScale];
    }
}
// 离开绘图页面时取消选中某种颜色
- (void)hp_unchoose{
    if (self.handPating) {
        [self removeGestureRecognizer:self.handPating.pan];
        [self removeGestureRecognizer:self.handPating.tap];
    }
}

// 撤销绘图
- (void)hp_undo{
    if (self.handPating && self.handPating.strokes.count) {
        [self.handPating.redoList addObject:self.handPating.strokes.lastObject];
        [self.handPating.strokes removeLastObject];
        [self.handPating reset4Painting];
    }
}
// 是否进行过标注
- (BOOL)hp_hasStocks{
    return self.handPating && self.handPating.strokes.count;
}

// 标注过的图片需要通过此方法将标注与原图混合
- (void)hp_drawOnImage{
    if (self.handPating && self.handPating.strokes.count){
        CGSize size = CGSizeMake(self.image.size.width, self.image.size.height);
        UIImage *flipImage = [self flip:self.image.CGImage size:size opaque:true scale:1];
        self.image = [self imageOf:size opaque:true scale:1 completion:^{
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), flipImage.CGImage);
            [self.handPating drawStockes];
        }];
        [self.handPating.strokes removeAllObjects];
        [self.handPating reset4Painting];
    }
}

// 重新计算缩放比等绘制参数
- (void)hp_reset4Painting{
    if (self.handPating) {
        [self.handPating reset4Painting];
    }
}

// 传入绝对的缩放比
- (void)hp_setAbsoluteScale:(CGFloat)scale{
    if (self.handPating) {
        [self.handPating setAbsoluteScale:scale];
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [self hp_reset4Painting];
    [super layoutSublayersOfLayer:layer];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    self.handPating.pan.start = [self.handPating.pan locationInView:self];
    self.handPating.pan.point = self.handPating.pan.start;
    
    self.handPating.tap.start = [self.handPating.tap locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    self.handPating.pan.point = [self.handPating.pan locationInView:self];
}


- (UIImage *)imageOf:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale completion:(void (^)())completion{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 10) {
        UIGraphicsImageRendererFormat *f = [UIGraphicsImageRendererFormat defaultFormat];
        f.opaque = opaque;
        if (scale > 0) {
            f.scale = scale;
        }
        UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:size format:f];
        return [r imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            if (completion) {
                completion();
            }
        }];
    }else{
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        nob_defer(^{
            UIGraphicsEndImageContext();
        });
        if (completion) {
            completion();
        }
        return UIGraphicsGetImageFromCurrentImageContext();
    }
}

- (UIImage *)flip:(CGImageRef)im size:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale{
    return [self imageOf:size opaque:opaque scale:scale completion:^{
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height), im);
    }];
}
@end
