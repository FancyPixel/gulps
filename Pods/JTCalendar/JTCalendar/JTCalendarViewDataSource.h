//
//  JTCalendarDataSource.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <Foundation/Foundation.h>

@class JTCalendar;

@protocol JTCalendarDataSource <NSObject>

- (id)calendar:(JTCalendar *)calendar dataForDate:(NSDate *)date;
- (void)calendar:(JTCalendar *)calendar didSelectDate:(NSDate *)date;

@optional
- (void)calendarDidLoadPreviousPage;
- (void)calendarDidLoadNextPage;

@end
