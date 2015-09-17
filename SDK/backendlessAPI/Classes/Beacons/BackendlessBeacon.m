//
//  BackendlessBeacon.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 9/15/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//

#import "BackendlessBeacon.h"

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
        
        switch (type) {
            case BEACON_IBEACON: {
                if ([beacon isKindOfClass:CLBeacon.class]) {
                    CLBeacon *_beacon = beacon;
                    _type = type;
                    _iBeaconProps = @{IBEACON_UUID_STR:_beacon.proximityUUID, IBEACON_MAJOR_STR:_beacon.major.stringValue, IBEACON_MINOR_STR:_beacon.minor.stringValue};
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
    }
    
    return self;    
}

@end
