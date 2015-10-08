//
//  BackendlessBeacon.m
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

#import "BackendlessBeacon.h"
#import "Backendless.h"

@implementation BackendlessBeacon

-(id)init {
    
    if ( (self=[super init]) ) {
        _objectId = nil;
        _iBeaconProps = nil;
        _eddystoneProps = nil;
        _type = BEACON_UNKNOWN;
    }
    
    return self;
}

/*
 
 private Map<String, String> createIbeaconProps( String uuid, String majorVersion, String minorVersion )
 {
 Map<String, String> properties = new HashMap<String, String>( 3 );
 properties.put( BeaconConstants.IBEACON_UUID_STR, uuid );
 properties.put( BeaconConstants.IBEACON_MAJOR_STR, majorVersion );
 properties.put( BeaconConstants.IBEACON_MINOR_STR, minorVersion );
 
 return properties;
 }
 
 private Map<String, String> createEddystoneProps( String namespaceId, String instanceId )
 {
 Map<String, String> properties = new HashMap<String, String>( 2 );
 properties.put( BeaconConstants.EDDYSTONE_NAMESPACE_ID_STR, namespaceId );
 properties.put( BeaconConstants.EDDYSTONE_INSTANCE_ID_STR, instanceId );
 
 return properties;
 }
 
 private Map<String, String> createEddystoneExtraProps( String telemetry, String batteryMil, String temperatureCels,
 String PduCount, String upTime )
 {
 Map<String, String> properties = new HashMap<String, String>( 5 );
 properties.put( BeaconConstants.EDDYSTONE_TELEMETRY_VERSION_STR, telemetry ); // telemetry Version
 properties.put( BeaconConstants.EDDYSTONE_BATTERY_STR, batteryMil ); // battery MilliVolts
 properties.put( BeaconConstants.EDDYSTONE_TEMPERATURE_STR, temperatureCels ); // temperature Celsius
 properties.put( BeaconConstants.EDDYSTONE_PDU_COUNT_STR, PduCount); //PDU cont
 properties.put( BeaconConstants.EDDYSTONE_UPTIME_STR, upTime ); // up time
 
 return properties;
 }
 
 */

-(id)initWithType:(BeaconTypeEnum)type beacon:(id)beacon {
    
    if ( (self=[super init]) ) {

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        switch (type) {
            case BEACON_IBEACON: {
                if ([beacon isKindOfClass:CLBeacon.class]) {
                    CLBeacon *_beacon = beacon;
                    _type = type;
                    _objectId = _beacon.proximityUUID.UUIDString;
                    _iBeaconProps = @{IBEACON_UUID_STR:_objectId, IBEACON_MAJOR_STR:_beacon.major.stringValue, IBEACON_MINOR_STR:_beacon.minor.stringValue};
                }
                break;
            }
            case BEACON_EDDYSTONE: {
                _type = type;
                break;
            }
            default: {
                _type = BEACON_UNKNOWN;
                break;
            }
        }
#endif
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC BackendlessBeacon"];
    
    [_objectId release];
    [_iBeaconProps release];
    [_eddystoneProps release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark overwrided NSObject Methods

-(BOOL)isEqual:(id)object {
    
    if (!object || ![object isKindOfClass:self.class])
        return NO;
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    BackendlessBeacon *beacon = (BackendlessBeacon *)object;
    switch (_type) {
        case BEACON_IBEACON: {
            return [self.iBeaconProps isEqualToDictionary:beacon.iBeaconProps];
            }
        case BEACON_EDDYSTONE: {
            return [self.eddystoneProps isEqualToDictionary:beacon.eddystoneProps];
        }
        default: {
            return NO;
        }
    }
#else
    return NO;
#endif
}

@end
