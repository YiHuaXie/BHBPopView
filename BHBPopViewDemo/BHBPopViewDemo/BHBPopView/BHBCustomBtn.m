//
//  BHBCustomBtn.m
//  BHBPopViewDemo
//
//  Created by 毕洪博 on 15/8/15.
//  Copyright (c) 2015年 毕洪博. All rights reserved.
//

#import "BHBCustomBtn.h"

@implementation BHBCustomBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, 0, contentRect.size.width, ICONHEIGHT);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, ICONHEIGHT + 10, contentRect.size.width, TITLEHEIGHT);
}

- (void)dealloc{
//    NSLog(@"BHBCustomBtn");
}

@end
