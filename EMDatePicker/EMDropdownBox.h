//
//  EMDropdownBox.h
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMDropdownBox;

@protocol EMDropdownBoxDelegate <NSObject>

- (void)dropdownBox:(EMDropdownBox *)dropdown didSelectIndex:(NSUInteger)index;

@end

@interface EMDropdownBox : UIView

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *dropdownColor;
@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) UIColor *boxColor;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) id<EMDropdownBoxDelegate> delegate;
@end
