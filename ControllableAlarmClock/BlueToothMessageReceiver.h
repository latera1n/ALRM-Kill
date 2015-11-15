//
//  BlueToothMessageReceiver.h
//  ControllableAlarmClock
//
//  Created by DengYuchi on 11/14/15.
//  Copyright © 2015 HackSC15. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueToothMessageSender.h"

@interface BlueToothMessageReceiver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

- (instancetype)init;

@end
