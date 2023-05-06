//
//  MarqueeView.m
//  sip
//
//  Created by gemvary on 16/5/30.
//  Copyright © 2016年 gemvary. All rights reserved.
//

#import "MarqueeView.h"

#define VIEW_INTERVAL_WIDTH 30.0
#define VIEW_INTERVAL_HEIGHT 6.0
#define TIMER_INTERVAL_LEFT 0.05
#define TIMER_INTERVAL_UP 0.1

@interface MarqueeView ()
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) NSMutableAttributedString* textAttrM;
@end

@implementation MarqueeView

#pragma mark - setter

- (void)setTextArr:(NSArray *)textArr{
    if (![_textArr isEqualToArray:textArr]) {
        _textArr = textArr;
        [self setNeedsDisplay];
    }
}

- (void)setFontOfMarqueeLabel:(CGFloat)fontOfMarqueeLabel{
    if (_fontOfMarqueeLabel != fontOfMarqueeLabel) {
        _fontOfMarqueeLabel = fontOfMarqueeLabel;
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    if (![_textColor isEqual:textColor]) {
        _textColor = textColor;
        [self setNeedsDisplay];
    }
}

- (void)setDirection:(MarqueeViewDirection)direction{
    if (_direction != direction) {
        _direction = direction;
        [self setNeedsDisplay];
    }
}

- (void)setHeaderImage:(UIImage *)headerImage{
    if (![_headerImage isEqual:headerImage]) {
        _headerImage = headerImage;
        [self setNeedsDisplay];
    }
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self option];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self option];
    }
    return self;
}

- (void)dealloc{
    [self unTimer];
}

- (void)unTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)option{
    self.clipsToBounds = YES;
    self.backgroundColor = nil;
//    self.backgroundColor = [UIColor redColor];
    self.opaque = NO;
}


#pragma mark - create
//创建MarqueeLabels
- (void)createMarqueeViews{
    switch (self.direction) {
        case MarqueeViewDirectionLeft: {
            [self createLeftMarqueeViews];
            break;
        }
        case MarqueeViewDirectionUp: {
            [self createUpMarqueeViews];
            break;
        }
    }
}

