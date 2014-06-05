//
//  EMDayGrid.h
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMDayGrid;

@protocol EMDayGridDelegate <NSObject>

- (void)dayGrid:(EMDayGrid *)grid didSelectDay:(NSInteger)day;

@end

@interface EMDayGrid : UIView

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate, *maximumDate;
@property (nonatomic, assign, readonly) NSInteger selectedDay;
@property (nonatomic, weak) id<EMDayGridDelegate> delegate;

@end
