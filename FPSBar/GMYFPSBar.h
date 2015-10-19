//
//  GMYFPSBar.h
//  FPSBar
//
//  Created by 郭妙友 on 15/10/16.
//  Copyright © 2015年 miaoyou.gmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMYFPSBar : UIWindow

@property (nonatomic, readwrite, assign) NSTimeInterval updateInterval;

+ (GMYFPSBar *)shareInstance;

@end

