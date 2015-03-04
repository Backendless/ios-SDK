//
//  BEMapView.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BEMapView.h"
#import <MapKit/MapKit.h>
#import "Backendless.h"
#import "BEAnnotation.h"

@interface BEMapView ()<MKMapViewDelegate>
{
    UNITS _units;
    //BackendlessGeoQuery *_geoQuery;
    Responder *_responder;
    NSMutableDictionary *_data;
    NSMutableSet *_categories;
    BOOL _autoUpdate;
    NSMutableArray *_responseData;
    float _radius;
    BOOL _searchInRadius;
    MKCircle *_circle;
}

@property (nonatomic, strong) id beMapViewDelegate;
-(id)errorHandler:(Fault *)fault;
-(void)initProperties;
-(id)responseHandler:(id)response;
-(void)removeCircle;
-(void)addCircle:(float)radius;
-(double)convertUnits;
-(void)updateGeopoints;
@end

@implementation BEMapView
@synthesize whereClause=_whereClause, metadata=_metadata;
-(void)dealloc
{
    self.delegate = nil;
//    [_circle release];
    [_responseData release];
    [_whereClause release];
    [_metadata release];
    [_categories release];
    [_data release];
    //[_geoQuery release];
    [_responder release];
    [super dealloc];
}
-(void)initProperties
{
    _includeMetadata = NO;
    _units = METERS;
    _searchInRadius = NO;
    _autoUpdate = YES;
    _categories = [NSMutableSet new];
    _responseData = [NSMutableArray new];
    self.delegate = self;
    _data = [NSMutableDictionary new];
    _responder = [[Responder responder:self selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)] retain];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }

    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}
