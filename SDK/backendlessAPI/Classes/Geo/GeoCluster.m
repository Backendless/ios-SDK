//
//  GeoCluster.m
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

#import "GeoCluster.h"

@implementation GeoCluster

-(int)valTotalPoints {
    return _totalPoints.intValue;
}

-(void)totalPoints:(int)totalPoints {
    self.totalPoints = @(totalPoints);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<GeoCluster> LAT:%@, LON:%@, distance:%@, CATEGORIES:%@, METADATA:%@, objectId:%@, totalPoints: %@\n%@", self.latitude, self.longitude, self.distance, self.categories, self.metadata, self.objectId, _totalPoints, _geoQuery];
}

@end
