//
//  BackendlessBeacon.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2015 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define BEACON_SERVICE_NAME @"beacons"

#define BEACON_DISCOVERY @"beacon-discovery"
#define BEACON_FREQUENCY @"beacon-frequency"
#define BEACON_DEFAULT_FREQUENCY 0
#define BEACON_DEFAULT_DISCOVERY NO
#define BEACON_DEFAUTL_DISTANCE_CHANGE 1

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
    BEACON_IBEACON,
    BEACON_EDDYSTONE,
    BEACON_UNKNOWN = -1
} BeaconTypeEnum;

@interface BackendlessBeacon : NSObject <NSCopying>
@property (strong, nonatomic, readonly) NSString *objectId;
@property (strong, nonatomic, readonly) NSDictionary<NSString*,NSString*> *iBeaconProps;
@property (strong, nonatomic, readonly) NSDictionary<NSString*,NSString*> *eddystoneProps;
@property (readonly) BeaconTypeEnum type;

-(id)initWithType:(BeaconTypeEnum)type beacon:(id)beacon;
-(id)initWithClass:(id)beacon;
-(id)initWithBackendlessBeacon:(BackendlessBeacon *)beacon;
-(NSString *)key;

@end
