/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/
#import "AP_3AxisGraphic.h"

#define BASE_VALUE 2000
NSString* ACCEL_METER_TABLE[] = {
    @"2g",@"1g",@"0",@"-1g",@"-2g"
};
#define METER_BASE_Y_POINT  115
@implementation AP_3AxisGraphic
{
    float   _ave_accel_x;
    float   _ave_accel_y;
    float   _ave_accel_z;
}

/********************************************************************************
 *initWithFrame
 ********************************************************************************/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    _ave_accel_x = 0;
    _ave_accel_y = 0;
    _ave_accel_z = 0;
    return self;
}
/********************************************************************************
 *getAccelX
 ********************************************************************************/
-(void)getAccelX:(NSInteger)accel_x
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _accel_x[i+1] = _accel_x[i];
    }
    _accel_x[0] = accel_x;
}
/********************************************************************************
 *getAccelY
 ********************************************************************************/
-(void)getAccelY:(NSInteger)accel_y
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _accel_y[i+1] = _accel_y[i];
    }
    _accel_y[0] = accel_y;
}
/********************************************************************************
 *getAccelZ
 ********************************************************************************/
-(void)getAccelZ:(NSInteger)accel_z
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _accel_z[i+1] = _accel_z[i];
    }
    _accel_z[0] = accel_z;
}
/********************************************************************************
 *setContext
 ********************************************************************************/
-(void)setContext:(CGContextRef)context
{
    if(_context != NULL){
        CGContextRelease(_context);
        _context = NULL;
    }
    _context = context;
    CGContextRetain(_context);
}
/********************************************************************************
 *setColor_r
 ********************************************************************************/
-(void)setColor_r:(int)r g:(int)g b:(int)b
{
    CGContextSetRGBFillColor(_context, r/255, g/255, b/255, 1.0f);
    CGContextSetRGBStrokeColor(_context, r/255, g/255, b/255, 1.0f);
}
/********************************************************************************
 *setLineWidth
 ********************************************************************************/
-(void) setLineWidth:(float)width
{
    CGContextSetLineWidth(_context, width);
}
/********************************************************************************
 *drawLine_x0
 ********************************************************************************/
-(void) drawLine_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1
{
    CGContextMoveToPoint(_context, x0, y0);
    CGContextAddLineToPoint(_context, x1, y1);
    CGContextStrokePath(_context);
}
/********************************************************************************
 *drawRect_x
 ********************************************************************************/
-(void)drawRect_x:(float)x y:(float)y w:(float)w h:(float)h
{
    CGContextMoveToPoint(_context, x, y);
    CGContextAddLineToPoint(_context, x+w, y);
    CGContextAddLineToPoint(_context, x+w, y+h);
    CGContextAddLineToPoint(_context, x, y+h);
    CGContextAddLineToPoint(_context, x, y);
    CGContextAddLineToPoint(_context, x+w, y);
    CGContextStrokePath(_context);
}
/********************************************************************************
 *fillRect_x
 ********************************************************************************/
-(void)fillRect_x:(float)x y:(float)y w:(float)w h:(float)h
{
    CGContextFillRect(_context,CGRectMake(x, y, w, h));
}
/********************************************************************************
 *drawString
 ********************************************************************************/
-(void)drawString:(NSString*)string x:(float)x y:(float)y font:(UIFont*)font
{
    [string drawAtPoint:CGPointMake(x , y) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil]];
}
/********************************************************************************
 *drawAccelX_x0
 ********************************************************************************/
-(void)drawAccelX_x0:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_accel_x[i-1] / BASE_VALUE;
    y0 = (-40) * r0 + 160;
    float r1 = (float)_accel_x[i] / BASE_VALUE;
    y1 = (-40) * r1 + 160;
    [self setColor_r:0 g:255 b:0];
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawAccelY_x0
 ********************************************************************************/
-(void)drawAccelY_x0:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_accel_y[i-1] / BASE_VALUE;
    y0 = (-40) * r0 + 160;
    float r1 = (float)_accel_y[i] / BASE_VALUE;
    y1 = (-40) * r1 + 160;
    [self setColor_r:255 g:0 b:255];
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawAccelZ_x0
 ********************************************************************************/
-(void)drawAccelZ_x0:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_accel_z[i-1] / BASE_VALUE;
    y0 = (-40) * r0 + 160;
    float r1 = (float)_accel_z[i] / BASE_VALUE;
    y1 = (-40) * r1 + 160;
    [self setColor_r:255 g:0 b:0];
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawAccelGraph
 ********************************************************************************/
