//
//  NSDate+Values.m
//  Loci
//
//  Created by Elliott Minns on 03/03/2014.
//  Copyright (c) 2014 Ocean Labs. All rights reserved.
//

#import "NSDate+Values.h"

@implementation NSDate (Values)

- (NSInteger)getMonthNumber {
    // Work out the dates.
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    return comps.month;
}

- (NSInteger)getDay {
    // Work out the dates.
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth |
                               NSCalendarUnitYear
                                     fromDate:self];
    return comps.day;
}

- (NSInteger)getYear {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [cal components:NSCalendarUnitDay |
                               NSCalendarUnitMonth | NSCalendarUnitYear
                                     fromDate:self];
    return comps.year;
}

@end
