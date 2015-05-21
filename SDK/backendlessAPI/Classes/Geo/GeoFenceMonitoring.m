//
//  GeoFenceMonitoring.m
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

#import "GeoFenceMonitoring.h"
#import "Backendless.h"
#import "DEBUG.h"
#import "GeoPoint.h"
#import "GeoFence.h"
#import "GeoMath.h"
#import "ICallback.h"

/*
 
 private ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
 private Set<GeoFence> onStaySet = Collections.synchronizedSet( new HashSet<GeoFence>() );
 
 private Map<GeoFence, ICallback> fencesToCallback = Collections.synchronizedMap( new HashMap<GeoFence, ICallback>() );
 private Set<GeoFence> pointFences = new HashSet<GeoFence>();
 
 private volatile Location location;

 */

@interface GeoFenceMonitoring ()
@property (strong, nonatomic) NSMutableArray *onStaySet;                // Set<GeoFence>
@property (strong, nonatomic) NSMutableDictionary *fencesToCallback;    // Map<GeoFence, ICallback>
@property (strong, nonatomic) NSMutableArray *pointFences;              // Set<GeoFence>
@property (strong, nonatomic) CLLocation *location;
@end

@implementation GeoFenceMonitoring

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(GeoFenceMonitoring *)sharedInstance {
    static GeoFenceMonitoring *sharedGeoFenceMonitoring;
    @synchronized(self)
    {
        if (!sharedGeoFenceMonitoring) {
            sharedGeoFenceMonitoring = [GeoFenceMonitoring new];
            [DebLog logN:@"CREATE GeoFenceMonitoring: sharedGeoFenceMonitoring = %@", sharedGeoFenceMonitoring];
        }
    }
    return sharedGeoFenceMonitoring;
}

-(id)init {
    if ( (self=[super init]) ) {
        self.onStaySet = [NSMutableArray new];
        self.fencesToCallback = [NSMutableDictionary new];
        self.pointFences = [NSMutableArray new];
        _location = nil;
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC GeoFenceMonitoring"];
    
    [_onStaySet removeAllObjects];
    [_onStaySet release];
    
    [_fencesToCallback removeAllObjects];
    [_fencesToCallback release];
    
    [_pointFences removeAllObjects];
    [_pointFences release];
    
    [_location release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark ILocationTrackerListener Methods

/*
@Override
public void onLocationChanged( Location location )
{
    Set<GeoFence> oldFences, newFences, currFence;
    
    synchronized( this )
    {
        this.location = location;
        oldFences = pointFences;
        currFence = findGeoPointsFence( new GeoPoint( location.getLatitude(), location.getLongitude() ), fencesToCallback.keySet() );
        newFences = new HashSet<GeoFence>( currFence );
        
        newFences.removeAll( oldFences );
        oldFences.removeAll( currFence );
        
        callOnEnter( newFences );
        callOnStay( newFences );
        callOnExit( oldFences );
        cancelOnStay( oldFences );
        
        pointFences = currFence;
    }
}
 
 */

-(void)onLocationChanged:(CLLocation *)location {
    
    self.location = location;
    
    GeoPoint *point = [GeoPoint geoPoint:(GEO_POINT){.latitude=location.coordinate.latitude, .longitude=location.coordinate.longitude}];
    
    NSMutableArray *oldFences = _pointFences;
    NSArray *geoFences = [_fencesToCallback allKeys];
    NSMutableArray *currFence = [self findGeoPointsFence:point geoFences:geoFences];
    NSMutableArray *newFences = [NSMutableArray arrayWithArray:currFence];
    
    [newFences removeObjectsInArray:oldFences];
    [oldFences removeObjectsInArray:currFence];
    
    [DebLog log:@"GeoFenceMonitoring -> onLocationChanged: %@\nnewFences: %@\noldFences: %@\ncurrFence: %@", location, newFences, oldFences, currFence];
    
    [self callOnEnter:newFences];
    [self callOnStay:newFences];
    [self callOnExit:oldFences];
    [self cancelOnStay:oldFences];
    
    self.pointFences = currFence;
}

-(void)onLocationFailed:(NSError *)error {
    [DebLog log:@"GeoFenceMonitoring -> onLocationFailed: %@", error];
}

static NSString *GEOFENCE_OR_CALLBACK_IS_NOT_VALUED = @"The geofence %@ or callback %@ is not valued";
static NSString *GEOFENCE_ALREADY_MONITORING = @"The %@ geofence is already being monitored. Monitoring of the geofence must be stopped before you start it again";
static NSString *GEOFENCES_MONITORING = @"Cannot start geofence monitoring for all available geofences. There is another monitoring session in progress on the client-side. Make sure to stop all monitoring sessions before starting it for all available geo fences.";

#pragma mark -
#pragma mark Public Methods

-(NSString *)listenerName {
    return @"GeoFenceMonitoring";
}

/*

public void addGeoFences( Set<GeoFence> geoFences, ICallback callback )
{
    if( !fencesToCallback.isEmpty() )
        throw new BackendlessException( ExceptionMessage.GEOFENCES_MONITORING );
    
    for( GeoFence geoFence : geoFences )
    {
        addGeoFence( geoFence, callback );
    }
}
 */

-(Fault *)addGeoFences:(NSArray *)geoFences callback:(id <ICallback>)callback {
    
    if (!callback || !geoFences || !geoFences.count) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_OR_CALLBACK_IS_NOT_VALUED, geoFences, callback] faultCode:@"0000"]];
    }
    
    if (_fencesToCallback.count) {
        return [backendless throwFault:[Fault fault:GEOFENCES_MONITORING faultCode:@"0000"]];
    }
    
    for (GeoFence *geoFence in geoFences) {
        [self addGeoFence:geoFence callback:callback];
    }
    
    return nil;
}

