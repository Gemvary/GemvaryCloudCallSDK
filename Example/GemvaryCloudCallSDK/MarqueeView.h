//
//  MarqueeView.h
//  sip
//
//  Created by gemvary on 16/5/30.
//  Copyright © 2016年 gemvary. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MarqueeViewDirection) {
    MarqueeViewDirectionLeft,
    MarqueeViewDirectionUp
};

@interface MarqueeView : UIView
/**
 *  内容数组    结构:@[NSString];   @{@"name":@"", @"prize":@""}
 */
@property (nonatomic,strong) NSArray* textArr;
@property (nonatomic) CGFloat fontOfMarqueeLabel;//字号
@property (nonatomic,strong) UIColor* textColor;//字体颜色
@property (nonatomic) MarqueeViewDirection direction;//滚动方向
@property (nonatomic,strong) UIImage* headerImage;//图片
@property (nonatomic) BOOL isLeft; //是否左对齐

@end
