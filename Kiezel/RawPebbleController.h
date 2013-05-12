//
//  RawPebbleController.h
//  Kiezel
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString *EASessionDataReceivedNotification;

@interface RawPebbleController : NSObject <EAAccessoryDelegate, NSStreamDelegate>

+ (RawPebbleController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;

@property (nonatomic, readonly, retain) EAAccessory *accessory;
@property (nonatomic, readonly, retain) NSString *protocolString;

@end
