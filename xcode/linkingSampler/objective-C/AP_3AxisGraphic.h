/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import <UIKit/UIKit.h>

#define ARRAY_MAX   180

@interface AP_3AxisGraphic : UIView
{
    CGContextRef _context;
    NSInteger       _accel_x[ARRAY_MAX];
    NSInteger       _accel_y[ARRAY_MAX];
    NSInteger       _accel_z[ARRAY_MAX];
}

-(void)setContext:(CGContextRef)context;
-(void)setColor_r:(int)r g:(int)g b:(int)b;
-(void) setLineWidth:(float)width;
-(void)drawRect_x:(float)x y:(float)y w:(float)w h:(float)h;
-(void)fillRect_x:(float)x y:(float)y w:(float)w h:(float)h;
-(void)deleteDatas;
-(float)getAccelXAverage;
-(float)getAccelYAverage;
-(float)getAccelZAverage;
-(void)getAccelX:(NSInteger)accel_x;
-(void)getAccelY:(NSInteger)accel_y;
-(void)getAccelZ:(NSInteger)accel_z;

@end