-(void)setDelegate:(id<MKMapViewDelegate>)delegate
{
    if (delegate == nil) {
        self.beMapViewDelegate = nil;
        [super setDelegate:nil];
        return;
    }
    if (delegate != self) {
        self.beMapViewDelegate = delegate;
    }
    [super setDelegate:self];
}
-(BOOL)addCategory:(NSString *)category
{
    _autoUpdate = YES;
    [_categories addObject:category];
    return YES;
}
-(BOOL)removeCategory:(NSString *)category
{
    _autoUpdate = YES;
    [_categories removeObject:category];
    return YES;
}
-(BOOL)addGeopointIfNeed:(GeoPoint *)point
{
    if ([_data valueForKey:point.objectId]) {
        return NO;
    }
    [_data setValue:point forKey:point.objectId];
    BEAnnotation *annotation = [[[BEAnnotation alloc] init] autorelease];
    annotation.geoPointId = point.objectId;
    if (point.metadata.count > 0) {
        NSMutableArray *metadata = [[NSMutableArray alloc] init];
        for (NSString *key in point.metadata) {
            NSString *data = [NSString stringWithFormat:@"%@: %@", key, [point.metadata valueForKey:key]];
            data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            [metadata addObject:data];
            NSLog(@"%@", data);
        }
        annotation.title = [metadata componentsJoinedByString:@", "];
        [metadata release];
    }
    else
    {
        annotation.title = [NSString stringWithFormat:@"lat: %0.4f long: %0.4f", point.latitude.floatValue, point.longitude.floatValue];
    }
    [annotation setCoordinate:CLLocationCoordinate2DMake(point.latitude.floatValue, point.longitude.floatValue)];
    [self addAnnotation:annotation];
    return YES;
}
-(void)removeCircle
{
    if (_circle) {
        [self removeOverlay:_circle];
        _circle = nil;
    }
}
-(void)updateGeopoints
{
    BackendlessGeoQuery *query;
    GEO_POINT point;
    NSArray *categories = (_categories.allObjects.count==0)?@[@"geoservice_sample"]:_categories.allObjects;
    if (_searchInRadius) {
        [self addCircle:_radius];
        point.latitude = self.centerCoordinate.latitude;
        point.longitude = self.centerCoordinate.longitude;
        query = [BackendlessGeoQuery queryWithPoint:point radius:_radius units:_units categories:categories];
    }
    else
    {
        MKCoordinateRegion region = self.region;
        
        point.latitude = region.center.latitude;
        point.longitude = region.center.longitude;
        GEO_RECT rect = [backendless.geoService geoRectangle:point length:region.span.longitudeDelta widht:region.span.latitudeDelta];
        query = [BackendlessGeoQuery queryWithRect:rect.nordWest southEast:rect.southEast categories:categories];
    }
    query.includeMeta = @(_includeMetadata);
    query.metadata = (NSMutableDictionary *)self.metadata;
    query.whereClause = self.whereClause;
    [backendless.geoService getPoints:query responder:_responder ];
}
-(double)convertUnits
{
    double unitK = 1.0;
    switch (_units) {
        case METERS:
            unitK = 1.0;
            break;
        case MILES:
            unitK = 1609.3;
            break;
        case KILOMETERS:
            unitK = 1000.0;
            break;
        case YARDS:
            unitK = 0.91440;
            break;
        case FEET:
            unitK = 0.3048;
            break;
        default:
            unitK = 1.0;
            break;
    }
    return unitK;
}
-(void)addCircle:(float)radius
{
    [self removeCircle];
    _radius = radius;
    double unitK = [self convertUnits];
    _circle = [MKCircle circleWithCenterCoordinate:self.region.center radius:(_radius * unitK)];
    [self addOverlay:_circle];
}
-(NSArray *)responseData
{
    return _responseData;
}
-(void)setSearchWithRadius:(float)radius
{
    _searchInRadius = YES;
    [self addCircle:radius];
}
-(void)setSearchInMapBoundaries
{
    _radius = 0;
    _searchInRadius = NO;
    [self removeCircle];
}
-(void)setUnits:(int)units
{
    _units = units;
    [self addCircle:_radius];
}
-(void)removeGeoPointAnnotation:(NSString *)geopointId
{
    NSArray *annotations = self.annotations;
    for (id annotation in annotations) {
        if ([annotation isKindOfClass:[BEAnnotation class]]) {
            if ([[(BEAnnotation *)annotation geoPointId] isEqualToString:geopointId]) {
                [self removeAnnotation:annotation];
                return;
            }
        }
    }
}
-(void)removeAllObjects
{
    [_data removeAllObjects];
    [self removeAnnotations:self.annotations];
}
-(void)update
{
    [self removeAllObjects];
    [self mapView:self regionDidChangeAnimated:NO];
}
-(id)responseHandler:(BackendlessCollection *)response
{
    if (_autoUpdate) {
#if 1
        if (!_responseData.count) {
            [self removeAllObjects];
            NSLog(@"BEMapView -> responseHandler: (CLEAN)");
        }
#endif
        [_responseData addObjectsFromArray:response.data];
        if (response.valPageSize + response.valOffset < response.valTotalObjects) {
            [response nextPage:NO responder:_responder];
        }
        else
        {
            if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didFinishLoadData:)]) {
                [_beMapViewDelegate mapView:self didFinishLoadData:_responseData];
            }
        }
        for (GeoPoint *point in response.data) {
            [self addGeopointIfNeed:point];
        }
    }
    else {
        [self removeAllObjects];
        [_responseData removeAllObjects];
        [_responseData addObjectsFromArray:response.data];
        if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didFinishLoadData:)]) {
            [_beMapViewDelegate mapView:self didFinishLoadData:_responseData];
        }
        for (GeoPoint *point in response.data) {
            [self addGeopointIfNeed:point];
        }
    }
    return response;
}
-(id)errorHandler:(Fault *)fault
{
    [self removeAllObjects];
    [_responseData removeAllObjects];
    NSLog(@"BEMapView -> errorHandler:%@", fault.detail);
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didFinishWithFault:)]) {
        [_beMapViewDelegate mapView:self didFinishWithFault:fault];
    }
    return fault;
}

