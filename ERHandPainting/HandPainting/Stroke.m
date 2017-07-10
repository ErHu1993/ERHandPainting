//
//  Stroke.m
//  ErHuDemo
//
//  Created by 胡广宇 on 2017/6/2.
//  Copyright © 2017年 胡广宇. All rights reserved.
//

#import "Stroke.h"

@interface Stroke ()

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat width;

@end

@implementation Stroke{
    NSMutableArray *_points;
    CGFloat DD;
}

- (instancetype)initWithColor:(UIColor *)color width:(CGFloat)width{
    if (self = [super init]) {
        
        _points = [NSMutableArray array];
        
        DD = 3.0 / [UIScreen mainScreen].scale;
        
        self.color = color;
        self.width = width;
    }
    return self;
}

- (void)pass:(CGPoint)point{
    if (!_points.count) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        }
        
        self.path = [UIBezierPath bezierPath];
        self.path.lineWidth = self.width;
        self.path.lineCapStyle = kCGLineCapRound;
        self.path.lineJoinStyle = kCGLineJoinRound;
        [self.path moveToPoint:point];
        [self.path addLineToPoint:point];
        [_points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    CGPoint last = [_points.lastObject CGPointValue];
    NSInteger dx = ABS(point.x - last.x);
    NSInteger dy = ABS(point.y - last.y);
    
    if (dx >= DD || dy >= DD ) {
        [self.path addQuadCurveToPoint:CGPointMake((point.x + last.x) / 2, (point.y + last.y) / 2) controlPoint:last];
        [_points addObject:[NSValue valueWithCGPoint:point]];
    }
}

- (void)draw{
    if (self.path) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        }
        [self.path stroke];
    }
}

@end
