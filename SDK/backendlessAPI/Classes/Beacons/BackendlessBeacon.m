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
#if !BEACON_DEBUGGING
        _objectId = nil;
        _iBeaconProps = nil;
        _eddystoneProps = nil;
        _type = BEACON_UNKNOWN;
#else
        _objectId = nil;
        _iBeaconProps = @{IBEACON_UUID_STR:@"D77657C4-52A7-426F-B9D0-D71E10798C8A", IBEACON_MAJOR_STR:@"0", IBEACON_MINOR_STR:@"0"};
        [_iBeaconProps retain];
        _eddystoneProps = nil;
        _type = BEACON_IBEACON;
#endif
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
        
        _type = BEACON_UNKNOWN;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        switch (type) {
            case BEACON_IBEACON: {
                if ([beacon isKindOfClass:CLBeacon.class]) {
                    CLBeacon *_beacon = beacon;
                    _type = type;
                    _iBeaconProps = [@{IBEACON_UUID_STR:_beacon.proximityUUID.UUIDString, IBEACON_MAJOR_STR:_beacon.major.stringValue, IBEACON_MINOR_STR:_beacon.minor.stringValue} retain];
                }
                break;
            }
            case BEACON_EDDYSTONE: {
                _type = type;
                break;
            }
            default: {
                break;
            }
        }
#endif
    }
    
    return self;
}

-(id)initWithClass:(id)beacon {
    
    if ( (self=[super init]) ) {
        
        _type = BEACON_UNKNOWN;
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        if ([beacon isKindOfClass:CLBeacon.class]) {
            CLBeacon *_beacon = beacon;
            _type = BEACON_IBEACON;
            _iBeaconProps = [@{IBEACON_UUID_STR:_beacon.proximityUUID.UUIDString, IBEACON_MAJOR_STR:_beacon.major.stringValue, IBEACON_MINOR_STR:_beacon.minor.stringValue} retain];
        }
#endif
    }
    
    return self;
}

#if 0
-(id)initWithBackendlessBeacon:(BackendlessBeacon *)beacon {
    
    NSLog(@"Backendless->initWithBackendlessBeacon:(0) %@", beacon);
    
    if ( (self=[super init]) ) {
        
        _type = beacon.type;
        _objectId = beacon.objectId?[[NSString alloc] initWithString:beacon.objectId]:nil;
        _iBeaconProps = beacon.iBeaconProps?[[NSDictionary alloc] initWithDictionary:beacon.iBeaconProps copyItems:YES]:nil;
        _eddystoneProps = beacon.eddystoneProps?[[NSDictionary alloc] initWithDictionary:beacon.eddystoneProps copyItems:YES]:nil;
    }
    
    return self;
}
#else
-(id)initWithBackendlessBeacon:(BackendlessBeacon *)beacon {
    
    if ( (self=[super init]) ) {
        
        _type = beacon.type;
        _objectId = beacon.objectId.copy;
        _iBeaconProps = beacon.iBeaconProps.copy;
        _eddystoneProps = beacon.eddystoneProps.copy;
    }
    
    //NSLog(@"Backendless->initWithBackendlessBeacon: (1) %@ from %@", self, beacon);
    
    return self;
}
#endif

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC BackendlessBeacon"];
    
    [_objectId release];
    [_iBeaconProps release];
    [_eddystoneProps release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)key {
    
    switch (_type) {
        case BEACON_IBEACON: {
            //NSLog(@"Backendless->key: %@", _iBeaconProps);
            return [NSString stringWithFormat:@"%@,%@,%@", _iBeaconProps[IBEACON_UUID_STR], _iBeaconProps[IBEACON_MAJOR_STR], _iBeaconProps[IBEACON_MINOR_STR]];
        }
        case BEACON_EDDYSTONE: {
            return @"BEACON_EDDYSTONE";
        }
        default: {
            return @"BEACON_UNKNOWN";
        }
    }
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    return [[BackendlessBeacon alloc] initWithBackendlessBeacon:self];
}

#pragma mark -
#pragma mark overwrided NSObject Methods

-(BOOL)isEqual:(id)object {
#if 0
    BOOL q = object && [object isKindOfClass:self.class] && [self.key isEqualToString:[(BackendlessBeacon *)object key]];
    NSLog(@"<<<<<<<<<<<< isEqual:: %@ == %@ ? [ %@ ]", self.key, [(BackendlessBeacon *)object key], q?@"YES":@"NO");
    return q;
#else
    return object && [object isKindOfClass:self.class] && [self.key isEqualToString:[(BackendlessBeacon *)object key]];
#endif
}

@end
