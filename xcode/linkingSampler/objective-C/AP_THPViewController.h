/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import <UIKit/UIKit.h>


@interface AP_THPViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *SearchingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *SearchingAnimation;
@property (strong, nonatomic) IBOutlet UILabel *temp_label;
@property (strong, nonatomic) IBOutlet UILabel *hum_label;
@property (strong, nonatomic) IBOutlet UILabel *atm_label;
@property (strong, nonatomic) IBOutlet UILabel *rssiLabel;


@end
