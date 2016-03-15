/********************************************************************************
 *  Copyright(c 2014 Braveridge Co., Ltd. All Rights Reserved
 ********************************************************************************/


#import "Ap_6AxisViewController.h"
@import CoreBluetooth;

#define SixAxisServiceUUID                      @"45351530-0FD8-5FB5-5148-3027069B3FD9"
#define QuaternionCharacteristicUUID            @"45351532-0FD8-5FB5-5148-3027069B3FD9"
#define ModeCharacteristicUUID                  @"45351535-0FD8-5FB5-5148-3027069B3FD9"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define SCALE (2.0f * M_PI)

#define  QUO_BASE_VALUE                         2147483648
#define  QUOTIENT_VALUE                         1073741824.0

GLfloat gCubeVertexData[216] =
{
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


@interface Ap_6AxisViewController ()<CBCentralManagerDelegate>
{
    GLfloat _rotation;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLKMatrix4 modelViewMatrix1;
    GLKMatrix4 modelViewMatrix2;
    CGPoint _touchBegan;
    CGPoint _touchFinished;
    GLfloat eyeDist;
    GLKQuaternion cquat;
    GLKQuaternion tquat;
    GLKMatrix4 rotMat;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong , nonatomic) CBCentralManager* centralManager;
@property (strong , nonatomic) CBPeripheral*     connectedPeripheral;

- (void)setupGL;
- (void)tearDownGL;
@end

@implementation Ap_6AxisViewController

/********************************************************************************
 *viewDidLoad
 ********************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    cquat = GLKQuaternionIdentity;
    tquat = GLKQuaternionIdentity;
    rotMat = GLKMatrix4MakeWithQuaternion(cquat);
    eyeDist = -10.0f;
    [self setupGL];
}
/********************************************************************************
 *startScan
 ********************************************************************************/
-(void)startScan
{
    NSDictionary* options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
    NSArray* scan_service = [NSArray arrayWithObjects:[CBUUID UUIDWithString:SixAxisServiceUUID] , nil];
    [self.centralManager scanForPeripheralsWithServices:scan_service options:options];
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
 *writeValueForService
 ********************************************************************************/
-(void) writeValueForService:(NSString*)serviceUUIDString characteristicUUID:(NSString*)characteristicUUIDString peripheral:(CBPeripheral *)aPeripheral data:(NSData*)data writeType:(CBCharacteristicWriteType)writeType
{
    if ( aPeripheral.state != CBPeripheralStateConnected ) {
        return;
    }
    CBUUID *serviceUUID = [CBUUID UUIDWithString:serviceUUIDString];
    
    CBService* found_service = nil;
    for(int i = 0; i < aPeripheral.services.count; i++) {
        CBService *service = [aPeripheral.services objectAtIndex:i];
        if ([serviceUUID isEqual:service.UUID]) found_service = service;
    }
    if ( !found_service )   return;
    
    CBUUID *characteristicUUID       = [CBUUID UUIDWithString:characteristicUUIDString];
    CBCharacteristic *found_characteristic = nil;
    for(int i=0; i < found_service.characteristics.count; i++) {
        CBCharacteristic *characteristic = [found_service.characteristics objectAtIndex:i];
        if ([characteristicUUID isEqual:characteristic.UUID]) found_characteristic = characteristic;
    }
    if ( !found_characteristic )  return;
    [aPeripheral writeValue:data forCharacteristic:found_characteristic type:writeType];
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
    NSString* str_uuid = [self getAdvertisementServiceUUID:advertisementData];
    NSString* str_name = [self getAdvertisementLocalName:advertisementData];
        
    if([str_uuid isEqualToString:SixAxisServiceUUID] ){
        self.DeviceName.text = str_name;
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:self.connectedPeripheral options:nil];
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
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral  error:(NSError *)error
{
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
        }else{
            if([aChar.UUID isEqual:[CBUUID UUIDWithString:ModeCharacteristicUUID] ]){
                uint8_t u_data[] = {0x01,};
                NSData* data = [NSData dataWithBytes:u_data length:1];
                [self writeValueForService:SixAxisServiceUUID characteristicUUID:ModeCharacteristicUUID peripheral:self.connectedPeripheral data:data writeType:CBCharacteristicWriteWithResponse];
            }
        }
    }
}
/********************************************************************************
 *takequoternionValue
 ********************************************************************************/
-(uint32_t)takequoternionValue:(NSString*)quoternion
{
    uint32_t result_value;
    NSString *s_1 , *s_2 , *s_3 , *s_4;
    unsigned int q_1 , q_2 , q_3 , q_4;
    s_1 = [quoternion substringWithRange:NSMakeRange(0, 2)];
    s_2 = [quoternion substringWithRange:NSMakeRange(2, 2)];
    s_3 = [quoternion substringWithRange:NSMakeRange(4, 2)];
    s_4 = [quoternion substringWithRange:NSMakeRange(6, 2)];
    
    [ [NSScanner scannerWithString:s_1] scanHexInt:&q_1 ];
    [ [NSScanner scannerWithString:s_2] scanHexInt:&q_2 ];
    [ [NSScanner scannerWithString:s_3] scanHexInt:&q_3 ];
    [ [NSScanner scannerWithString:s_4] scanHexInt:&q_4 ];
    
    result_value = (int32_t)( ( 0xFF000000 & ( q_1 << 24) ) | ( 0x00FF0000 & ( q_2 << 16) ) | ( 0x0000FF00 & (q_3 << 8) ) | ( 0x000000FF & (q_4 << 0) ) );
    return result_value;
}
/**********************************************************************************
 *peripheral didUpdateValueForCharacteristic
 *********************************************************************************/
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    long long uquo_w , uquo_x , uquo_y , uquo_z;
    float quo_w , quo_x  , quo_y , quo_z;
    if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:QuaternionCharacteristicUUID] ] ){
        NSString* str_quoternion = [NSString stringWithFormat:@"%@" , characteristic.value];
        NSString* str_w = [str_quoternion substringWithRange:NSMakeRange(1, 8)];
        NSString* str_x = [str_quoternion substringWithRange:NSMakeRange(10, 8)];
        NSString* str_y = [str_quoternion substringWithRange:NSMakeRange(19, 8)];
        NSString* str_z = [str_quoternion substringWithRange:NSMakeRange(28, 8)];
        
        uquo_w = [self takequoternionValue:str_w];
        uquo_x = [self takequoternionValue:str_x];
        uquo_y = [self takequoternionValue:str_y];
        uquo_z = [self takequoternionValue:str_z];
        
        if(uquo_w > QUO_BASE_VALUE){
            uquo_w = (uquo_w - (QUO_BASE_VALUE * 2) );
        }
        quo_w = (float)uquo_w / QUOTIENT_VALUE;
        if(uquo_x > QUO_BASE_VALUE){
            uquo_x = (uquo_x - (QUO_BASE_VALUE * 2) );
        }
        quo_x = (float)uquo_x / QUOTIENT_VALUE;
        if(uquo_y > QUO_BASE_VALUE){
            uquo_y = (uquo_y - (QUO_BASE_VALUE * 2) );
        }
        quo_y = (float)uquo_y / QUOTIENT_VALUE;
        if(uquo_z > QUO_BASE_VALUE){
            uquo_z = (uquo_z - (QUO_BASE_VALUE * 2) );
        }
        quo_z = (float)uquo_z / QUOTIENT_VALUE;
        GLKQuaternion dquat = GLKQuaternionMake(quo_x, quo_y, quo_z, quo_w);
        
        tquat = GLKQuaternionMultiply(dquat, cquat);
        rotMat = GLKMatrix4MakeWithQuaternion(tquat);
    }
}
/********************************************************************************
 *dealloc
 ********************************************************************************/
- (void)dealloc
{
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}
/********************************************************************************
 *didReceiveMemoryWarning
 ********************************************************************************/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        [self tearDownGL];
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}
/********************************************************************************
 *setupGL
 ********************************************************************************/
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float)*6, BUFFER_OFFSET(12));
    glBindVertexArrayOES(0);
}
/********************************************************************************
 *tearDownGL
 ********************************************************************************/
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    self.effect = nil;
}
/********************************************************************************
 *update
 ********************************************************************************/
- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 300.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, eyeDist);
    baseModelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, rotMat);
    modelViewMatrix1 = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    modelViewMatrix1 = GLKMatrix4Rotate(modelViewMatrix1, _rotation, -1.0f, -1.0f, 1.0f);
    modelViewMatrix1 = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix1);
}
/********************************************************************************
 *glkView
 ********************************************************************************/
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindVertexArrayOES(_vertexArray);
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    self.effect.transform.modelviewMatrix = modelViewMatrix1;
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