/*

public void addGeoFence( GeoFence geoFence, ICallback callback )
{
    if( fencesToCallback.containsKey( geoFence ) )
    {
        if( !fencesToCallback.get( geoFence ).equalCallbackParameter( callback ) )
            throw new BackendlessException( String.format( ExceptionMessage.GEOFENCE_ALREADY_MONITORING, geoFence.getGeofenceName() ) );
        return;
    }
    
    if( !isDefiniteRect( geoFence.getNwPoint(), geoFence.getSePoint() ) )
    {
        definiteRect( geoFence );
    }
    this.fencesToCallback.put( geoFence, callback );
    
    if( location != null && isPointInFence( new GeoPoint( location.getLatitude(), location.getLongitude() ), geoFence ) )
    {
        pointFences.add( geoFence );
        callback.callOnEnter( geoFence, location );
        addOnStay( geoFence );
    }
}
 */

-(Fault *)addGeoFence:(GeoFence *)geoFence callback:(id <ICallback>)callback {
    
    if (!geoFence || !callback) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_OR_CALLBACK_IS_NOT_VALUED, geoFence, callback] faultCode:@"0000"]];
    }
    
    id <ICallback> _callback = [_fencesToCallback objectForKey:geoFence];
    if (_callback && ![_callback equalCallbackParameter:callback]) {
        return [backendless throwFault:[Fault fault:[NSString stringWithFormat:GEOFENCE_ALREADY_MONITORING, geoFence.geofenceName] faultCode:@"0000"]];
    }
    
    if (![self isDefiniteRect:geoFence.nwPoint se:geoFence.sePoint]) {
        [self definiteRect:geoFence];
    }
    
    [_fencesToCallback setObject:callback forKey:geoFence];
    
    if (_location && [self isPointInFence:[GeoPoint geoPoint:(GEO_POINT){.latitude=_location.coordinate.latitude, .longitude=_location.coordinate.latitude}] geoFence:geoFence]) {
        
        [_pointFences addObject:geoFence];
        [callback callOnEnter:geoFence location:_location];
        [self addOnStay:geoFence];
    }
    
    return nil;
}

/*

public void removeGeoFence( String geoFenceName )
{
    GeoFence removed = new GeoFence( geoFenceName );
    if( fencesToCallback.containsKey( removed ) )
    {
        fencesToCallback.remove( removed );
        cancelOnStay( removed );
        pointFences.remove( removed );
    }
}
 */

-(void)removeGeoFence:(NSString *)geoFenceName {
    
    NSArray *geoFences = [_fencesToCallback allKeys];
    for (GeoFence *geoFence in geoFences) {
        if ([geoFence.geofenceName isEqualToString:geoFenceName ]) {
            [_fencesToCallback removeObjectForKey:geoFence];
            [self cancelOnStayGeoFence:geoFence];
            [_pointFences removeObject:geoFence];
            return;
        }
    }
}
/*

public void removeGeoFences()
{
    onStaySet.clear();
    pointFences.clear();
    fencesToCallback.clear();
}
 */

