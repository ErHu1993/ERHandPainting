//
//  Stroke.h
//  ErHuDemo
//
//  Created by 胡广宇 on 2017/6/2.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Stroke : NSObject
// 笔画经过的点
@property (nonatomic, strong ,readonly) NSMutableArray *points;
// 缓存的创建好的贝塞尔曲线
@property (nonatomic, strong) UIBezierPath *path;

- (instancetype)initWithColor:(UIColor *)color width:(CGFloat)width;

- (void)pass:(CGPoint)point;

- (void)draw;

@end
