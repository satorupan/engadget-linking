/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/

#import "AP_3AxisViewController.h"
@import CoreBluetooth;


#define ADXL_SERVICE_UUID               @"EBAD3530-226C-4EBB-A153-A3BC9567057D"
#define ADXL_3AXIS_CHAR                 @"EBAD3531-226C-4EBB-A153-A3BC9567057D"
#define COORDINATE_HEIGHT               150

@interface AP_3AxisViewController () <CBCentralManagerDelegate>
{
    short                    accel_x_data;
    short                    accel_y_data;
    short                    accel_z_data;
    AP_3AxisGraphic*                _graphic;
}
@property (strong , nonatomic) CBCentralManager* centralManager;
@property (strong , nonatomic) CBPeripheral*     connectedPeripheral;
@end

@implementation AP_3AxisViewController

/********************************************************************************
 *viewDidLoad
 ********************************************************************************/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    CGRect rect;
    rect.origin = self.view.bounds.origin;
    rect.size.height = self.view.bounds.size.height-COORDINATE_HEIGHT;
    rect.size.width  = self.view.bounds.size.width;
    
    _graphic = [ [AP_3AxisGraphic alloc] initWithFrame:rect];
    [self.view addSubview:_graphic];
    self.SearchingAnimation.hidesWhenStopped = YES;
    [self.SearchingAnimation startAnimating];
    
}
/********************************************************************************
 *didReceiveMemoryWarning
 ********************************************************************************/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/********************************************************************************
 *startScan
 ********************************************************************************/
-(void)startScan
{
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
    [self.centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:ADXL_SERVICE_UUID]] options:options];
}
/********************************************************************************
 *setup
 ********************************************************************************/
-(void) setup
{
    self.centralManager = [ [ CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}
/********************************************************************************
 *centralManagerDidUpdateState
 ********************************************************************************/
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state == CBCentralManagerStatePoweredOn){
        [self startScan];
    }
}
/********************************************************************************
 *getAdvertisementLocalName
 ********************************************************************************/
-(NSString*)getAdvertisementLocalName:(NSDictionary *)advertisementData
{
    NSString* local_name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    return local_name;
}
/********************************************************************************
 *getAdvertisementServiceUUID
 ********************************************************************************/
-(NSString *)getAdvertisementServiceUUID:(NSDictionary *)advertisementData
{
    NSArray* advertisementUUID = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSData* advUUIDObj = [advertisementUUID objectAtIndex:0];
    NSString* str_uuid = [NSString stringWithFormat:@"%@",advUUIDObj];
    return str_uuid;
}
/********************************************************************************
 *centralManager didDiscoverPeripheral
 ********************************************************************************/
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString* device_name = [self getAdvertisementLocalName:advertisementData];
    NSString* device_uuid = [self getAdvertisementServiceUUID:advertisementData];
    if( [device_uuid isEqualToString:ADXL_SERVICE_UUID]){
        self.SearchingLabel.text = device_name;
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:self.connectedPeripheral options:nil];
        [self.SearchingAnimation stopAnimating];
    }
}
/********************************************************************************
 *centralManager didConnectPeripheral
 ********************************************************************************/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil ];
}

/**********************************************************************************
 *peripheral didDiscoverServices
 *********************************************************************************/
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    NSArray *services=aPeripheral.services;
    for (CBService *aService in services)
    {
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}
/**********************************************************************************
 *centralManager didDisconnectPeripheral
 *********************************************************************************/
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral  error:(NSError *)error
{
    [self.SearchingAnimation startAnimating];
    self.SearchingLabel.text = @"Searching...";
    [_graphic deleteDatas];
    [_graphic removeFromSuperview];
    
    CGRect rect;
    rect.origin = self.view.bounds.origin;
    rect.size.height = self.view.bounds.size.height-COORDINATE_HEIGHT;
    rect.size.width  = self.view.bounds.size.width;
    _graphic = [ [AP_3AxisGraphic alloc] initWithFrame:rect];
    [self.view addSubview:_graphic];
    
    [self startScan];
}
/**********************************************************************************
 *centralManager didFailToConnectPeripheral
 *********************************************************************************/
- (void) centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    [self.SearchingAnimation startAnimating];
    self.SearchingLabel.text = @"Searching...";
    [self startScan];
}
/**********************************************************************************
 *peripheral didDiscoverCharacteristicsForService
 *********************************************************************************/
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics)
    {
        if(aChar.properties & (CBCharacteristicPropertyNotify|CBCharacteristicPropertyNotifyEncryptionRequired)){
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}
/**********************************************************************************
 *peripheral didUpdateValueForCharacteristic
 *********************************************************************************/
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    unsigned int x_data , y_data,z_data;
    int16_t accel_x , accel_y , accel_z;
    NSString *str_x_data,*str_y_data, *str_z_data;
    
    if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:ADXL_3AXIS_CHAR] ]){
        NSString* str_data = [NSString stringWithFormat:@"%@",characteristic.value];
        NSString* str_temp = [str_data stringByReplacingOccurrencesOfString:@" " withString:@""];
        str_temp = [str_temp stringByReplacingOccurrencesOfString:@"<" withString:@""];
        str_temp = [str_temp stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        //x axis data
        str_x_data = [ str_temp substringWithRange:NSMakeRange(0, 4)];
        [ [NSScanner scannerWithString:str_x_data] scanHexInt:&x_data];
        accel_x = x_data;
        [_graphic getAccelX:accel_x];
        
        //y axis data
        str_y_data = [ str_temp substringWithRange:NSMakeRange(4, 4)];
        [ [NSScanner scannerWithString:str_y_data] scanHexInt:&y_data];
        accel_y = y_data;
        [_graphic getAccelY:accel_y];
        
        //z axis data
        str_z_data = [ str_temp substringWithRange:NSMakeRange(8, 4)];
        [ [NSScanner scannerWithString:str_z_data] scanHexInt:&z_data];
        accel_z = z_data;
        [_graphic getAccelZ:accel_z];
        [_graphic setNeedsDisplay];
        
        self.accel_x_value.text = [NSString stringWithFormat:@"%0.2fg" , [_graphic getAccelXAverage]];
        self.accel_y_value.text = [NSString stringWithFormat:@"%0.2fg" , [_graphic getAccelYAverage]];
        self.accel_z_value.text = [NSString stringWithFormat:@"%0.2fg" , [_graphic getAccelZAverage]];
        
        [aPeripheral readRSSI];
    }
}
/********************************************************************************
 *peripheralDidUpdateRSSI
 ********************************************************************************/
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString* str_rssi = [peripheral.RSSI stringValue];
    NSInteger rssi = [str_rssi integerValue];
    self.rssi_label.text = [NSString stringWithFormat:@"Rssi : %lddpm" , (long)rssi];
}

@end