-(void)removeGeoFences {
    [_onStaySet removeAllObjects];
    [_pointFences removeAllObjects];
    [_fencesToCallback removeAllObjects];
}
/*

public boolean isMonitoring()
{
    return !fencesToCallback.isEmpty();
}
 */

-(BOOL)isMonitoring {
    return _fencesToCallback.count > 0;
}

#pragma mark -
#pragma mark Private Methods

/*
 
 private void callOnEnter( Set<GeoFence> geoFences )
 {
 for( GeoFence geoFence : geoFences )
 {
 fencesToCallback.get( geoFence ).callOnEnter( geoFence, location );
 }
 }
 
 private void callOnStay( Set<GeoFence> geoFences )
 {
 for( GeoFence geoFence : geoFences )
 {
 if( geoFence.getOnStayDuration() > 0 )
 addOnStay( geoFence );
 }
 }
 
 private void cancelOnStay( Set<GeoFence> geoFences )
 {
 for( GeoFence geoFence : geoFences )
 {
 cancelOnStay( geoFence );
 }
 }
 
 private void callOnExit( Set<GeoFence> geoFences )
 {
 for( GeoFence geoFence : geoFences )
 {
 fencesToCallback.get( geoFence ).callOnExit( geoFence, location );
 }
 }
 
 */

-(void)callOnEnter:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [(id <ICallback>)_fencesToCallback[geoFence] callOnEnter:geoFence location:_location];
    }
}

-(void)callOnStay:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        if ([geoFence valOnStayDuration] > 0)
            [self addOnStay:geoFence];
    }
}

-(void)cancelOnStay:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [self cancelOnStayGeoFence:geoFence];
    }
}

-(void)callOnExit:(NSArray *)geoFences {
    for (GeoFence *geoFence in geoFences) {
        [(id <ICallback>)_fencesToCallback[geoFence] callOnExit:geoFence location:_location];
    }
}


/*

private Set<GeoFence> findGeoPointsFence( GeoPoint geoPoint, Set<GeoFence> geoFences )
{
    Set<GeoFence> pointFences = new HashSet<GeoFence>();
    
    for( GeoFence geoFence : geoFences )
    {
        
        if( isPointInFence( geoPoint, geoFence ) )
        {
            pointFences.add( geoFence );
        }
    }
    
    return pointFences;
}
 */

-(NSMutableArray *)findGeoPointsFence:(GeoPoint *)geoPoint geoFences:(NSArray *)geoFences {
    
    NSMutableArray *pointFences = [NSMutableArray new];
    for (GeoFence *geoFence in geoFences) {
        if ([self isPointInFence:geoPoint geoFence:geoFence]) {
            [pointFences addObject:geoFence];
        }
    }
    return pointFences;
}


/*

private boolean isPointInFence( GeoPoint geoPoint, GeoFence geoFence )
{
    if( !GeoMath.isPointInRectangular( geoPoint, geoFence.getNwPoint(), geoFence.getSePoint() ) )
    {
        return false;
    }
    
    if( geoFence.getType() == FenceType.CIRCLE && !GeoMath.isPointInCircle( geoPoint, geoFence.getNodes().get( 0 ), GeoMath.distance( geoFence.getNodes().get( 0 ).getLatitude(), geoFence.getNodes().get( 0 ).getLongitude(), geoFence.getNodes().get( 1 ).getLatitude(), geoFence.getNodes().get( 1 ).getLongitude() ) ) )
    {
        return false;
    }
    
    if( geoFence.getType() == FenceType.SHAPE && !GeoMath.isPointInShape( geoPoint, geoFence.getNodes() ) )
    {
        return false;
    }
    
    return true;
}
 */

-(BOOL)isPointInFence:(GeoPoint *)geoPoint geoFence:(GeoFence *)geoFence {
    
    if ( ![GeoMath isPointInRectangular:geoPoint nw:geoFence.nwPoint se:geoFence.sePoint] ) {
        return NO;
    }
    
    switch (geoFence.valType) {
        
        case CIRCLE_FENCE: {
            
            GeoPoint *gp0 = geoFence.nodes[0];
            GeoPoint *gp1 = geoFence.nodes[1];
            double distance = [GeoMath distance:[gp0 valLatitude] lon1:[gp0 valLongitude] lat2:[gp1 valLatitude] lon2:[gp1 valLongitude]];
            return [GeoMath isPointInCircle:geoPoint center:gp0 radius:distance];
        }
            
        case SHAPE_FENCE: {
            return [GeoMath isPointInShape:geoPoint shape:geoFence.nodes];
        }
           
        default:
            return YES;
    }
}

