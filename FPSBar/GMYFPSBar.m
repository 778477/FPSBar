//
//  GMYFPSBar.m
//  FPSBar
//
//  Created by 郭妙友 on 15/10/16.
//  Copyright © 2015年 miaoyou.gmy. All rights reserved.
//

#import "GMYFPSBar.h"
#import <QuartzCore/QuartzCore.h>

@interface GMYFPSBarViewController : UIViewController
@end
@implementation GMYFPSBarViewController
@end


@interface GMYFPSBar()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CATextLayer *textLayer;
//@property (nonatomic, strong) CAShapeLayer *linesLayer;
@property (nonatomic, strong) CAShapeLayer *chartLayer;

@property (nonatomic, assign) NSUInteger maxDTLength;
@property (nonatomic, assign) NSUInteger historyDTLength;

@property (nonatomic, assign) NSTimeInterval *historyDT;
@property (nonatomic, assign) NSTimeInterval displayLinkTickLastTime;
@end

@implementation GMYFPSBar
static GMYFPSBar *bar = nil;
+ (GMYFPSBar *)shareInstance{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        bar = [[GMYFPSBar alloc] init];
    });
    
    return bar;
}


#pragma mark - Life Cycle
- (void)dealloc{
    _displayLink.paused = YES;
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (instancetype)init{
    if(self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)]){
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor blackColor];
        
        // 根据屏幕宽度 设置最长数据限制。 方便绘制曲线图
        _maxDTLength = (NSUInteger)CGRectGetWidth(self.bounds);
        _historyDTLength = 0;
        _historyDT = (NSTimeInterval *)malloc(sizeof(NSTimeInterval) * _maxDTLength);
        
        // bugfix Application windows are expected to have a root view controller at the end of application launch
        // https://forums.developer.apple.com/thread/15737
        self.rootViewController = [GMYFPSBarViewController new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        // Track FPS using display Link
        
        /* Create a new display link object for the main display. It will
         * invoke the method called 'sel' on 'target', the method has the
         * signature '(void)selector:(CADisplayLink *)sender'. */
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        
//        _linesLayer = [CAShapeLayer layer];
//        _linesLayer.frame = self.bounds;
//        _linesLayer.strokeColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.5f].CGColor;
//        _linesLayer.contentsScale = [UIScreen mainScreen].scale;
//        [self.layer addSublayer:_linesLayer];
//        
////        UIBezierPath *path = [UIBezierPath bezierPath];
////        [path moveToPoint:CGPointZero];
////        [path addLineToPoint:CGPointMake(self.frame.size.width, 0.f)];
////        [path moveToPoint:CGPointMake(0, 43.f)];
////        [path addLineToPoint:CGPointMake(self.frame.size.width, 43.f)];
////        [path closePath];
////        _linesLayer.path = path.CGPath;
//        [_linesLayer setDrawsAsynchronously:YES];
        
        
        _chartLayer = [CAShapeLayer layer];
        _chartLayer.frame = self.bounds;
        _chartLayer.strokeColor = [UIColor redColor].CGColor;
        _chartLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_chartLayer];
        [_chartLayer setDrawsAsynchronously:YES];
        
        _textLayer = [CATextLayer layer];
        _textLayer.frame = CGRectMake(5.0f, 9.0f, 100.f,20.f);
        _textLayer.fontSize = 14.f;
        _textLayer.foregroundColor = [UIColor redColor].CGColor;
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_textLayer];
        [_textLayer setDrawsAsynchronously:YES];

        [self setUpdateInterval:1.0f/60];
    }
    return self;
}

#pragma mark - NSNotification
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification{
    _displayLink.paused = NO;
    _displayLinkTickLastTime = CACurrentMediaTime(); // 开始计时
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification{
    _displayLink.paused = YES;
}


#pragma mark - Track FPS
- (void)displayLinkTick{
    // Shift up the buffer
    for(NSUInteger idx = _historyDTLength; idx >= 1 ; --idx){
        _historyDT[idx] = _historyDT[idx-1];
    }
    
    _historyDT[0] = _displayLink.timestamp - _displayLinkTickLastTime;
    
    if(_historyDTLength < _maxDTLength - 1) _historyDTLength++;
    
    _displayLinkTickLastTime = _displayLink.timestamp;
    
    [self updateCharAndText];
}


- (void)updateCharAndText{
    CFTimeInterval maxDT = CGFLOAT_MIN;
    CFTimeInterval avgDT = 0.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    
    for(NSUInteger idx = 0; idx<_historyDTLength ; ++idx){
        maxDT = MAX(maxDT, _historyDT[idx]);
        avgDT += _historyDT[idx];
        
        CGFloat fraction = roundf(1.f/(float)_historyDT[idx]) * 1.0 / 60;
        CGFloat y = _chartLayer.frame.size.height * (1.0 - fraction);
        y = MAX(0.f, MIN(_chartLayer.frame.size.height, y));
        
        [path addLineToPoint:CGPointMake(idx+1.f, y)];
    }
    
    [path addLineToPoint:CGPointMake(_historyDTLength, 0)];
    _chartLayer.path = path.CGPath;
    
    avgDT /= _historyDTLength;
    
    CFTimeInterval avgFPS = roundf(1.0f/(float)avgDT);
    [_textLayer setString:[NSString stringWithFormat:@"avg : %.f",avgFPS]];
    
}
@end
