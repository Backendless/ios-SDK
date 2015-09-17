//
//  BackendlessBeacon.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 9/15/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define BEACON_SERVICE_NAME @"beacons"
#define BEACON_SERVICE_VERSION @"1.0"

#define BEACON_DISCOVERY @"beacon-frequency"
#define BEACON_FREQUENCY @"beacon-discovery"
#define BEACON_DEFAULT_FREQUENCY 300
#define BEACON_DEFAULT_DISCOVERY YES

#define IBEACON_UUID_STR @"uuid"
#define IBEACON_MAJOR_STR @"majorVersion"
#define IBEACON_MINOR_STR @"minorVersion"
#define EDDYSTONE_NAMESPACE_ID_STR @"namespaceId"
#define EDDYSTONE_INSTANCE_ID_STR @"instanceId"
#define EDDYSTONE_TELEMETRY_VERSION_STR @"telemetryVersion"
#define EDDYSTONE_BATTERY_STR @"batteryMilliVolts"
#define EDDYSTONE_TEMPERATURE_STR @"temperatureCelsius"
#define EDDYSTONE_PDU_COUNT_STR @"pduCount"
#define EDDYSTONE_UPTIME_STR @"uptimeSeconds"

typedef enum {
    BEACON_IBEACON = 0x0215,
    BEACON_EDDYSTONE = 0xfeaa,
    BEACON_UNKNOWN = -1
} BeaconTypeEnum;

@interface BackendlessBeacon : NSObject
@property (strong, nonatomic, readonly) NSString *objectId;
@property (strong, nonatomic, readonly) NSDictionary *iBeaconProps;
@property (strong, nonatomic, readonly) NSDictionary *eddystoneProps;
@property (readonly) BeaconTypeEnum type;

-(id)initWithType:(BeaconTypeEnum)type beacon:(id)beacon;
@end
