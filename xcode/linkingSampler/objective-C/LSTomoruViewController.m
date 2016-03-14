/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 *
 * ------注意----------
 * 1.Linkingデバイスとの接続後、切断と接続が繰り返される場合はLinkingデバイスの電源を落とし
 *   再度起動させてください.(電池抜き差し)
 *
 * 2.Linkingデバイスとの接続後、メッセージ送受信ができない場合(デリゲートの通知がこない場合等)
 *   端末の設定アプリより、Bluetoothを選択し,記憶しているデバイス情報をリセットすることで改善する場合があります。
 */

#import "LSTomoruViewController.h"
#import <LinkingLibrary/LinkingLibrary.h>

#import <TargetConditionals.h>


@interface LSTomoruViewController () <BLEConnecterDelegate>

#if (TARGET_IPHONE_SIMULATOR)
#else
// 実機で動作している場合のコード
@property (nonatomic)BLEConnecter *connecter;
@property (nonatomic)CBPeripheral *peripheral;
@property (nonatomic)BLEDeviceSetting *device;
#endif


@property (nonatomic)BOOL canDiscover;
@property (nonatomic)BOOL canConnect;
@property (nonatomic)BOOL canLightning;

@property (weak, nonatomic) IBOutlet UILabel *message;    // 検索ボタン
@property (weak, nonatomic) IBOutlet UITextField *tomoruID;    // 検索ボタン

@property (weak, nonatomic) IBOutlet UIButton *searchButton;    // 検索ボタン
@property (weak, nonatomic) IBOutlet UIButton *connectButton;   // 接続ボタン
@property (weak, nonatomic) IBOutlet UIButton *changeLedSettingButton; // LEDパターン変更ボタン
@property (weak, nonatomic) IBOutlet UIButton *lightningButton; // LED点灯ボタン
@property int settingPatternNumber; // 変更するLEDのパターンナンバー
@end

@implementation LSTomoruViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    _message.text=@"Simulatorでは動きません。実機にてご確認ください";
#else
    // 実機で動作している場合のコード
    
    // インスタンス生成
    self.connecter = [BLEConnecter sharedInstance];
    // デリゲートの登録
    [self.connecter addListener:self deviceUUID:nil];
#endif
    // 接続ボタン非活性
    self.connectButton.enabled = NO;
    // LEDパターン変更ボタン非活性
    self.changeLedSettingButton.enabled = NO;
    // LED点灯ボタン非活性
    self.lightningButton.enabled = NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    
#else
    // 実機で動作している場合のコード
    // デリゲートの削除
    [self.connecter removeListener:self deviceUUID:nil];
    
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 検索ボタンタップ時の処理
- (IBAction)searchButtonTap:(id)sender {
    
    // BluetoothがONの場合
    if([self canDiscoverDevice]){
        
#if (TARGET_IPHONE_SIMULATOR)
        // シミュレータで動作している場合のコード
        
#else
        // 実機で動作している場合のコード
        // デバイス検索を開始する
        [self.connecter scanDevice];
        
#endif
    }
}

-(BOOL)canDiscoverDevice {
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    return NO;
#else
    // 実機で動作している場合のコード
    return self.connecter.canDiscovery;
    
#endif
}

// デバイス検索が成功した時に呼ばれるデリゲート
-(void)didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    
    NSLog(@"検知したデバイス名:%@",peripheral.name);
    
    //接続したいデバイスを選別(view内の情報を取得。に接続したいTomoruの名称を入力して比較)
    //if([peripheral.name isEqualToString:@"Tomoru[デバイス番号]"]){
    if([peripheral.name isEqualToString:_tomoruID.text]){
        
#if (TARGET_IPHONE_SIMULATOR)
        // シミュレータで動作している場合のコード
#else
        // 実機で動作している場合のコード
        // BLEDeviceSetting(デバイス情報が登録されているクラス)をセットする
        self.device = [self.connecter getDeviceByPeripheral:peripheral];
        // 発見したペリフェラル
        self.peripheral = peripheral;
        // デバイスを発見したので接続ボタンを活性
        self.connectButton.enabled = YES;
#endif
    }
    
}

// 接続ボタンタップ時の処理
- (IBAction)connectButtonTap:(id)sender {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
#else
    // 実機で動作している場合のコード
    // 発見したデバイスに接続する
    [self.connecter connectDevice:self.peripheral];
#endif
}

