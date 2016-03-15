/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import <UIKit/UIKit.h>
#import "AP_3AxisGraphic.h"

@interface AP_3AxisViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *SearchingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *SearchingAnimation;
//@property (strong, nonatomic) IBOutlet UILabel *EEPROM_TEST_RESULT_LABEL;


@property (strong, nonatomic) IBOutlet UILabel *accel_x_value;
@property (strong, nonatomic) IBOutlet UILabel *accel_y_value;
@property (strong, nonatomic) IBOutlet UILabel *accel_z_value;
@property (strong, nonatomic) IBOutlet UILabel *rssi_label;

@end
