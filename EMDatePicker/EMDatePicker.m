//
//  EMDatePicker.m
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import "EMDatePicker.h"
#import "EMDropdownBox.h"
#import "EMDayGrid.h"
#import "NSDate+Values.h"

@interface EMDatePicker() <EMDropdownBoxDelegate, EMDayGridDelegate>
@property (nonatomic, strong) EMDropdownBox *monthBox, *yearBox;
@property (nonatomic, strong) EMDayGrid *dayGrid;
@property (nonatomic, strong) NSMutableArray *targetsAndSelectors;
@end

@implementation EMDatePicker

- (id)init {
    self = [super init];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (void)initialise {
    UIColor *viewColor = [UIColor colorWithRed:244.0f/255.0f
                                         green:246.0f/255.0f
                                          blue:247.0f/255.0f
                                         alpha:1.0];
    
    UIColor *textColor = [UIColor colorWithRed:131.0f/255.0f
                                         green:109.0f/255.0f
                                          blue:151.0f/255.0f
                                         alpha:1.0];
    
    UIFont *textFont = [UIFont fontWithName:@"GothamCondensed-Medium" size:20];
    self.monthBox = [[EMDropdownBox alloc] init];
    self.monthBox.boxColor = viewColor;
    self.monthBox.titleColor = textColor;
    self.monthBox.titleFont = textFont;
    self.monthBox.title = @"ddd";
    self.monthBox.tableData = [self getMonths];
    self.monthBox.delegate = self;
    [self addSubview:self.monthBox];
    
    self.yearBox = [[EMDropdownBox alloc] init];
    self.yearBox.boxColor = viewColor;
    self.yearBox.titleColor = textColor;
    self.yearBox.titleFont = textFont;
    self.yearBox.title = @"2014";
    self.yearBox.tableData = [self getYears];
    self.yearBox.delegate = self;
    [self addSubview:self.yearBox];
    
    self.dayGrid = [[EMDayGrid alloc] init];
    self.dayGrid.backgroundColor = [UIColor clearColor];
    self.dayGrid.titleColor = textColor;
    self.dayGrid.titleFont = [UIFont fontWithName:@"GothamCondensed-Book" size:20];
    self.dayGrid.delegate = self;
    
    [self addSubview:self.dayGrid];
    
    self.date = [NSDate date];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (controlEvents == UIControlEventValueChanged) {
        if (!self.targetsAndSelectors) {
            self.targetsAndSelectors = [[NSMutableArray alloc] init];
        }
        
        [self.targetsAndSelectors addObject:@{@"target": target,
                                             @"selector": [NSValue valueWithPointer:action]}];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    self.monthBox.translatesAutoresizingMaskIntoConstraints = NO;
    self.yearBox.translatesAutoresizingMaskIntoConstraints = NO;
    self.dayGrid.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_monthBox, _yearBox, _dayGrid);
    
    NSArray *constraints;
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_monthBox]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_monthBox(44)]"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];

    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_yearBox]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_monthBox]-10-[_yearBox(44)]"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_dayGrid]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_yearBox]-(<=10)-[_dayGrid]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];

    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_yearBox]-(10@999)-[_dayGrid]"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:constraints];
    
    [self.dayGrid setNeedsDisplay];
}

#pragma mark - Setters

- (void)setDate:(NSDate *)date {
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM"];
    NSString *monthString = [monthFormatter stringFromDate:date];
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"YYYY"];
    NSString *yearString = [yearFormatter stringFromDate:date];
    
    self.monthBox.selectedIndex = [[self getMonths] indexOfObject:monthString];
    self.yearBox.selectedIndex = [[self getYears] indexOfObject:yearString];
    
    self.dayGrid.date = date;
}

