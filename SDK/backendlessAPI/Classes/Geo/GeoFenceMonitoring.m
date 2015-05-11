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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "GeoFenceMonitoring.h"
#import "DEBUG.h"
#import "LocationTracker.h"
#import "GeoPoint.h"
#import "GeoFence.h"
#import "GeoMath.h"

/*
 
 private ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
 private Set<GeoFence> onStaySet = Collections.synchronizedSet( new HashSet<GeoFence>() );
 
 private Map<GeoFence, ICallback> fencesToCallback = Collections.synchronizedMap( new HashMap<GeoFence, ICallback>() );
 private Set<GeoFence> pointFences = new HashSet<GeoFence>();
 
 private volatile Location location;

 */

@interface GeoFenceMonitoring () <ILocationTrackerListener>
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
        if (!sharedGeoFenceMonitoring)
            sharedGeoFenceMonitoring = [GeoFenceMonitoring new];
    }
    return sharedGeoFenceMonitoring;
}

-(id)init {
    if ( (self=[super init]) ) {
        self.onStaySet = [NSMutableArray array];
        self.fencesToCallback = [NSMutableDictionary dictionary];
        self.pointFences = [NSMutableArray array];
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
    
    NSMutableArray *oldFences = _pointFences;
    NSMutableArray *currFence = [self findGeoPointsFence:[GeoPoint geoPoint:(GEO_POINT)(GEO_POINT){.latitude=location.coordinate.latitude, .longitude=location.coordinate.longitude}] geoFences:[_fencesToCallback allKeys]];
    NSMutableArray *newFences = [NSMutableArray arrayWithArray:currFence];
    
    [newFences removeObjectsInArray:oldFences];
    [oldFences removeObjectsInArray:currFence];
    
    [self callOnEnter:newFences];
    [self callOnStay:newFences];
    [self callOnExit:oldFences];
    [self cancelOnStay:oldFences];
    
    self.pointFences = currFence;
}

static const NSString *GEOFENCE_ALREADY_MONITORING = @"The %s geofence is already being monitored. Monitoring of the geofence must be stopped before you start it again";
static const NSString *GEOFENCES_MONITORING = @"Cannot start geofence monitoring for all available geofences. There is another monitoring session in progress on the client-side. Make sure to stop all monitoring sessions before starting it for all available geo fences.";

#pragma mark -
#pragma mark Public Methods

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

public void removeGeoFences()
{
    onStaySet.clear();
    pointFences.clear();
    fencesToCallback.clear();
}

public boolean isMonitoring()
{
    return !fencesToCallback.isEmpty();
}
 */

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

-(void)addOnStay:(GeoFence *)geoFence {
    
}

-(void)cancelOnStayGeoFence:(GeoFence *)geoFence {
    [_onStaySet removeObject:geoFence];
}

@end
#endif
