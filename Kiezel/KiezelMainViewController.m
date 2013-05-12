//
//  KiezelMainViewController.m
//  Kiezel
//
//  Copyright (c) 2013 aleksandyr. All rights reserved.
//

#import "KiezelMainViewController.h"

#import "RawPebbleController.h"

@interface KiezelMainViewController ()
@property (nonatomic, readwrite, retain) NSMutableArray *accessoryList;

@property (nonatomic, readwrite, retain) EAAccessory *pebble;

@property (nonatomic, strong) IBOutlet UILabel *deviceLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl *protocolBar;

@property (nonatomic, readwrite, retain) RawPebbleController *rawPebbleController;
@end

@implementation KiezelMainViewController

@synthesize accessoryList;
@synthesize deviceLabel;
@synthesize pebble;
@synthesize rawPebbleController;
@synthesize protocolBar;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    for(EAAccessory *accessory in accessoryList) {
        [self connectAccessory:accessory];
    }
}

#pragma mark Accessory Handlers

- (void)connectAccessory:(EAAccessory *)accessory {
    NSString *name = accessory.name;
    NSLog(@"CONNECT: %@", name);
    
    if(rawPebbleController != nil) {
        [rawPebbleController closeSession];
    }
    
    if([name hasPrefix:@"Pebble "] && name.length == 11) {
        [deviceLabel setText:name];
        pebble = accessory;
        rawPebbleController = [RawPebbleController sharedController];
        
        NSArray *protocolStrings = [pebble protocolStrings];
        for(NSString *protocolString in protocolStrings) {
            NSLog(@"PROTOCOL: %@", protocolString);
        }
        
        NSString *protocol;
        
        switch(protocolBar.selectedSegmentIndex) {
            case 0:
                protocol = @"com.getpebble.public";
                break;
            case 1:
                protocol = @"com.getpebble.private";
                break;
            default:
                NSLog(@"Unknown protocol identifier %d, defaulting to public.", protocolBar.selectedSegmentIndex);
                protocol = @"com.getpebble.public";
                break;
        }
        
        [rawPebbleController setupControllerForAccessory:pebble withProtocolString:protocol];
        [rawPebbleController openSession];
        
    }

}

- (void)disconnectAccessory:(EAAccessory *)accessory {
    NSString *name = accessory.name;
    NSLog(@"DISCONNECT: %@", name);
    
    if([name isEqualToString:[deviceLabel text]]) {
        [deviceLabel setText:@""];
        [rawPebbleController closeSession];
        pebble = nil;
        rawPebbleController = nil;
    }
}

#pragma mark Accessory Events

- (void)_accessoryDidConnect:(NSNotification *)notification {
    [self connectAccessory:[[notification userInfo] objectForKey:EAAccessoryKey]];
}

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    [self disconnectAccessory:[[notification userInfo] objectForKey:EAAccessoryKey]];
}

#pragma mark Button Events

- (IBAction)doPing:(id)sender
{
    //TODO: Build a LibPebbleController!
    //From libPebble, 0005 07d1 00deadbeef is a ping
    NSLog(@"Do a ping!");
    uint8_t ping[] = {
        0x00, 0x05, //Length of payload
        0x07, 0xd1, //Code for command (not counted in payload)
        0x00, 0xde, 0xad, 0xbe, 0xef
    };
    [rawPebbleController writeData:[NSData dataWithBytes:ping length:9]];
}

- (IBAction)doChangeProtocol:(id)sender
{
    if(pebble != nil) {
        [self connectAccessory:pebble];
    }
}


#pragma mark Other Events

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
