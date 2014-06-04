//
//  EMDatePicker.h
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMDatePicker : UIView

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate, *maximumDate;

@end
