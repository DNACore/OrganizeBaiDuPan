//
//  WaitingView.m
//  OrganizeBaiDuPan
//
//  Created by ixdtech on 14/12/30.
//  Copyright (c) 2014年 Ice. All rights reserved.
//

#import "WaitingView.h"

@implementation WaitingView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     //Drawing code
    [[UIColor colorWithRed:84/255.0 green:199/255.0 blue:252/255.0 alpha:1]set];
    UIBezierPath *beaierPath=[[UIBezierPath alloc]init];
    [beaierPath addArcWithCenter:self.center
                          radius:40
                      startAngle:0
                        endAngle:3.14159265359
                       clockwise:YES];
    beaierPath.lineWidth=5.0;
    beaierPath.lineCapStyle=kCGLineCapRound;
    [beaierPath stroke];
}


@end
