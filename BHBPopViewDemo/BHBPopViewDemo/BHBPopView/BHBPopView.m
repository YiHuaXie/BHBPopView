//
//  BHBPopView.m
//  BHBPopViewDemo
//
//  Created by 毕洪博 on 15/8/14.
//  Copyright (c) 2015年 毕洪博. All rights reserved.
//

#import "BHBPopView.h"
#import "UIView+BHBAnimation.h"
#import "BHBBottomBar.h"
#import "BHBCustomBtn.h"
#import "UIButton+BHBSetImage.h"
#import "BHBCenterView.h"

//iPhone full screen
#define NN_IS_ALL_SCREEN \
({\
    BOOL result = NO;\
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {\
        CGSize size = [UIScreen mainScreen].bounds.size;\
        CGFloat maxLength = size.width > size.height ? size.width : size.height;\
        if (maxLength >= 812.0f) \
            result = YES;\
    }\
    (result);\
})\

#define SAFE_AREA_BOTTOM    (NN_IS_ALL_SCREEN ? 34 : 0)

@interface BHBPopView ()<BHBCenterViewDelegate,BHBCenterViewDataSource>

@property (nonatomic,weak) UIImageView * background;
@property (nonatomic,weak) BHBBottomBar * bottomBar;
@property (nonatomic,weak) BHBCenterView * centerView;

@property (nonatomic,strong) NSArray * items;
@property (nonatomic,copy) DidSelectItemBlock selectBlock;

@end

@implementation BHBPopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didViewTouched:)]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didViewTouched:)];
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        UIImageView * iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:iv];
        self.background = iv;
        
        BHBBottomBar * bar = [[BHBBottomBar alloc]initWithFrame:CGRectMake(0, frame.size.height - BHBBOTTOMHEIGHT - SAFE_AREA_BOTTOM, frame.size.width, BHBBOTTOMHEIGHT)];
        
        __weak typeof(self) weakSelf = self;
        bar.backClick = ^{
            [weakSelf.centerView scrollBack];
        };
        bar.closeClick = ^{
            [weakSelf hideItems];
            [weakSelf hide];
        };
        [self addSubview:bar];
        self.bottomBar = bar;
        
        CGRect centerViewFrame = CGRectMake(0, bar.frame.origin.y - 294, self.frame.size.width, 294);
        BHBCenterView *centerView = [[BHBCenterView alloc] initWithFrame:centerViewFrame];
        [self addSubview:centerView];
        centerView.delegate = self;
        centerView.dataSource = self;
        centerView.clipsToBounds = NO;
        self.centerView = centerView;
        
    }
    return self;
}

- (void)_didViewTouched:(UITapGestureRecognizer *)tap {
    self.userInteractionEnabled = NO;
    [self.bottomBar btnResetPosition];
    [self.bottomBar fadeOutWithTime:.25];
    [self hideItems];
    [self hide];
}

- (void)removeitemsComplete{
    self.superview.userInteractionEnabled = YES;
}

- (void)showItems{
    [self.centerView reloadData];
}

- (void)hideItems{
    [self.centerView dismis];
}

+ (BHB_INSTANCETYPE)showToView:(UIView *)view withItems:(NSArray *)array andSelectBlock:(DidSelectItemBlock)block{
    if (!view) { return nil; }
    
    BHBPopView * popView = [[BHBPopView alloc]initWithFrame:view.bounds];
    popView.background.image = [self imageWithView:view];
    [view addSubview:popView];
    popView.selectBlock = block;
    [popView fadeInWithTime:0.25];
    popView.items = array;
    [popView showItems];
    
    return popView;
}

+ (UIImage *)imageWithView:(UIView *)view{
    // 背景色
    UIColor *color = [UIColor.whiteColor colorWithAlphaComponent:0.95];
    
    CGRect rect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}

- (void)hide{
    [BHBPopView hideWithView:self];
}

+ (void)hideWithView:(UIView *)view {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view fadeOutWithTime:0.35];
    });
}

#pragma mark centerview delegate and datasource

- (NSInteger)numberOfItemsWithCenterView:(BHBCenterView *)centerView {
    return self.items.count;
}

- (BHBItem *)itemWithCenterView:(BHBCenterView *)centerView item:(NSInteger)item {
    return self.items[item];
}

- (void)didSelectItemWithCenterView:(BHBCenterView *)centerView andItem:(BHBItem *)item {
    if (self.selectBlock) {
        self.selectBlock(item);
    }

    [self hide];
}

- (void)dealloc{
//    NSLog(@"BHBPopView");
}

@end
