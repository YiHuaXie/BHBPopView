//
//  BHBCenterView.m
//  BHBPopViewDemo
//
//  Created by 毕洪博 on 15/8/15.
//  Copyright (c) 2015年 毕洪博. All rights reserved.
//

#import "BHBCenterView.h"
#import "BHBCustomBtn.h"
#import "UIButton+BHBSetImage.h"
#import "BHBItem.h"
#import "UIView+BHBAnimation.h"

@interface BHBCenterView ()

@property (nonatomic,strong) NSMutableArray * visableBtnArray;
@property (nonatomic,strong) NSMutableArray * homeBtns;
@property (nonatomic,assign) BOOL btnCanceled;

@end

@implementation BHBCenterView
@dynamic delegate;

-(NSMutableArray *)homeBtns
{
    if (!_homeBtns) {
        _homeBtns = [NSMutableArray array];
    }
    return _homeBtns;
}

-(NSMutableArray *)visableBtnArray
{
    if (!_visableBtnArray) {
        _visableBtnArray = [NSMutableArray array];
    }
    return _visableBtnArray;
}

//- (NSMutableArray *)moreBtns{
//    if (!_moreBtns) {
//        _moreBtns = [[NSMutableArray alloc] init];
//    }
//    return _moreBtns;
//}

- (void)reloadData{
    //    NSAssert(self.delegate, @"BHBCenterView`s delegate was nil.");
    NSAssert(self.dataSource, @"BHBCenterView`s dataSource was nil.");
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfItemsWithCenterView:)], @"BHBCenterView`s was unimplementation numberOfItemsWithCenterView:.");
    NSAssert([self.dataSource respondsToSelector:@selector(itemWithCenterView:item:)], @"BHBCenterView`s was unimplementation itemWithCenterView:item:.");
    [self.homeBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.moreBtns makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.homeBtns removeAllObjects];
//    [self.moreBtns removeAllObjects];
    NSUInteger count = [self.dataSource numberOfItemsWithCenterView:self];
    NSMutableArray * items = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        [items addObject:[self.dataSource itemWithCenterView:self item:i]];
    }
    [self layoutBtnsWith:items isMore:NO];
    [self btnPositonAnimation:NO];
}

- (void)layoutBtnsWith:(NSArray *)items isMore:(BOOL)isMore{
//    if(isMore){
//        [self.moreBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        [self.moreBtns removeAllObjects];
//    }
    BHBItem *item;
    for (int i = 0; i < items.count; i ++) {
        item = items[i];
        BHBCustomBtn * btn = [BHBCustomBtn buttonWithType:UIButtonTypeCustom];
        [btn bhb_setImage:[NSString stringWithFormat:@"%@",item.icon]];
        [btn.imageView setContentMode:UIViewContentModeCenter];
        [btn setTitle:item.title forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[UIColor colorWithRed:17 / 255.0 green:19 / 255.0 blue:56 / 255.0 alpha:1] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        CGFloat w = self.frame.size.width / 3.0;
        CGFloat h = 78.0;
        CGFloat x = (i % 3) * w;
        CGFloat y = (i / 3) * (h + 20.0);
        
        if (isMore) { x += [UIScreen mainScreen].bounds.size.width; }
        [self.homeBtns addObject:btn];
        
        btn.frame = CGRectMake(x, y, w, h);
        [btn addTarget:self action:@selector(didClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(didTouchBtn:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(didCancelBtn:) forControlEvents:UIControlEventTouchDragInside];
        [self addSubview:btn];
    }
}

- (void)didTouchBtn:(BHBCustomBtn *)btn{
    [btn scalingWithTime:.15 andscal:1.2];
}

- (void)didCancelBtn:(BHBCustomBtn *)btn{
    self.btnCanceled = YES;
    [btn scalingWithTime:.15 andscal:1];
}

- (void)scrollBack{
    [self.visableBtnArray removeAllObjects];
    [self.homeBtns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.visableBtnArray addObject:obj];
    }];
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)didClickBtn:(BHBCustomBtn *)btn{
    if (self.btnCanceled) {
        self.btnCanceled = NO;
        return;
    }
    
    BHBItem * item;
    NSInteger index;
    if([self.homeBtns containsObject:btn]){
        index = [self.homeBtns indexOfObject:btn];
        item = [self.dataSource itemWithCenterView:self item:index];
    }

    [btn scalingWithTime:.25 andscal:1];

    if([item isKindOfClass:[BHBItem class]]) {
        [btn scalingWithTime:.25 andscal:1.7];
        [btn fadeOutWithTime:.25];
        [self.visableBtnArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BHBCustomBtn * b = obj;
            if (b != btn) {
                [b scalingWithTime:.25 andscal:0.3];
                [b fadeOutWithTime:.25];
            }
        }];
        if (!self.delegate || ![self.delegate respondsToSelector:@selector(didSelectItemWithCenterView:andItem:)]) {
            return;
        }
        [self.delegate didSelectItemWithCenterView:self andItem:item];
    }
}

- (void)dismis{
    [self btnPositonAnimation:YES];
}

- (void)removeAnimation{
    [self.visableBtnArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BHBCustomBtn * btn = obj;
        CGFloat x = btn.frame.origin.x;
        CGFloat y = btn.frame.origin.y;
        CGFloat width = btn.frame.size.width;
        CGFloat height = btn.frame.size.height;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.visableBtnArray.count - idx) * 0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:0 animations:^{
                btn.alpha = 0;
                btn.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height - self.frame.origin.y + y, width, height);
            } completion:^(BOOL finished) {
                
            }];
        });
        
    }];
    
}

- (void)moveInAnimation{
    
    [self.visableBtnArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BHBCustomBtn * btn = obj;
        CGFloat x = btn.frame.origin.x;
        CGFloat y = btn.frame.origin.y;
        CGFloat width = btn.frame.size.width;
        CGFloat height = btn.frame.size.height;
        btn.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height + y - self.frame.origin.y, width, height);
        btn.alpha = 0.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(idx * 0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                btn.alpha = 1;
                btn.frame = CGRectMake(x, y, width, height);
            } completion:^(BOOL finished) {
                
            }];
        });
        
    }];
}

- (void)btnPositonAnimation:(BOOL)isDismis{
    if (self.visableBtnArray.count <= 0) {
        [self.homeBtns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.visableBtnArray addObject:obj];
        }];
    }
    if (isDismis) {
        [self removeAnimation];
    }else{
        [self moveInAnimation];
    }
    
}

@end
