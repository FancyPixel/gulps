//
//  JTCircleView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCircleView.h"

// http://stackoverflow.com/questions/17038017/ios-draw-filled-circles

@implementation JTCircleView

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }

    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor whiteColor];

    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(ctx, [self.backgroundColor CGColor]);
    CGContextFillRect(ctx, rect);

    rect = CGRectInset(rect, .5, .5);

    CGContextSetStrokeColorWithColor(ctx, [self.color CGColor]);
    CGContextSetFillColorWithColor(ctx, [self.color CGColor]);

    CGContextAddEllipseInRect(ctx, rect);
    CGContextFillEllipseInRect(ctx, rect);

    rect.size.height = rect.size.height * [self.data floatValue];

    CGContextAddRect(ctx, rect);
    CGContextClearRect(ctx, rect);

    CGContextFillPath(ctx);
}

- (void)setColor:(UIColor *)color
{
    self->_color = color;

    [self setNeedsDisplay];
}

- (void)setData:(id)data
{
    [self setNeedsDisplay];
    _data = data;
}

@end
