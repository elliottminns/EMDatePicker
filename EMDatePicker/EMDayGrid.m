//
//  EMDayGrid.m
//  Demo
//
//  Created by Elliott Minns on 28/02/2014.
//  Copyright (c) 2014 Elliott Minns. All rights reserved.
//

#import "EMDayGrid.h"
#import "EMDateModel.h"
#import "NSDate+Values.h"

@interface EMDayGrid()
@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, assign) NSInteger selectedSegment;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation EMDayGrid

- (id)init {
    self = [super init];
    
    if (self) {
        [self initialise];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
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
    self.days = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
    self.titleFont = [UIFont systemFontOfSize:15.0];
    self.titleColor = [UIColor blackColor];
    self.circleLayer = [CAShapeLayer layer];
}

- (void)drawRect:(CGRect)rect {
    // Draw the labels.
    self.layer.sublayers = nil;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat width = rect.size.width / self.days.count;
    CGFloat height = rect.size.height / 7;
    
    [self.days enumerateObjectsUsingBlock:^(NSString *day, NSUInteger idx, BOOL *stop) {
        CGRect dayRect = CGRectMake(width * idx, 0, width, height);
        
        CATextLayer *dayLayer = [CATextLayer layer];
        dayLayer.frame = dayRect;
        dayLayer.font = (__bridge CFTypeRef)(self.titleFont.fontName);
        dayLayer.fontSize = self.titleFont.pointSize;
        dayLayer.alignmentMode = kCAAlignmentCenter;
        dayLayer.string = day;
        dayLayer.foregroundColor = self.titleColor.CGColor;
        dayLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:dayLayer];
    }];
    

    [self.dates enumerateObjectsUsingBlock:^(EMDateModel *dateModel, NSUInteger idx, BOOL *stop) {
        
        CGFloat x = width * (idx % 7);
        CGFloat y = height + ((idx / 7) * height);
        
        CGRect dayRect = CGRectMake(x, y, width, height);
        
        
        NSString *text = [NSString stringWithFormat:@"%lu", (long)dateModel.dateNumber];
        CATextLayer *dayLayer = [CATextLayer layer];
        dayLayer.font = (__bridge CFTypeRef)(self.titleFont.fontName);
        CGFloat textHeight = [self getTextSize:text].height;
        dayLayer.frame = CGRectMake(x, y + height / 2 - textHeight / 2, width, textHeight);
        dayLayer.fontSize = self.titleFont.pointSize;
        dayLayer.alignmentMode = kCAAlignmentCenter;
        dayLayer.string = text;
        UIColor *foregroundColor = [UIColor colorWithRed:234.f/255.f
                                                   green:234.f/255.f
                                                    blue:234.f/255.f
                                                   alpha:1.0];
        if (dateModel.isInCurrentMonth) {
            foregroundColor = [UIColor colorWithRed:214.f/255.f
                                              green:214.f/255.f
                                               blue:214.f/255.f
                                              alpha:1.0];
        }
        
        
        
        if (idx == self.selectedSegment) {
            foregroundColor = self.titleColor;
            CGFloat radius = MAX(dayRect.size.width, dayRect.size.height) * 0.75;
            self.circleLayer.backgroundColor = self.titleColor.CGColor;
            self.circleLayer.frame = CGRectMake(x + dayRect.size.width / 2 - radius / 2, y + dayRect.size.height / 2 - radius / 2, radius, radius);
            self.circleLayer.cornerRadius = radius / 2;
            if (!self.circleLayer.superlayer) {
                [self.layer addSublayer:self.circleLayer];
            }
            foregroundColor = [UIColor whiteColor];
        }
        
        dayLayer.foregroundColor = foregroundColor.CGColor;
        

        dayLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:dayLayer];
        
        
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] == 1) {
        UITouch * touch = [touches anyObject];
        // This is a simple tap
        CGPoint touchLocation = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.bounds, touchLocation)) {
            NSInteger segmentX = touchLocation.x / (CGFloat)(self.bounds.size.width / 7);
            NSInteger segmentY = (touchLocation.y / (CGFloat)(self.bounds.size.height / 7)) - 1;
            
            NSInteger segment = (segmentY * 7) + segmentX;
            if (segment > 0 && [self segmentIsValid:segment]) {
                [self setSelectedDay:segment animated:YES];
            }
        }
    }
}