// 発見したデバイス情報の取得シーケンス完了のデリゲート
-(void)didDeviceInitialFinished:(CBPeripheral *)peripheral {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
#else
    // 実機で動作している場合のコード
    self.canLightning = [peripheral.identifier.UUIDString isEqualToString:self.peripheral.identifier.UUIDString];
#endif
    
    if(self.canLightning){
        
        // LED点灯ボタンを活性
        self.lightningButton.enabled = YES;
        
        // LEDパターン変更ボタン活性
        self.changeLedSettingButton.enabled = YES;
    }
}

// LED点灯ボタンタップ時の処理
- (IBAction)lightningButtonTap:(id)sender {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    
#else
    // 実機で動作している場合のコード
    if(self.device.deviceId){
        
        // LEDを点灯させる(現在設定されている設定値で点灯します)
        [[BLERequestController sharedInstance] sendGeneralInformation:nil text:nil appName:nil appNameLocal:nil package:nil notifyId:0 notifyCategoryId:0 ledSetting:YES vibrationSetting:NO led:nil vibration:nil deviceId:self.device.deviceId deviceUId:nil peripheral:self.peripheral disconnect:NO];
    }
    
#endif
}


// LED変更のボタンをタップ
- (IBAction)changeLedSettingButtonTap:(id)sender {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"パターン変更"
                                                                             message:@"カラーパターンを変更します"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    
#if (TARGET_IPHONE_SIMULATOR)
#else
    // 実機で動作している場合のコード
    NSString * title;
    int countColorPattern = [[self.device.settingInformationDataLED objectForKey:@"patterns"]intValue];
    for (int i = 0; i < countColorPattern; i++) {
        
        if(i == 0){
            title = @"OFF";
        }else{
            title = [NSString stringWithFormat:@"%d",i];
        }
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           
                                                           int num = [action.title intValue];
                                                           
                                                           [self changeLEDSetting:num];
                                                       }];
        [alertController addAction:action];
        
        
    }
    
#endif
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"キャンセル"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       
                                                   }];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
    
}


//LEDのパターンを選択したパターンに変更する
-(void)changeLEDSetting:(int)num {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    
#else
    // 実機で動作している場合のコード
    
    //設定値1はOFFの設定の為、設定値2をパターン1として実装。
    self.settingPatternNumber = num +1;
    
    //現在の設定値をコピーしパターンだけ変更
    NSMutableDictionary*dic = [self.device.settingInformationDataLED mutableCopy];
    [dic setObject:[NSNumber numberWithInt:self.settingPatternNumber] forKey:@"settingPatternNumber"];
    
    //パターンだけ変更したデータをデバイスに送信
    [[BLERequestController sharedInstance] setSelectSettingInformationWithLED:[dic copy] vibration:nil peripheral:self.peripheral disconnect:NO];
    
#endif
}

//LEDのパターン変更完了のデリゲート
-(void)sendSelectSettingInformationRespSuccessDelegate:(CBPeripheral *)peripheral {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    
#else
    // 実機で動作している場合のコード
    
    //設定の変更が反映されているかデバイス情報を取得
    [[BLERequestController sharedInstance] getSettingInformationMessage:self.peripheral disconnect:NO];
#endif
    
}

-(void)getSettingInformationRespSuccessDelegate:(CBPeripheral *)peripheral {
    
#if (TARGET_IPHONE_SIMULATOR)
    // シミュレータで動作している場合のコード
    
#else
    // 実機で動作している場合のコード
    
    //設定したパターンの値と一致していれば変更完了
    if([[self.device.settingInformationDataLED objectForKey:@"settingPatternNumber"]intValue] == self.settingPatternNumber){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"確認"
                                                                                 message:@"設定を変更しました"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            
                                                        }];
        [alertController addAction:confirm];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
#endif
    
    
}





/*
 繋がらない、メッセージが送信できていない場合は下記デリゲートを確認
 ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
 */



//接続に失敗した
-(void)didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"接続に失敗しました(%@)",peripheral.name);
    
}

//デバイスが切断された
-(void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"%@が切断されました",peripheral.name);
    
}


//書き込みが失敗した
-(void)didFailToWrite:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"書き込みが失敗しました:(%@)",error);
}

@end