-(void)removeAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[BEAnnotation class]])
    {
        [_data removeObjectForKey:((BEAnnotation *)annotation).geoPointId];
    }
    [super removeAnnotation:annotation];

}
-(void)removeAnnotations:(NSArray *)annotations {
    
    if (_data.count) {
        for (id ann in annotations) {
            if ([ann isKindOfClass:[BEAnnotation class]]) {
                [_data removeObjectForKey:((BEAnnotation *)ann).geoPointId];
            }
        }
    }
    
    [super removeAnnotations:annotations];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [_beMapViewDelegate mapView:mapView viewForAnnotation:annotation];
    }
    if (annotation == mapView.userLocation) {
        return nil;
    }
    static NSString *const kAnnotationReuseIdentifier = @"backendlessAnnotationView";
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationReuseIdentifier];
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [_responseData removeAllObjects];
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [_beMapViewDelegate mapView:mapView regionDidChangeAnimated:animated];
        return;
    }
    if (_autoUpdate) {
        [self updateGeopoints];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [_beMapViewDelegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [_beMapViewDelegate mapView:mapView annotationView:view didChangeDragState:newState fromOldState:oldState];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [_beMapViewDelegate mapView:mapView didAddAnnotationViews:views];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didAddOverlayRenderers:)]) {
        [_beMapViewDelegate mapView:mapView didAddOverlayRenderers:renderers];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [_beMapViewDelegate mapView:mapView didAddOverlayViews:overlayViews];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)]) {
        [_beMapViewDelegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [_beMapViewDelegate mapView:mapView didDeselectAnnotationView:view];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [_beMapViewDelegate mapView:mapView didFailToLocateUserWithError:error];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [_beMapViewDelegate mapView:mapView didSelectAnnotationView:view];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [_beMapViewDelegate mapView:mapView didUpdateUserLocation:userLocation];
        return;
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [_beMapViewDelegate mapView:mapView regionWillChangeAnimated:animated];
        return;
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:rendererForOverlay:)]) {
        return [_beMapViewDelegate mapView:mapView rendererForOverlay:overlay];
    }
    MKCircleRenderer *circle = [[MKCircleRenderer alloc] initWithCircle:overlay];
    circle.fillColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:0.4];
    circle.lineWidth = 1;
    circle.strokeColor = [UIColor redColor];
    return circle;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        return [_beMapViewDelegate mapView:mapView viewForOverlay:overlay];
    }
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    circleView.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    
    return circleView;
}

-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [_beMapViewDelegate mapViewDidFailLoadingMap:mapView withError:error];
        return;
    }
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [_beMapViewDelegate mapViewDidFinishLoadingMap:mapView];
        return;
    }
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewDidFinishRenderingMap:fullyRendered:)]) {
        [_beMapViewDelegate mapViewDidFinishRenderingMap:mapView fullyRendered:fullyRendered];
        return;
    }
}

-(void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [_beMapViewDelegate mapViewDidStopLocatingUser:mapView];
        return;
    }
}

-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [_beMapViewDelegate mapViewWillStartLoadingMap:mapView];
        return;
    }
}

-(void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [_beMapViewDelegate mapViewWillStartLocatingUser:mapView];
        return;
    }
}

-(void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    if ([_beMapViewDelegate respondsToSelector:@selector(mapViewWillStartRenderingMap:)]) {
        [_beMapViewDelegate mapViewWillStartRenderingMap:mapView];
        return;
    }
}

-(void)getPoints:(BackendlessGeoQuery *)query
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = nil;
    BackendlessCollection *c = [backendless.geoService getPoints:query];
    [self responseHandler:c];
}

-(void)relativeFind:(BackendlessGeoQuery *)query
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = nil;
    BackendlessCollection *c = [backendless.geoService relativeFind:query];
    [self responseHandler:c];
}

-(void)getPoints:(BackendlessGeoQuery *)query responder:(id)responder
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService getPoints:query responder:_responder];
}

-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id)responder
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = responder;
    [backendless.geoService relativeFind:query responder:_responder];
}

-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService getPoints:query responder:_responder];
}

-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock
{
    _autoUpdate = NO;
    //_geoQuery = [query retain];
    _responder.chained = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [backendless.geoService relativeFind:query responder:_responder];
}

@end
