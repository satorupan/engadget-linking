/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import "AP_THPGraphic.h"

NSString* drawTempMeter[] = {
    @"50°C" , @"40" , @"30" , @"20" , @"10" , @"0" , @"-10" , @"-20" , @"-30" , @"-40" , @"-50",
};
#define TEMP_HUMID_METER_BASE_Y_POINT     95.0f

@implementation AP_THPGraphic
{
    float   _temp;
    float   _hum;
    float   _atom;
    uint8_t index;
}
/********************************************************************************
 *initWithFrame
 ********************************************************************************/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    _temp = 0;
    _hum = 0;
    _atom = 0;
    index = 0;
    return self;
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
    [string drawAtPoint:CGPointMake(x, y) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil]];
}
/********************************************************************************
 *drawGraphBackGround
 ********************************************************************************/
-(void)drawGraphBackGround : (float)screen_x
{
    [self setContext:UIGraphicsGetCurrentContext()];
    UIFont* font = [UIFont fontWithName:@"Futura-Medium" size:10];
    [self setColor_r:255 g:255 b:255];
    [self fillRect_x:0 y:80 w:screen_x h:240];
    
    [self setColor_r:0 g:0 b:0];
    for(int y=100;y<320;y+=20){
        [self drawLine_x0:30 y0:y x1:screen_x-40 y1:y];
    }
    
    [self setColor_r:0 g:0 b:0];
    for(uint8_t i=0;i<11;i++){
        [self drawString:drawTempMeter[i] x:0 y:i*20+TEMP_HUMID_METER_BASE_Y_POINT font:font];
        [self drawString:[NSString stringWithFormat:@"%d%c" , 100 - 10*i , (i==0) ? '%' : ' '] x:screen_x-30 y:i*20+TEMP_HUMID_METER_BASE_Y_POINT font:font];
    }
    
    [self drawString:@"Temperature : "  x:80 y:355 font:font];
    [self drawString:@"Humidity : "  x:190 y:355 font:font];
    
    [self setColor_r:255 g:0 b:0];
    CGContextSetLineWidth(_context, 3.0);
    [self drawLine_x0:150 y0:365 x1:180 y1:365];
    [self setColor_r:0 g:0 b:255];
    [self drawLine_x0:240 y0:365 x1:270 y1:365];
}
/********************************************************************************
 *drawRect
 ********************************************************************************/
- (void)drawRect:(CGRect)rect
{
    CGRect screen_size = [ [UIScreen mainScreen] bounds];
    float  screen_x = screen_size.size.width;
    [self drawGraphBackGround:screen_x];
    [self drawTHPGraph:screen_x];
}
/********************************************************************************
 *drawTem
 ********************************************************************************/
-(void)drawTem:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_temp_value[i-1];
    y0 = -r0*2 + 200;
    float r1 = (float)_temp_value[i];
    y1 = -r1*2 + 200;
    [self setColor_r:255 g:0 b:0];
     CGContextSetLineWidth(_context, 3.0);
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawHum
 ********************************************************************************/
-(void)drawHum:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_humi_value[i-1];
    y0 =  -r0*2 + 300;
    float r1 = (float)_humi_value[i];
    y1 =  -r1*2  + 300;
    [self setColor_r:0 g:0 b:255];
     CGContextSetLineWidth(_context, 3.0f);
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawATM
 ********************************************************************************/
-(void)drawATM:(float)x0 x1:(float)x1  index:(int)i
{
    float y0 , y1;
    float r0 = (float)_atom_value[i-1];
    y0 = r0 / 2 + 160;
    float r1 = (float)_atom_value[i];
    y1 = r1 / 2 + 160;
    [self setColor_r:0 g:0 b:255];
    [self drawLine_x0:x0 y0:y0 x1:x1 y1:y1];
}
/********************************************************************************
 *drawTHPGraph
 ********************************************************************************/
-(void)drawTHPGraph:(float)ScreenWidth
{
    float x0 , x1;
    float width = (ScreenWidth-70)/ARRAY_MAX;
    for(int i=1;i<index;i++){
        x0 = (i-1)*width+30;
        x1 = i*width+30;
        [self drawTem:x0 x1:x1 index:i];
        [self drawHum:x0 x1:x1 index:i];
    }
}
/********************************************************************************
 *getAccelX
 ********************************************************************************/
-(void)getTEM:(float)tem
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _temp_value[i+1] = _temp_value[i];
    }
    _temp_value[0] = tem;
}
/********************************************************************************
 *getAccelY
 ********************************************************************************/
-(void)getHUM:(float)hum
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _humi_value[i+1] = _humi_value[i];
    }
    _humi_value[0] = hum;
}
/********************************************************************************
 *getAccelZ
 ********************************************************************************/
-(void)getATM:(float)atm
{
    for(int i=ARRAY_MAX-2;i>=0;i--){
        _atom_value[i+1] = _atom_value[i];
    }
    _atom_value[0] = atm;
}
/********************************************************************************
 *deleteDatas
 ********************************************************************************/
-(void)deleteDatas
{
    for(int i=0;i<ARRAY_MAX;i++){
        _temp_value[i] = 0;
        _humi_value[i] = 0;
        _atom_value[i] = 0;
        index = 0;
    }
}
/********************************************************************************
 *increaseIndex
 ********************************************************************************/
-(void)increaseIndex
{
    if(index <ARRAY_MAX)index++;
    
}

@end
