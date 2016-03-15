/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import <UIKit/UIKit.h>


#define ARRAY_MAX   60

@interface AP_THPGraphic : UIView
{
    CGContextRef _context;
    float       _temp_value[ARRAY_MAX];
    float       _humi_value[ARRAY_MAX];
    float       _atom_value[ARRAY_MAX];
}


-(void)setContext:(CGContextRef)context;
-(void)setColor_r:(int)r g:(int)g b:(int)b;
-(void) setLineWidth:(float)width;
-(void)drawRect_x:(float)x y:(float)y w:(float)w h:(float)h;
-(void)fillRect_x:(float)x y:(float)y w:(float)w h:(float)h;
-(void)deleteDatas;
-(void)getATM:(float)atm;
-(void)getHUM:(float)hum;
-(void)getTEM:(float)tem;
-(void)increaseIndex;

@end
