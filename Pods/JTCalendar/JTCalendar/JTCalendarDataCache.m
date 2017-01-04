//
//  JTCalendarDataCache.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDataCache.h"

#import "JTCalendar.h"

@interface JTCalendarDataCache(){
    NSMutableDictionary *events;
    NSDateFormatter *dateFormatter;
};

@end

@implementation JTCalendarDataCache

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    events = [NSMutableDictionary new];
    
    return self;
}

- (void)reloadData
{
    [events removeAllObjects];
}

- (id)dataForEvent:(NSDate *)date
{
    if(!self.calendarManager.dataSource){
        return nil;
    }
    
    if(!self.calendarManager.calendarAppearance.useCacheSystem){
        return [self.calendarManager.dataSource calendar:self.calendarManager dataForDate:date];
    }
    
    id eventData;
    NSString *key = [dateFormatter stringFromDate:date];
    
    if(events[key] != nil){
        eventData = events[key];
    } else {
        if ((eventData = [self.calendarManager.dataSource calendar:self.calendarManager dataForDate:date])) {
            events[key] = eventData;
        }
    }
    
    return eventData;
}

@end