- (NSDate *)date {
    NSInteger year = [self.yearBox.tableData[self.yearBox.selectedIndex] integerValue];
    
    NSString *monthString = self.monthBox.tableData[self.monthBox.selectedIndex];
    NSInteger month = [self getMonthNumberFromString:monthString];
    NSInteger day = self.dayGrid.selectedDay;
    
    return [self dateFromYear:year andMonth:month day:day];
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    
    // Set up the minimum and maximum date in the month box.
    self.monthBox.tableData = [self getMonths];
    self.yearBox.tableData = [self getYears];
    self.dayGrid.minimumDate = minimumDate;
    self.dayGrid.date = self.date;
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    
    self.monthBox.tableData = [self getMonths];
    self.yearBox.tableData = [self getYears];
    self.dayGrid.maximumDate = maximumDate;
    self.dayGrid.date = self.date;
}

#pragma mark - Date Utilities

- (NSArray *)getMonths {
    NSInteger indexStart = 0;
    NSInteger indexEnd = 12;
    
    if (self.minimumDate) {
        if ([self.minimumDate getYear] == [self.yearBox.tableData[self.yearBox.selectedIndex] integerValue]) {
            indexStart = [self.minimumDate getMonthNumber] - 1;
        }
    }
    
    if (self.maximumDate) {
        if ([self.maximumDate getYear] == [self.yearBox.tableData[self.yearBox.selectedIndex] integerValue]) {
            indexEnd = [self.maximumDate getMonthNumber] ;
        }
    }
    
    NSMutableArray *months = [[NSMutableArray alloc] initWithCapacity:12];
    for (NSInteger i = indexStart; i < indexEnd; i++) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *monthName = [[df monthSymbols] objectAtIndex:(i)];
        [months addObject:monthName];
    }
    
    return months;
}

- (NSArray *)getYears {
    NSInteger indexStart = 0;
    NSInteger indexEnd = 9999;
    
    if (self.minimumDate) {
        indexStart = [self.minimumDate getYear] - 1;
    }
    
    if (self.maximumDate) {
        indexEnd = [self.maximumDate getYear];
    }
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for (NSInteger i = indexStart; i < indexEnd; i++) {
        [years addObject:[NSString stringWithFormat:@"%lu", i + 1]];
    }
    return years;
}

#pragma mark - DropdownBoxDelegate Methods

- (void)dropdownBox:(EMDropdownBox *)dropdown didSelectIndex:(NSUInteger)index {
    NSInteger year = [self.yearBox.tableData[self.yearBox.selectedIndex] integerValue];
    NSString *monthString = self.monthBox.tableData[self.monthBox.selectedIndex];
    NSInteger month = [self getMonthNumberFromString:monthString];
    NSArray *months = [self getMonths];
    self.monthBox.tableData = months;
    NSDate *date = [self dateFromYear:year andMonth:month];
    if ([date compare:self.minimumDate] == NSOrderedAscending) {
        date = self.minimumDate;
    }
    self.dayGrid.date = date;
}

#pragma mark - Date from year and month.

- (NSDate *)dateFromYear:(NSInteger)year andMonth:(NSInteger)month {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    
    // Set your month here
    [comps setMonth:month];
    [comps setYear:year];
    [comps setDay:1];
    
    NSDate *date = [cal dateFromComponents:comps];
    
    return date;
}

- (NSDate *)dateFromYear:(NSInteger)year andMonth:(NSInteger)month day:(NSInteger)day {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    
    // Set your month here
    [comps setMonth:month];
    [comps setYear:year];
    [comps setDay:day];
    
    NSDate *date = [cal dateFromComponents:comps];
    
    return date;
}

- (NSInteger)getMonthNumberFromString:(NSString *)string {
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MMMM"];
    NSDate *monthDate = [monthFormatter dateFromString:string];
    return [monthDate getMonthNumber];
}

#pragma mark - Day Grid Delegate Methods

- (void)dayGrid:(EMDayGrid *)grid didSelectDay:(NSInteger)day {
    for (NSDictionary *dict in self.targetsAndSelectors) {
        id target = dict[@"target"];
        SEL selector = [dict[@"selector"] pointerValue];
        if ([target canPerformAction:selector withSender:self]) {
            [target performSelector:selector withObject:self];
        } else {
            [target performSelector:selector];
        }
    }
}

@end