//向左滚动的跑马灯
- (void)createLeftMarqueeViews{
    if ([self isGreaterForWidthOfAllViews]) {
        for (int i = 0; i < self.textArr.count; ++i) {
            [self createLeftMarqueeViewWithContent:self.textArr[i]];
        }
    }else{
        for (int i = 0; i%self.textArr.count < self.textArr.count; ++i) {
            UIView* view =  [self createLeftMarqueeViewWithContent:self.textArr[i%self.textArr.count]];
            view.tag = i%self.textArr.count;
            if (CGRectGetMaxX(view.frame) > self.frame.size.width-VIEW_INTERVAL_WIDTH) {
                break;
            }
        }
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL_LEFT target:self selector:@selector(move:) userInfo:nil repeats:YES];
        self.timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL_LEFT target:self selector:@selector(move:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

//向上滚动的跑马灯
- (void)createUpMarqueeViews{
    for (int i = 0; i%self.textArr.count < self.textArr.count; ++i) {
        UIView* view =  [self createUpMarqueeViewWithContent:self.textArr[i%self.textArr.count]];
        view.tag = i%self.textArr.count;
        if (CGRectGetMaxY(view.frame) > self.frame.size.height-VIEW_INTERVAL_HEIGHT) {
            break;
        }
    }
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL_UP target:self selector:@selector(move:) userInfo:nil repeats:YES];
    self.timer = [NSTimer timerWithTimeInterval:TIMER_INTERVAL_UP target:self selector:@selector(move:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

//创建LeftMarqueeLabel
- (UIView*)createLeftMarqueeViewWithContent:(id)content
{
    CGSize labelSize = [self labelSizeWithContent:content];
    CGSize viewSize = labelSize;
    
    //创建view
    UIView* view = [[UIView alloc]init];
    view.frame = CGRectMake(0, (self.frame.size.height - viewSize.height)/2, viewSize.width, viewSize.height);
    
    //有图片
    if (self.headerImage) {
        viewSize = CGSizeMake(labelSize.width+labelSize.height, labelSize.height);
        view.frame = CGRectMake(0, (self.frame.size.height - viewSize.height)/2, viewSize.width, viewSize.height);
    }
    
    if (self.isLeft?NO:[self isGreaterForWidthOfAllViews]) {//是否左对齐显示
        CGFloat x = (self.frame.size.width-[self widthOfAllViews])/2;
        CGRect frame = view.frame;
        frame.origin.x = x;
        view.frame = frame;
    }
    
    UIView* lastView = (UIView*)[self.subviews lastObject];
    if (lastView) {
        view.frame = CGRectMake(CGRectGetMaxX(lastView.frame)+VIEW_INTERVAL_WIDTH, (self.frame.size.height - viewSize.height)/2, viewSize.width, viewSize.height);
    }
    //创建headerImageView
    if (self.headerImage) {
        UIImageView* iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkbox_yes"]];
        iv.frame = CGRectMake(0, (view.frame.size.height - labelSize.height)/2, labelSize.height, labelSize.height);
        [view addSubview:iv];
    }
    
    //创建label
    UILabel* label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, (view.frame.size.height - labelSize.height)/2, labelSize.width, labelSize.height);
    [label setAttributedText:[self labelAttributedStringWithContent:content]];
    if (self.headerImage) {
        label.frame = CGRectMake(labelSize.height, (view.frame.size.height - labelSize.height)/2, labelSize.width, labelSize.height);
    }
    [view addSubview:label];
    
    [self addSubview:view];
    
    return view;
}


//创建upMarqueeLabel
- (UIView*)createUpMarqueeViewWithContent:(id)content{
    CGSize labelSize = [self labelSizeWithContent:content];
    CGSize viewSize = labelSize;
    
    //创建view
    UIView* view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    
    if (self.headerImage) {
        viewSize = CGSizeMake(labelSize.width+labelSize.height, labelSize.height);
        view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    }
    UIView* lastView = (UIView*)[self.subviews lastObject];
    if (lastView) {
        view.frame = CGRectMake(0, CGRectGetMaxY(lastView.frame)+VIEW_INTERVAL_HEIGHT, viewSize.width, viewSize.height);
    }
    
    //创建headerImageView
    if (self.headerImage) {
        UIImageView* iv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkbox_yes"]];
        iv.frame = CGRectMake(0, 0, labelSize.height, labelSize.height);
        [view addSubview:iv];
    }
    
    //创建label
    UILabel* label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    [label setAttributedText:[self labelAttributedStringWithContent:content]];
    if (self.headerImage) {
        label.frame = CGRectMake(labelSize.height, 0, labelSize.width, labelSize.height);
    }
    [view addSubview:label];
    
    [self addSubview:view];
    
    return view;
}

//删除所有MarqueeLabel
- (void)removeMarqueeViews{
    [self unTimer];
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
}

- (void)move:(NSTimer*)timer{
    switch (self.direction) {
        case MarqueeViewDirectionLeft: {
            [self leftMove];
            break;
        }
        case MarqueeViewDirectionUp: {
            [self upMove];
            break;
        }
    }
}

//向左移动
- (void)leftMove{
    for (UIView* view in self.subviews) {
        CGRect frame = view.frame;
        CGPoint point = frame.origin;
        --point.x;
        frame.origin = point;
        view.frame = frame;
    }
    
    UIView* lastView = [self.subviews lastObject];
    if (CGRectGetMaxX(lastView.frame) < self.frame.size.width-VIEW_INTERVAL_WIDTH) {
        UIView* view = [self createLeftMarqueeViewWithContent:self.textArr[(lastView.tag+1)%self.textArr.count]];
        view.tag = (lastView.tag+1)%self.textArr.count;
    }
    
    UIView* firstView = [self.subviews firstObject];
    if (CGRectGetMaxX(firstView.frame) < 0) {
        [firstView removeFromSuperview];
    }
}

//向上移动
- (void)upMove {
    for (UIView* view in self.subviews) {
        CGRect frame = view.frame;
        CGPoint point = frame.origin;
        --point.y;
        frame.origin = point;
        view.frame = frame;
    }
    
    UIView* lastView = [self.subviews lastObject];
    if (CGRectGetMaxY(lastView.frame) < self.frame.size.height-VIEW_INTERVAL_HEIGHT) {
        UIView* view = [self createUpMarqueeViewWithContent:self.textArr[(lastView.tag+1)%self.textArr.count]];
        view.tag = (lastView.tag+1)%self.textArr.count;
    }
    
    UIView* firstView = [self.subviews firstObject];
    if (CGRectGetMaxY(firstView.frame) < 0) {
        [firstView removeFromSuperview];
    }
}

#pragma mark

//数组中string的总宽度是否大于self的宽度
- (BOOL)isGreaterForWidthOfAllViews {
    CGFloat allWidth = [self widthOfAllViews];
    return self.frame.size.width > allWidth;
}

//数组中string的总宽度
- (CGFloat)widthOfAllViews {
    CGFloat allWidth = 0.0;
    for (id content in self.textArr) {
        if (allWidth > 0) {
            allWidth += VIEW_INTERVAL_WIDTH;
        }
        CGSize size = [self labelSizeWithContent:content];
        allWidth += size.width;
        if (self.headerImage) {
            allWidth += size.height;
        }
    }
    return allWidth;
}

//label的size
- (CGSize)labelSizeWithContent:(id)content{
    if ([content isKindOfClass:[NSDictionary class]]) {
        NSString* name = [(NSDictionary*)content objectForKey:@"name"];
        NSString* prize = [(NSDictionary*)content objectForKey:@"prize"];
        NSString* str = @"恭喜3小时前获得";
        
        NSAttributedString* nameAttr = [[NSAttributedString alloc]initWithString:name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:[UIColor blueColor]}];
        NSAttributedString* prizeAttr = [[NSAttributedString alloc]initWithString:prize attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:[UIColor redColor]}];
        NSMutableAttributedString* strAttrM = [[NSMutableAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:self.textColor?self.textColor:[UIColor blackColor]}];
        
        [strAttrM insertAttributedString:nameAttr atIndex:2];
        [strAttrM insertAttributedString:prizeAttr atIndex:strAttrM.length];
        
        self.textAttrM = strAttrM;
        
        CGSize size = [strAttrM size];
        
        return size;
    }
    CGSize size = [(NSString*)content sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel]}];
    self.textAttrM = [[NSMutableAttributedString alloc]initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel]}];
    return size;
}

//label的内容
- (NSMutableAttributedString*)labelAttributedStringWithContent:(id)content{
    if ([content isKindOfClass:[NSDictionary class]]) {
        NSString* name = [(NSDictionary*)content objectForKey:@"name"];
        NSString* prize = [(NSDictionary*)content objectForKey:@"prize"];
        NSString* str = @"恭喜3小时前获得";
        
        NSAttributedString* nameAttr = [[NSAttributedString alloc]initWithString:name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:[UIColor blueColor]}];
        NSAttributedString* prizeAttr = [[NSAttributedString alloc]initWithString:prize attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:[UIColor redColor]}];
        NSMutableAttributedString* strAttrM = [[NSMutableAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:self.textColor?self.textColor:[UIColor blackColor]}];
        
        [strAttrM insertAttributedString:nameAttr atIndex:2];
        [strAttrM insertAttributedString:prizeAttr atIndex:strAttrM.length];
        
        return strAttrM;
    }
    NSMutableAttributedString* strAttrM = [[NSMutableAttributedString alloc]initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontOfMarqueeLabel], NSForegroundColorAttributeName:self.textColor?self.textColor:[UIColor blackColor]}];
    return strAttrM;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self removeMarqueeViews];
    [self createMarqueeViews];
}


@end
