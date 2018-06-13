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
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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
    if (self = [super init]) {
        _objectId = nil;
        _iBeaconProps = @{IBEACON_UUID_STR:@"D77657C4-52A7-426F-B9D0-D71E10798C8A", IBEACON_MAJOR_STR:@"0", IBEACON_MINOR_STR:@"0"};
        [_iBeaconProps retain];
        _eddystoneProps = nil;
        _type = BEACON_IBEACON;
    }
    return self;
}

-(id)initWithType:(BeaconTypeEnum)type beacon:(id)beacon {
    if (self = [super init]) {
        _type = BEACON_UNKNOWN;
#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) && !TARGET_OS_WATCH && !TARGET_OS_TV
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
    if (self = [super init]) {
        _type = BEACON_UNKNOWN;
#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) && !TARGET_OS_WATCH && !TARGET_OS_TV
        if ([beacon isKindOfClass:CLBeacon.class]) {
            CLBeacon *_beacon = beacon;
            _type = BEACON_IBEACON;
            _iBeaconProps = [@{IBEACON_UUID_STR:_beacon.proximityUUID.UUIDString, IBEACON_MAJOR_STR:_beacon.major.stringValue, IBEACON_MINOR_STR:_beacon.minor.stringValue} retain];
        }
#endif
    }
    return self;
}

-(id)initWithBackendlessBeacon:(BackendlessBeacon *)beacon {
    if (self = [super init]) {
        _type = beacon.type;
        _objectId = beacon.objectId.copy;
        _iBeaconProps = beacon.iBeaconProps.copy;
        _eddystoneProps = beacon.eddystoneProps.copy;
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

-(NSString *)key {
    switch (_type) {
        case BEACON_IBEACON: {
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

-(id)copyWithZone:(NSZone *)zone {
    return [[BackendlessBeacon alloc] initWithBackendlessBeacon:self];
}

-(BOOL)isEqual:(id)object {
    return object && [object isKindOfClass:self.class] && [self.key isEqualToString:[(BackendlessBeacon *)object key]];
}

@end
