//
//  BEAnnotation.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 10/30/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BEAnnotation : NSObject<MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *geoPointId;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
