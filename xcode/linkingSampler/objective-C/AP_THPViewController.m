
/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/


#import "AP_THPViewController.h"
#import "AP_THPGraphic.h"
@import CoreBluetooth;


#define AP_THP_SERVICE_UUID               @"2445AA20-5CA6-46BE-8A0F-58784154F5EE"
#define THP_CHARACTERISTIC_UUID           @"2445AA21-5CA6-46BE-8A0F-58784154F5EE"
#define COORDINATE_HEIGHT    150

@interface AP_THPViewController() <CBCentralManagerDelegate>
{
    float               _tem_data;
    float               _hum_data;
    float               _atom_data;
    AP_THPGraphic*             _graph;
}

@property (strong , nonatomic) CBCentralManager* centralManager;
@property (strong , nonatomic) CBPeripheral*     connectedPeripheral;
@end

@implementation AP_THPViewController
/********************************************************************************
 *viewDidLoad
 ********************************************************************************/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    self.SearchingAnimation.hidesWhenStopped = YES;
    [self.SearchingAnimation startAnimating];
    
    CGRect rect;
    rect.origin = self.view.bounds.origin;
    rect.size.height = self.view.bounds.size.height-COORDINATE_HEIGHT;
    rect.size.width  = self.view.bounds.size.width;
    _graph = [ [AP_THPGraphic alloc] initWithFrame:rect];
    [self.view addSubview:_graph];
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
    [self.centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:AP_THP_SERVICE_UUID]] options:options];
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
    
    if( [device_uuid isEqualToString:AP_THP_SERVICE_UUID]){
        self.SearchingLabel.text = device_name;
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:self.connectedPeripheral options:nil];
        [self.SearchingAnimation stopAnimating];
        [self.centralManager stopScan];
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
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    [self.SearchingAnimation startAnimating];
    
    self.SearchingLabel.text = @"Searching...";
    [_graph deleteDatas];
    [_graph removeFromSuperview];
    
    CGRect rect;
    rect.origin = self.view.bounds.origin;
    rect.size.height = self.view.bounds.size.height-COORDINATE_HEIGHT;
    rect.size.width  = self.view.bounds.size.width;
    _graph = [ [AP_THPGraphic alloc] initWithFrame:rect];
    [self.view addSubview:_graph];
    
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
/********************************************************************************
 *calcTHPSensorData
 ********************************************************************************/
-(void)calcTHPSensorData :(NSString*)value
{
    uint32_t tem = 0 , hum = 0 , atm = 0;
    NSString*   str_temp = [value substringWithRange:NSMakeRange(0, 4)];
    
    [ [NSScanner scannerWithString:str_temp] scanHexInt:&tem];
    _tem_data = (float)tem / 100;
    str_temp = [value substringWithRange:NSMakeRange(4, 4)];
    
    [ [NSScanner scannerWithString:str_temp] scanHexInt:&hum];
    _hum_data = (float)hum / 100;
    str_temp = [value substringWithRange:NSMakeRange(8, 4)];
    
    [ [NSScanner scannerWithString:str_temp] scanHexInt:&atm];
    _atom_data = (float)atm;
}
/**********************************************************************************
 *peripheral didUpdateValueForCharacteristic
 *********************************************************************************/
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:THP_CHARACTERISTIC_UUID] ])
    {
        NSString* str_char_value = [NSString stringWithFormat:@"%@" , characteristic.value];
        str_char_value = [str_char_value stringByReplacingOccurrencesOfString:@" " withString:@""];
        str_char_value = [str_char_value stringByReplacingOccurrencesOfString:@"<" withString:@""];
        str_char_value = [str_char_value stringByReplacingOccurrencesOfString:@">" withString:@""];
        [self calcTHPSensorData:str_char_value];
        
        [_graph getTEM:_tem_data];
        [_graph getHUM:_hum_data];
        [_graph getATM:_atom_data];
        [_graph increaseIndex];
        
        [_graph setNeedsDisplay];
        
        self.temp_label.text = [NSString stringWithFormat:@"%.2f°C" , _tem_data];
        self.hum_label.text = [NSString stringWithFormat:@"%.2f ％" , _hum_data];
        self.atm_label.text = [NSString stringWithFormat:@"%.0f hpa" , _atom_data];
    }
    [aPeripheral readRSSI];
}
/********************************************************************************
 *peripheralDidUpdateRSSI
 ********************************************************************************/
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString* str_rssi = [peripheral.RSSI stringValue];
    NSInteger rssi = [str_rssi integerValue];
    self.rssiLabel.text = [NSString stringWithFormat:@"%ld" , (long)rssi];
}

@end