//
//  JTCircleView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>
#import "JTDayViewProtocol.h"

@interface JTCircleView : UIView <JTDayViewProtocol>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) id data;

@end