/*

private boolean isDefiniteRect( GeoPoint nwPoint, GeoPoint sePoint )
{
    return nwPoint != null && sePoint != null;
}
*/

-(BOOL)isDefiniteRect:(GeoPoint *)nwPoint se:(GeoPoint *)sePoint {
    return (nwPoint != nil) && (sePoint != nil);
}

/*
private void definiteRect( GeoFence geoFence )
{
    switch( geoFence.getType() )
    {
        case RECT:
        {
            GeoPoint nwPoint = geoFence.getNodes().get( 0 );
            GeoPoint sePoint = geoFence.getNodes().get( 1 );
            geoFence.setNwPoint( nwPoint );
            geoFence.setSePoint( sePoint );
            break;
        }
        case CIRCLE:
        {
            double[] outRect = GeoMath.getOutRectangle( geoFence.getNodes().get( 0 ), geoFence.getNodes().get( 1 ) );
            geoFence.setNwPoint( new GeoPoint( outRect[ 0 ], outRect[ 1 ] ) );
            geoFence.setSePoint( new GeoPoint( outRect[ 2 ], outRect[ 3 ] ) );
            break;
        }
        case SHAPE:
        {
            double[] outRect = GeoMath.getOutRectangle( geoFence.getNodes() );
            geoFence.setNwPoint( new GeoPoint( outRect[ 0 ], outRect[ 1 ] ) );
            geoFence.setSePoint( new GeoPoint( outRect[ 2 ], outRect[ 3 ] ) );
            break;
        }
        default:
    }
}
 */

-(void)definiteRect:(GeoFence *)geoFence {
    
    switch ( [geoFence valType] )
    {
        case RECT_FENCE:
        {
            GeoPoint *nwPoint = geoFence.nodes[0];
            GeoPoint *sePoint = geoFence.nodes[1];
            geoFence.nwPoint = nwPoint;
            geoFence.sePoint = sePoint;
            break;
        }
        case CIRCLE_FENCE:
        {
            GEO_RECTANGLE outRect = [GeoMath getOutRectangle:geoFence.nodes[0] bounded:geoFence.nodes[1]];
            geoFence.nwPoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.northLat, .longitude=outRect.westLong}];
            geoFence.sePoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.southLat, .longitude=outRect.eastLong}];
            break;
        }
        case SHAPE_FENCE:
        {
            GEO_RECTANGLE outRect = [GeoMath getOutRectangle:geoFence.nodes];
            geoFence.nwPoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.northLat, .longitude=outRect.westLong}];
            geoFence.sePoint = [GeoPoint geoPoint:(GEO_POINT){.latitude=outRect.southLat, .longitude=outRect.eastLong}];
            break;
        }
        default:
            break;
    }
}

/*

private void addOnStay( final GeoFence geoFence )
{
    onStaySet.add(geoFence);
    scheduledExecutorService.schedule( new Runnable()
                                      {
                                          @Override
                                          public void run()
                                          {
                                              if( onStaySet.contains(geoFence) )
                                              {
                                                  fencesToCallback.get(geoFence).callOnStay(geoFence, location);
                                                  cancelOnStay(geoFence);
                                              }
                                          }
                                      }, geoFence.getOnStayDuration(), TimeUnit.SECONDS );
}

private void cancelOnStay( GeoFence geoFence )
{
    onStaySet.remove( geoFence );
}
*/

-(void)checkOnStay:(GeoFence *)geoFence {
    
    [DebLog log:@"GeoFenceMonitoring -> checkOnStay:"];
    
    if ([_onStaySet containsObject:geoFence]) {
        
        [(id <ICallback>)_fencesToCallback[geoFence] callOnStay:geoFence location:_location];
        [self cancelOnStayGeoFence:geoFence];
    }
}

-(void)addOnStay:(GeoFence *)geoFence {
    
    [_onStaySet addObject:geoFence];
    
    [DebLog log:@"GeoFenceMonitoring -> addOnStay: geofence = %@, onStayDuration = %dsec", geoFence.geofenceName, geoFence.valOnStayDuration];
    
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*geoFence.valOnStayDuration);
    dispatch_after(interval, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkOnStay:geoFence];
    });
}

-(void)cancelOnStayGeoFence:(GeoFence *)geoFence {
    [_onStaySet removeObject:geoFence];
}

@end
