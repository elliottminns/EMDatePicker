//
//  EMViewController.m
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import "EMViewController.h"
#import "EMDatePicker.h"

@interface EMViewController ()
@property (nonatomic, weak) IBOutlet EMDatePicker *datePicker;
@property (nonatomic, strong) NSDate *minimumDate, *maximumDate;
@end

@implementation EMViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.minimumDate = [[NSDate date] dateByAddingTimeInterval:-3600 * 48];
    self.maximumDate = [[NSDate date] dateByAddingTimeInterval:3600 * 48];
    
    self.datePicker.minimumDate = self.minimumDate;
    self.datePicker.maximumDate = self.maximumDate;
    
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker addTarget:self action:@selector(dateChangedAgain) forControlEvents:UIControlEventValueChanged];
}

- (void)dateChanged:(id)sender {
    NSLog(@"Changes");
}

- (void)dateChangedAgain {
    NSLog(@"ANOTHER CHANGE");
}

@end