- (void)setSelectedDay:(NSInteger)date animated:(BOOL)animated {
    self.selectedSegment = date;
    
    if (animated) {
        [self setNeedsDisplay];
    } else {
        [self setNeedsDisplay];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dayGrid:didSelectDay:)]) {
        [self.delegate dayGrid:self didSelectDay:self.selectedDay];
    }
}

- (BOOL)segmentIsValid:(NSInteger)segment {
    EMDateModel *model = self.dates[segment];
    return model.isInCurrentMonth;
}

- (void)setDate:(NSDate *)date {
    _date = date;
    
    // Work out the dates.
    NSInteger year = [date getYear];
    NSInteger month = [date getMonthNumber] - 1;
    NSInteger numberOfDaysInCurrentMonth = [self numberOfDaysInMonth:month + 1 forYear:year];
    NSInteger numberOfDaysInLastMonth = [self numberOfDaysInMonth:month forYear:year];

    NSInteger firstWeekday = [self getWeekdayForFirstDayInMonth:month + 1 forYear:year] - 1;
    NSInteger firstDate = numberOfDaysInLastMonth - (firstWeekday - 1);
    
    self.dates = [[NSMutableArray alloc] init];
    NSInteger numberOfDaysInMonth = numberOfDaysInLastMonth;
    NSInteger minusNumber = 0;
    NSInteger currentDay = [date getDay];
    
    BOOL isCurrentMonth = NO;
    NSInteger numberOfDaysOutInCurrentMonthStart = (self.minimumDate) ? [self.minimumDate getDay] : 0;
    NSInteger numberOfDaysOutInCurrentMonthEnd = 0;
    if (self.maximumDate) {
        numberOfDaysOutInCurrentMonthEnd = numberOfDaysOutInCurrentMonthStart - [self.maximumDate getDay] ;
    }
    
    
    for (NSInteger i = 0; i < 42; i++) {
        EMDateModel *dateModel = [[EMDateModel alloc] init];
        if (firstDate + i - minusNumber > numberOfDaysInMonth) {
            isCurrentMonth = !isCurrentMonth;
            firstDate = 1;
            numberOfDaysInMonth = numberOfDaysInCurrentMonth;
            minusNumber = i;
        }
        
        NSInteger date = firstDate + i - minusNumber;
        dateModel.isInCurrentMonth = isCurrentMonth;
        
        if (self.minimumDate) {
            if (isCurrentMonth && date < numberOfDaysOutInCurrentMonthStart && [self.minimumDate getMonthNumber] == month + 1) {
                dateModel.isInCurrentMonth = NO;
            }
        }
        
        if (self.maximumDate) {
            if (isCurrentMonth && date > [self.maximumDate getDay] && [self.maximumDate getMonthNumber] == month + 1) {
                dateModel.isInCurrentMonth = NO;
            }
        }
        
        dateModel.dateNumber = date;
        [self.dates addObject:dateModel];
        
        if (isCurrentMonth && currentDay == date) {
            self.selectedSegment = i;
        }
    }
    
    [self setNeedsDisplay];
}

- (NSInteger)numberOfDaysInMonth:(NSInteger)month forYear:(NSInteger)year {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    
    // Set your month here
    comps.day = 1;
    comps.month = month;
    comps.year = year;
    
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:[cal dateFromComponents:comps]];
    
    return  range.length;
}

- (NSInteger)getWeekdayForFirstDayInMonth:(NSInteger)month forYear:(NSInteger)year {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *firstDayComps = [[NSDateComponents alloc] init];
    firstDayComps.month = month;
    firstDayComps.year = year;
    firstDayComps.day = 1;
    NSDate *dayOneInCurrentMonth = [cal dateFromComponents:firstDayComps];
    NSDateComponents *components = [cal components:NSWeekdayCalendarUnit fromDate:dayOneInCurrentMonth];
    
    NSInteger weekday = [components weekday];
    return weekday;
}

- (CGSize)getTextSize:(NSString *)text {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName: self.titleFont,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    return [text sizeWithAttributes:attributes];
}

- (NSInteger)selectedDay {
    EMDateModel *model = self.dates[self.selectedSegment];
    return model.dateNumber;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    [self setNeedsDisplay];
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    [self setNeedsDisplay];
}

@end