-(void)drawAccelGraph:(float)ScreenWidth
{
    float x0 , x1;
    float width = (ScreenWidth-30)/ARRAY_MAX;
    for(int i=1;i<ARRAY_MAX;i++){
        x0 = (i-1)*width+30;
        x1 = i*width+30;
        [self drawAccelX_x0:x0 x1:x1 index:i];
        [self drawAccelY_x0:x0 x1:x1 index:i];
        [self drawAccelZ_x0:x0 x1:x1 index:i];
    }
}
/********************************************************************************
 *drawAverageValue
 ********************************************************************************/
-(void)drawAverageValue
{
    NSString* mes;
    float ave_1=0 , ave_2=0 , ave_3=0;
    UIFont* font = [UIFont fontWithName:@"Futura-Medium" size:12];

    for(int i=0;i<ARRAY_MAX;i++){
        ave_1 += (float)_accel_x[i]/BASE_VALUE*2;
        ave_2 += (float)_accel_y[i]/BASE_VALUE*2;
        ave_3 += (float)_accel_z[i]/BASE_VALUE*2;
    }
    ave_1 /= ARRAY_MAX;
    ave_2 /= ARRAY_MAX;
    ave_3 /= ARRAY_MAX;
    _ave_accel_x = ave_1;
    _ave_accel_y = ave_2;
    _ave_accel_z = ave_3;
    mes = [NSString stringWithFormat:@"x:%.3fg" , _ave_accel_x];
    [self drawString:mes x:100 y:60 font:font];
    mes = [NSString stringWithFormat:@"y:%.3fg" , _ave_accel_y];
    [self drawString:mes x:170 y:60 font:font];
    mes = [NSString stringWithFormat:@"z:%.3fg" , _ave_accel_z];
    [self drawString:mes x:240 y:60 font:font];
}
/********************************************************************************
 *drawGraphBackGround
 ********************************************************************************/
-(void)drawGraphBackGround : (float)screen_x
{
    [self setContext:UIGraphicsGetCurrentContext()];
    UIFont* font = [UIFont fontWithName:@"Futura-Medium" size:10];
    UIFont* font2 = [UIFont fontWithName:@"Futura-Medium" size:30];
    [self setColor_r:255 g:255 b:255];
    [self fillRect_x:0 y:100 w:screen_x h:120];
    [self setColor_r:0 g:0 b:0];
    for(int y=120;y<220;y+=20){
        [self drawLine_x0:30 y0:y x1:screen_x y1:y];
    }
    [self drawString:@"Accel" x:0 y:60 font:font2];
    [self drawString:@"x :" x:120 y:85 font:font];
    [self setColor_r:0 g:255 b:0];
    [self drawLine_x0:140 y0:90 x1:160 y1:90];
    [self drawString:@"y :" x:180 y:85 font:font];
    [self setColor_r:255 g:0 b:255];
    [self drawLine_x0:200 y0:90 x1:220 y1:90];
    [self drawString:@"z :" x:240 y:85 font:font];
    [self setColor_r:255 g:0 b:0];
    [self drawLine_x0:260 y0:90 x1:280 y1:90];
    [self setColor_r:0 g:0 b:0];
    for(uint8_t i=0;i<5;i++){
        [self drawString:ACCEL_METER_TABLE[i] x:0 y:i*20+METER_BASE_Y_POINT font:font];
    }
}
/********************************************************************************
 *getAccelXAverage
 ********************************************************************************/
-(float)getAccelXAverage
{
    return _ave_accel_x;
}
/********************************************************************************
 *getAccelYAverage
 ********************************************************************************/
-(float)getAccelYAverage
{
    return _ave_accel_y;
}
/********************************************************************************
 *getAccelZAverage
 ********************************************************************************/
-(float)getAccelZAverage
{
    return _ave_accel_z;
}
/********************************************************************************
 *deleteDatas
 ********************************************************************************/
-(void)deleteDatas
{
    for(int i=0;i<ARRAY_MAX;i++){
        _accel_x[i] = 0;
        _accel_y[i] = 0;
        _accel_z[i] = 0;
    }
}
/********************************************************************************
 *drawRect
 ********************************************************************************/
- (void)drawRect:(CGRect)rect
{
    CGRect screen_size = [ [UIScreen mainScreen] bounds];
    float  screen_x = screen_size.size.width;
    [self drawGraphBackGround:screen_x];
    [self drawAverageValue];
    [self drawAccelGraph:screen_x];
}

@end
