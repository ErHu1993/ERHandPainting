//
//  HandPaintingImageView.h
//  ErHuDemo
//
//  Created by 胡广宇 on 2017/6/2.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HandPaintingImageView : UIImageView

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
@end
