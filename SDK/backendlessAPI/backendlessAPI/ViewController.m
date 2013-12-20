//
//  ViewController.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "ViewController.h"
#import "Types.h"
#import "PersistenceServiceUser.h"
#import "AppDelegate.h"
#import "BackendlessCache.h"
#import "Backendless.h"
#import "BackendlessCache.h"

static NSString *VERSION_NUM = @"v1";

static NSString *APP_ID = @"";
static NSString *SECRET_KEY = @"";


@interface Weather : NSObject {
    NSNumber    *Temperature;
    NSString    *Condition;
}
@property (nonatomic, retain) NSNumber *Temperature;
@property (nonatomic, retain) NSString *Condition;
@property (nonatomic, strong) NSString *objectId;
@end


@implementation Weather
@synthesize Temperature, Condition;

-(id)init {
	if ( (self=[super init]) ) {
        Temperature = [[NSNumber alloc] initWithFloat:-5.7f];
        Condition = [[NSString alloc] initWithString:@"Cooly"];
	}
	
	return self;
}

-(void)dealloc {
    
    [Temperature release];
    [Condition release];
	
	[super dealloc];
}

+(Weather *)weather:(float)temperature condition:(NSString *)condition {
    Weather *_weather = [Weather new];
    _weather.Temperature = [[NSNumber alloc] initWithFloat:temperature];
    _weather.Condition = condition;
    
    return _weather;
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@> objectId: '%@', Temperature: %@, Condition: %@", [self class], self.objectId, Temperature, Condition];
}

@end

// TestPerson

@interface TestPerson : NSObject {
    NSString    *objectId;
    NSString    *name;
    NSNumber    *age;
    NSDate      *born;
    NSNumber    *american;
    NSNumber    *income;
    BackendlessEntity *obj;
}
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *age;
@property (strong, nonatomic) NSDate *born;
@property (strong, nonatomic) NSNumber *american;
@property (strong, nonatomic) NSNumber *income;
@property (strong, nonatomic) BackendlessEntity *obj;

+(TestPerson *)person:(NSString *)_name age:(uint)_age;
-(uint)valAge;
-(void)age:(uint)_age;
-(BOOL)valAmerican;
-(void)american:(BOOL)_american;
-(double)valIncome;
-(void)income:(double)_income;
@end

@implementation TestPerson
@synthesize objectId, name, age, born, american, income, obj;

-(id)init {
	if ( (self=[super init]) ) {
        objectId = nil;
        name = nil;
        age = nil;
        born = nil;
        american = nil;
        income = nil;
        obj = nil;
	}
	
	return self;
}

+(TestPerson *)person:(NSString *)_name age:(uint)_age {
    TestPerson *_person = [TestPerson new];
    _person.name = _name;
    _person.age = [[NSNumber alloc] initWithUnsignedInt:_age];
    return [_person autorelease];
}

-(void)dealloc {
    
    [objectId release];
    [name release];
    [age release];
    [born release];
    [american release];
    [income release];
    [obj release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(uint)valAge {
    return [age unsignedIntValue];
}

-(void)age:(uint)_age {
    age = [[NSNumber alloc] initWithUnsignedInt:_age];
}

-(BOOL)valAmerican {
    return [american boolValue];
}

-(void)american:(BOOL)_american {
    american = [[NSNumber alloc] initWithBool:_american];
}

-(double)valIncome {
    return [income doubleValue];
}

-(void)income:(double)_income {
    income = [[NSNumber alloc] initWithDouble:_income];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@> objectId: '%@', name: %@, age: %@, born: %@, american: %@, income: %@, obj = %@", [self class], objectId, name, age, born,american, income, obj];
}

@end


@interface ViewController () {
    MediaPublisher *_publisher;
    MediaPlayer *_player;
    NSString *_streamName;
}

@end

@implementation ViewController
-(id)r:(id)res
{
    BackendlessCollection *c = res;
    NSLog(@"%@", c.data);
    return res;
}
-(void)viewDidLoad {
    
    [super viewDidLoad];
    [DebLog setIsActive:YES];
    //
    [backendless initApp:APP_ID secret:SECRET_KEY version:VERSION_NUM];
    //backendless.hostURL = HOST_URL;
    [backendless setThrowException:NO];

/*/
//    [backendlessCache saveOnDisc];
    
    BackendlessDataQuery *query = [BackendlessDataQuery query];
    BackendlessCachePolicy *policy = [[BackendlessCachePolicy alloc] init];
    [policy cachePolicy:BackendlessCachePolicyIgnoreCache];
    query.cachePolicy = policy;
    BackendlessCollection *collection = [backendless.persistenceService find:[Weather class] dataQuery:query];
    NSLog(@"%@", collection);
//    [backendless.persistenceService find:[Weather class] dataQuery:query responder:[Responder responder:self selResponseHandler:@selector(r:) selErrorHandler:nil]];
    BackendlessDataQuery *query1 = [BackendlessDataQuery query:nil where:nil query:[QueryOptions query]];
    BackendlessCachePolicy *policy1 = [[BackendlessCachePolicy alloc] init];
    [policy1 cachePolicy:BackendlessCachePolicyRemoteDataOnly];
    query1.cachePolicy = policy1;
    BackendlessCollection *collection1 = [backendless.persistenceService find:[Weather class] dataQuery:query1];
    NSLog(@"%@", collection1);
//[backendless.persistenceService find:[Weather class] dataQuery:query1 responder:[Responder responder:self selResponseHandler:@selector(r:) selErrorHandler:nil]];

    BackendlessDataQuery *query2 = [BackendlessDataQuery query];
    BackendlessCachePolicy *policy2 = [[BackendlessCachePolicy alloc] init];
    [policy2 cachePolicy:BackendlessCachePolicyIgnoreCache];
    query2.cachePolicy = policy2;
    [backendless.persistenceService find:[Weather class] dataQuery:query2 responder:[Responder responder:self selResponseHandler:@selector(r:) selErrorHandler:nil]];
//    [backendless clearAllCache];
//    [backendlessCache saveOnDisc];
    NSLog(@"dddd");
/*/

}

-(void)viewDidUnload {
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Private Methods

/*!
 Generates a random string of up to 1000 characters in length. Generates a random length up to 1000 if numCharacters is set to 0.
 */
-(NSString *)randomString:(int)numCharacters {
    //static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    int len;
    if(numCharacters > 1000 || numCharacters == 0) len = (int)rand() % (1000);
    else len = numCharacters;
    unichar characters[len];
    for( int i=0; i < len; ++i ) {
        characters[i] = possibleChars[arc4random_uniform(sizeof(possibleChars)-1)];
    }
    return [NSString stringWithCharacters:characters length:len] ;
}

-(NSString*)GUIDString {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return [(NSString *)string autorelease];
}

-(NSString *)randomCategory {
    return [NSString  stringWithFormat:@"Test%@", [self GUIDString]];
}

-(GEO_POINT)randomGeoPoint {
    
    GEO_POINT geoPoint;
    geoPoint.longitude = (double)(rand() % 18000)/100.0;
    geoPoint.latitude = (double)(rand() % 9000)/100.0;
    return geoPoint;
}

-(NSString *)randomClassName {
    return [NSString  stringWithFormat:@"Test%d", rand()];
}


// ERRORS

-(void)onError:(Fault *)fault {
    
    NSString *error = [NSString stringWithFormat:@"message: <%@>, detail: <%@>, faultCode: <%@>", fault.message, fault.detail, fault.faultCode];
    
    NSLog(@"onError: %@", error);
}

// CALLBACKS

-(void)onResponse:(id)response action:(NSString *)action {
    
    NSLog(@"Action -> %@: response = %@", action, response);
}


// UserService

-(void)onRegister:(id)response {
    NSLog(@"%@", response);
    BackendlessUser *user = (BackendlessUser *)response;
    
    NSLog(@"onRegister = %@, thread: %@", [user getProperties], [NSThread isMainThread]?@"MAIN":@"ANOTHER");
    
}

-(void)onUpdate:(id)response {
    
    BackendlessUser *user = (BackendlessUser *)response;
    
    NSLog(@"onUpdate = %@", [user getProperties]);
}

-(void)onLogin:(id)response {
    
    BackendlessUser *user = (BackendlessUser *)response;
    
    NSLog(@"onLogin = %@", [user getProperties]);
}

-(void)onLogout:(id)response {
    
    NSLog(@"onLogout = %@", response);
}

-(void)onRestorePassword:(id)response {
    
    NSLog(@"onRestorePassword = %@", response);
}

-(void)onDescribeUserClass:(id)response {
    
    NSLog(@"onDescribeUserClass:");
    
    NSArray *props = (NSArray *)response;
    for (UserProperty *prop in props)
        NSLog(@"%@", prop);
}

// persistenceService

-(void)onFind:(id)response {
    
    BackendlessCollection *bc = (BackendlessCollection *)response;
    
    NSLog(@"onFind: %@", bc);
    for (id entity in bc.data)
        NSLog(@"%@", entity);
    
}

-(void)onEntityRemove:(id)response {

    NSNumber *num = (NSNumber *)response;
    
    NSLog(@"onEntityRemove: number = %lld", [num longLongValue]);
    
}

-(void)onEntityFindLast:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
    
    NSLog(@"onEntityFindLast: id = %@", entity.objectId);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityRemove:) selErrorHandler:@selector(onError:)];
    //[backendless.persistenceService remove:[response class] sid:entity.objectId responder:responder];
    id <IDataStore> data = PERSIST_CLASS([response class]);
    [data removeID:entity.objectId responder:responder];
}

-(void)onEntityFindFirst:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
    
    NSLog(@"onEntityFindFirst: entity = %@", entity);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityFindLast:) selErrorHandler:@selector(onError:)];
    //[backendless.persistenceService last:[response class] responder:responder];
    id <IDataStore> data = PERSIST_CLASS([response class]);
    [data findLast:responder];
}

-(void)onEntityFindByClassId:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
    
    NSLog(@"onEntityFindByClassId: entity = %@", entity);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityFindFirst:) selErrorHandler:@selector(onError:)];
    //[backendless.persistenceService first:[response class] responder:responder];
    id <IDataStore> data = PERSIST_CLASS([response class]);
    [data findFirst:responder];
}

-(void)onEntityFindById:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
    
    NSLog(@"onEntityFindById: entity = %@", entity);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityFindByClassId:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService findByClassId:[response class] sid:entity.objectId responder:responder];
}

-(void)onEntityUpdate:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
    
    NSLog(@"onEntityUpdate: entity = %@", entity);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityFindById:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService findById:[Types objectClassName:entity] sid:entity.objectId responder:responder];
}

-(void)onEntityDescribe:(id)response {
    
    NSLog(@"onEntityDescribe:");
    
    NSArray *props = (NSArray *)response;
    for (ObjectProperty *prop in props)
        NSLog(@"%@", prop);    
}

-(void)onEntitySave:(id)response {
    
    BackendlessEntity *entity = (BackendlessEntity *)response;
       
    NSLog(@"onEntitySave: %@", entity);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityDescribe:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService describe:[Types objectClassName:response] responder:responder];
}

-(void)onDictUpdate:(id)response {
    
    NSLog(@"onDictUpdate: response = %@", response);
}

-(void)onDictSave:(id)response {
    
    NSLog(@"onDictSave: response = %@", response);
    
    NSDictionary *dict = (NSDictionary *)response;
    NSString *sid = [dict valueForKey:@"id"];
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onDictUpdate:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService update:@"BackendlessDict" entity:dict sid:sid responder:responder];
}

// geoService

-(void)onDeleteCategory:(id)response {
    
    NSLog(@"onDeleteCategory: response = %@", response);
}

-(void)onGetPoints:(id)response {
    
    BackendlessCollection *bc = (BackendlessCollection *)response;
    NSLog(@"onGetPoints: totalObjects = %@, data: %@", bc.totalObjects, bc.data);
    
    return;
    
    NSLog(@"SEND ------> deleteCategory");
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onDeleteCategory:) selErrorHandler:@selector(onError:)];
    [backendless.geoService deleteCategory:@"MyLocations9" responder:responder];
}

-(void)onGetCategories:(id)response {
    
    NSLog(@"onGetCategories: response = %@", response);
    
    return;
    
    NSLog(@"SEND ------> getPoints");
    
    //BackendlessGeoQuery *query = [BackendlessGeoQuery queryWithPoint:(GEO_POINT){23.9, 55.6} radius:100 units:METERS categories:[NSArray arrayWithObject:(NSString *)@"MyLocations"]];
    BackendlessGeoQuery *query = [BackendlessGeoQuery queryWithCategories:[NSArray arrayWithObject:(NSString *)@"MyLocations9"]];
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onGetPoints:) selErrorHandler:@selector(onError:)];
    [backendless.geoService getPoints:query responder:responder];
}

-(void)onAddPoint:(id)response {
    
    GeoPoint *gp = (GeoPoint *)response;
    NSLog(@"onAddPoint: geoPoint -> %@", gp);
    
    return;
    
    NSLog(@"SEND ------> getCategories");
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onGetCategories:) selErrorHandler:@selector(onError:)];
    [backendless.geoService getCategories:responder];
    
}

-(void)onAdd:(id)response {
    
    NSLog(@"onAdd: response = %@", response);
    
    return;
    
    GeoPoint *gp1 = [GeoPoint geoPoint:(GEO_POINT){67.7, 38.0}];
    [gp1 addCategory:@"MyLocations9"];
    [gp1 addMetadata:@"FIRST" value:@"1"];
    NSLog(@"SEND ------> addPoint: %@", gp1);
    
    [backendless.geoService savePoint:gp1];
    
    //return;
    
    GeoPoint *gp2 = [GeoPoint geoPoint:(GEO_POINT){22.9, 58.6}];
    [gp2 addCategory:@"MyLocations9"];
    [gp2 addMetadata:@"SECOND" value:@"2"];
    NSLog(@"SEND ------> addPoint: %@", gp2);
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onAddPoint:) selErrorHandler:@selector(onError:)];
    [backendless.geoService savePoint:gp2 responder:responder];
    // 
}

#pragma mark -
#pragma mark Public Methods

// ACTIONS

// UserService

-(IBAction)registerControl:(id)sender {
    
    NSLog(@"SEND ------> registering");
    
    // SYNC
    
    [backendless setThrowException:YES];
    
    @try {
        
        NSString *userName = [self randomString:6];
        NSString *password = [self randomString:8];
        
        BackendlessUser *user = [BackendlessUser new];
        user.email = [NSString stringWithFormat:@"%@@foo.com", userName];
        user.password = password;
        user.name = userName;
        
        NSLog(@"registerControl: SYNC new user = %@", user);
        
        BackendlessUser *registeredUser = [backendless.userService registering:user];
        [self onRegister:registeredUser];
        
        [backendless.userService login:registeredUser.email password:password];
        [self onLogin:backendless.userService.currentUser];
        
        [backendless.userService logout];
        [self onLogout:backendless.userService.currentUser];
    }
    
    @catch (Fault *fault) {
        [self onError:fault];        
    }
    
    @finally {
        [backendless setThrowException:NO];
    }
    
    //return;
    
    // ASYNC
    
    NSString *userName = [self randomString:6];
    NSString *password = [self randomString:8];
    
    BackendlessUser *user = [BackendlessUser new];
    user.email = [NSString stringWithFormat:@"%@@foo.com", userName];
    user.password = password;
    user.name = userName;
    
    NSLog(@"registerControl: ASYNC new user = %@", user);
    
    [backendless.userService
     registering:user
     response:^(BackendlessUser *registeredUser) {
        [self onRegister:registeredUser];
         
         [backendless.userService
          login:registeredUser.email password:password
          response:^(BackendlessUser *response) {
              [self onLogin:backendless.userService.currentUser];
              
              [backendless.userService
               logout:^(id response) {
                   [self onLogout:backendless.userService.currentUser];
               }
               error:^(Fault *fault){
                   [self onError:fault];
               }
               ];
          }
          error:^(Fault *fault){
              [self onError:fault];
          }
          ];
     }
     error:^(Fault *fault){
         [self onError:fault];
     }
     ];
    
}

-(IBAction)updateControl:(id)sender {
    
    NSLog(@"SEND ------> update %@", backendless.userService.currentUser);
    
    //
    BackendlessUser *user = backendless.userService.currentUser;
    //user.password = @"foofoo";
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onUpdate:) selErrorHandler:@selector(onError:)];
    [backendless.userService update:user responder:responder];
    /*/ 
    id result = [backendless.userService update:user];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onUpdate:result];
}

-(IBAction)loginControl:(id)sender {
    
    NSLog(@"SEND ------> login");
    
    //NSString *login = @"bob";
    //NSString *password = @"foo";
    NSString *login = @"trinity@foo.com";
    NSString *password = @"pass";
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:@selector(onError:)];
    [backendless.userService login:login password:password responder:responder];
    /*/
    id result = [backendless.userService login:login password:password];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onLogin:result];
}

-(IBAction)logoutControl:(id)sender {
    
    NSLog(@"SEND ------> logout");
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onLogout:) selErrorHandler:@selector(onError:)];
    [backendless.userService logout:responder];
}

-(IBAction)restorePasswordControl:(id)sender {
    
    NSLog(@"SEND ------> restorePassword");
    
    NSString *email = @"bob";//@"bob@foo.com";
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onRestorePassword:) selErrorHandler:@selector(onError:)];
    [backendless.userService restorePassword:email responder:responder];
}

-(IBAction)describeUserClassControl:(id)sender {
    
    NSLog(@"SEND ------> describeUserClass");
    
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onDescribeUserClass:) selErrorHandler:@selector(onError:)];
    [backendless.userService describeUserClass:responder];
}
-(id)persistenceResponder:(id)response
{
    NSLog(@"%@", response);
    return response;
}
-(id)persistenceErrorResponder:(Fault *)response
{
    NSLog(@"%@ - %@", response.detail, response.faultCode);
    return response;
}
-(IBAction)assingRole:(id)sender
{
//    NSLog(@"SEND ------> assingRole");
//    NSString *email = @"trinity@foo.com";
//    NSString *role = @"iosDev";
    Responder *responder = [Responder responder:self selResponseHandler:@selector(persistenceResponder:) selErrorHandler:@selector(persistenceErrorResponder:)];
//    [backendless.userService user:email assignRole:role responder:responder];
//    NSString *res = [backendless.userService easyLoginWithFacebookFieldsMapping:@{@"emal":@"email"} permissins:@[@"email"]];
    [backendless.userService easyLoginWithFacebookFieldsMapping:@{@"emal":@"email"} permissions:@[@"email"]];

}
-(void)unssingRole:(id)sender
{
   
}
// persistenceService

-(IBAction)entitySaveControl:(id)sender {
    
    __block Weather *entity;
    
    // SYNC
    
    [backendless setThrowException:YES];
    
    //entity = [Weather weather:24.7f condition:@"Warm"];
    entity = [Weather new];
    
    /*///------------------------------------------------
    
    Weather *weather = [Weather weather:-4.7f condition:@"Cool"];
    TestPerson *person = [TestPerson person:@"John" age:37];
    person.obj = entity;
    
    NSArray *list = @[weather, person];
    NSDictionary *cash1 = @{@"TestAr":list};
    NSDictionary *cash2 = @{@"TestPerson":person, @"Weather":weather};
    
    BinaryStream *data = [AMFSerializer serializeToBytes:cash1];
    [data print:YES];
    NSLog(@">>> %@", [AMFSerializer deserializeFromBytes:data]);
    
    
    return;
    /*///------------------------------------------------
    
    @try {
        
        entity = [backendless.persistenceService save:entity];
        [self onResponse:entity action:@"SYNC!!! entitySave (save)"];
        
        entity = [backendless.persistenceService findByClassId:[entity class] sid:entity.objectId];
        [self onResponse:entity action:@"SYNC!!! entitySave (findByClassId)"];
        
        entity = [backendless.persistenceService first:[entity class]];
        [self onResponse:entity action:@"SYNC!!! entitySave (first)"];
        
        entity = [backendless.persistenceService last:[entity class]];
        [self onResponse:entity action:@"SYNC!!! entitySave (last)"];
        
        NSNumber *result = [backendless.persistenceService remove:[entity class] sid:entity.objectId];
        [self onResponse:result action:@"SYNC!!! entitySave (remove)"];
        
    }
    
    @catch (Fault *fault) {
        [self onError:fault];
    }
    
    @finally {
        [backendless setThrowException:NO];
    }

    // ASYNC
    
    entity = [Weather new];
    
    [backendless.persistenceService
     save:entity
     response:^(id response) {
         entity = (Weather *)response;
         [self onResponse:entity action:@"BLOCKS!!! entitySave (save)"];
         
         [backendless.persistenceService
          findByClassId:[entity class] sid:entity.objectId
          response:^(id response) {
              entity = (Weather *)response;
              [self onResponse:entity action:@"BLOCKS!!! entitySave (findByClassId)"];
              
              [backendless.persistenceService
               first:[entity class]
               response:^(id response) {
                   entity = (Weather *)response;
                   [self onResponse:entity action:@"BLOCKS!!! entitySave (first)"];
                   
                   [backendless.persistenceService
                    last:[entity class]
                    response:^(id response) {
                        entity = (Weather *)response;
                        [self onResponse:entity action:@"BLOCKS!!! entitySave (last)"];
                        
                        [backendless.persistenceService
                        remove:[entity class] sid:entity.objectId
                         response:^(NSNumber *response) {
                             [self onResponse:response action:@"BLOCKS!!! entitySave (remove)"];
                         }
                         error:^(Fault *fault){
                             [self onError:fault];
                         }
                         ];
                    }
                    error:^(Fault *fault){
                        [self onError:fault];
                    }
                    ];
               }
               error:^(Fault *fault){
                   [self onError:fault];
               }
               ];
          }
          error:^(Fault *fault){
              [self onError:fault];
          }
          ];
     }
     error:^(Fault *fault){
         [self onError:fault];
     }
     ];
    
}

-(IBAction)entityUpdateControl:(id)sender {
    
    Weather *entity = [Weather new];
    id result = [backendless.persistenceService save:entity];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    };

    entity = (Weather *)result;
    entity.Temperature = [NSNumber numberWithFloat:22.8f];
    entity.Condition = @"Warm";
    
    NSLog(@"SEND ------>entityUpdate: %@", entity);
    
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onEntityUpdate:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService save:entity responder:responder];
    return; 
    /*/ 
    result = [backendless.persistenceService save:entity];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onResponse:result action:@"entityUpdate"];
}

-(IBAction)dictSaveControl:(id)sender {
    
    NSLog(@"SEND ------> dictSave");
    
    //NSString *type = @"BackendlessDict";
    NSString *type = [self randomClassName];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"FIRST", @"first", @"SECOND", @"second", nil];
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onDictSave:) selErrorHandler:@selector(onError:)];
    [backendless.persistenceService save:@"BackendlessDict" entity:dict responder:responder];
    return; 
    /*/ 
    id result = [backendless.persistenceService save:type entity:dict];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }

    [self onResponse:result action:[NSString stringWithFormat:@"dictSave (save) <%@>", type]];
    
    dict = (NSDictionary *)result;
    NSString *sid = [dict objectForKey:PERSIST_OBJECT_ID];
    if (!sid)
        return;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"FIRST", @"first", @"SECOND", @"second", @"THIRD", @"third", sid, PERSIST_OBJECT_ID, nil];
    result = [backendless.persistenceService update:type entity:dict sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    [self onResponse:result action:[NSString stringWithFormat:@"dictSave (update) <%@>", type]];
    
    result = [backendless.persistenceService findById:type sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    [self onResponse:result action:@"dictSave (findById)"];
   
}

-(IBAction)findControl:(id)sender {
    
    NSLog(@"SEND ------> find");
    
    id <IDataStore> weather = PERSIST_CLASS(Weather);
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onFind:) selErrorHandler:@selector(onError:)];
    [weather find:nil responder:responder];
    return; 
    /*/ 
    id result = [weather find:nil];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    [self onResponse:result action:@"find"];
    
    result = [backendless.persistenceService describe:@"Weather"];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    [self onResponse:result action:@"describe"];
    
}

// geoService

-(IBAction)addControl:(id)sender {
    
    NSLog(@"SEND ------> addCategory");
    
    id result = nil;
    GEO_POINT geoPoint = [self randomGeoPoint];
    //NSString *categoryName = [self randomCategory];
    NSString *categoryName = DEFAULT_CATEGORY_NAME;
    NSArray *categories = [NSArray arrayWithObjects: categoryName, nil];
    GeoPoint *gp = nil;
    NSDictionary *meta123 = [NSDictionary dictionaryWithObjectsAndKeys:@"FIRST", @"1", @"SECOND", @"2", @"THIRTH", @"3", nil];
    
    //---------------- addcategory
    /*/
    Responder *responder = [Responder responder:self selResponseHandler:@selector(onAdd:) selErrorHandler:@selector(onError:)];
    [backendless.geoService addCategory:@"MyLocations8" responder:responder];
    /*/
    
    //result = [backendless.geoService addCategory:nil];
    //result = [backendless.geoService addCategory:@""];
    //result = [backendless.geoService addCategory:@"Default"];
    //result = [backendless.geoService addCategory:categoryName];
    //[result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onAdd:result];
    //
    
    //------------------ deleteCategory
    //result = [backendless.geoService deleteCategory:nil];
    //result = [backendless.geoService deleteCategory:@""];
    //result = [backendless.geoService deleteCategory:@"Default"];
    //result = [backendless.geoService deleteCategory:@"ababagalamaga"];
    //result = [backendless.geoService deleteCategory:categoryName];
    //[result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onDeleteCategory:result];
    
    //return;
    
    //----------- getCategories
    //result = [backendless.geoService getCategories];
    //[result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onGetCategories:result];
    
    //return;
    
    //----------- add Points
    
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"MyLocations15", nil]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"MyLocations11", @"MyLocations12",nil]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"MyLocations11", @"MyLocations12", @"MyLocations13", nil]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"MyLocations11", @"MyLocations12", @"MyLocations11", nil]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"", nil]];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:nil];
    //gp = [GeoPoint geoPoint:[self randomGeoPoint] categories:[NSArray arrayWithObjects: @"MyLocations15", nil] metadata:nil];
    //gp = [GeoPoint geoPoint:geoPoint categories:[NSArray arrayWithObjects: categoryName, nil]];
    gp = [GeoPoint geoPoint:geoPoint categories:[NSArray arrayWithObjects: categoryName, nil] metadata:meta123];
    result = [backendless.geoService savePoint:gp];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onAddPoint:result];
    
    //return;
    
    //----------------- getPoints
    BackendlessGeoQuery *query = nil;
    
    //query = [BackendlessGeoQuery queryWithCategories:[NSArray arrayWithObject:(NSString *)@"MyLocations15"]];
    query = [BackendlessGeoQuery queryWithCategories:[NSArray arrayWithObject:(NSString *)@"Default"]];
    //query = [BackendlessGeoQuery queryWithCategories:[NSArray arrayWithObjects: @"Default", nil]];
    //query = [BackendlessGeoQuery queryWithPoint:geoPoint radius:100.0 units:METERS categories:categories];
    //query = [BackendlessGeoQuery queryWithPoint:geoPoint radius:100.0 units:METERS categories:categories metadata:meta123];
    [query pageSize:7];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>%@", query);
    result = [backendless.geoService getPoints:query];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onGetPoints:result];

}

-(void)cancelSubscribtion:(BESubscription *)subscription {
    
    NSLog(@"SEND ------> cancelSubscribtion: %@", subscription);
    
    [subscription cancel];
    [subscription release];
}

// messagingService

-(IBAction)messagingControl:(id)sender {
    
    NSLog(@"SEND ------> messagingControl");
    
    id result;
    NSString *channelName = @"TestChannel"; // HARDCODED TEST CHANNEL
    
    // registerDevice
    result = [backendless.messagingService registerDevice];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onResponse:result action:@"registerDevice"];
    //return;
    //
    
    
    // getRegistrations
    result = [backendless.messagingService getRegistrations];
    [result isKindOfClass:[Fault class]] ? [self onError:(Fault *)result] : [self onResponse:result action:@"getRegistrations"];
    //return;
    //
    
    
    // publish
    result = [backendless.messagingService publish:channelName message:@"HELLO!"];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    NSLog(@"PUBLISH: %@", result);
    
    MessageStatus *status = (MessageStatus *)result;
    NSString *messageId = [NSString stringWithFormat:@"%@", status.messageId];
    
    // subscribe
    
    result = [backendless.messagingService subscribe:channelName];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    NSLog(@"SUBSCRIPTION: %@", result);
    
    [self performSelector:@selector(cancelSubscribtion:) withObject:[result retain] afterDelay:10.0f];
    
    return;
    
    //cancel
    result = [backendless.messagingService cancel:messageId];
    if ([result isKindOfClass:[Fault class]]) {
        [self onError:(Fault *)result];
        return;
    }
    
    NSLog(@"CANCEL: %@", result);
    
    //
    
}

// mediaService

-(IBAction)publishControl:(id)sender {
    
    //MediaPublishOptions *options = [MediaPublishOptions liveStream:_preview];
    MediaPublishOptions *options = [MediaPublishOptions recordStream:_preview];
    //MediaPublishOptions *options = [MediaPublishOptions appendStream:_preview];
    //options.resolution = CIF_RESOLUTION;
    //_streamName = [self GUIDString];
    _streamName = @"11116";
    _publisher =[backendless.mediaService publishStream:_streamName tube:@"mediaTubeForWowza" options:options responder:nil];
    
    if (_publisher) {
        
        _preview.hidden = NO;
        _btnStopMedia.hidden = NO;
        _btnSwapCamera.hidden = NO;
    }
    
}

-(IBAction)playbackControl:(id)sender {
    
    //MediaPlaybackOptions *options = [MediaPlaybackOptions liveStream:_playbackView];
    MediaPlaybackOptions *options = [MediaPlaybackOptions recordStream:_playbackView];
    //_streamName = @"recorded_Last1";
    _streamName = @"11116";
    _player = [backendless.mediaService playbackStream:_streamName tube:@"mediaTubeForWowza" options:options responder:nil];
    
    if (_player) {
        
        _playbackView.hidden = NO;
        _btnStopMedia.hidden = NO;
    }
    
}

-(IBAction)stopMediaControl:(id)sender {
    
    if (_publisher) {
        
        [_publisher disconnect];
        _publisher = nil;
        
        _preview.hidden = YES;
        _btnStopMedia.hidden = YES;
        _btnSwapCamera.hidden = YES;
        
    }

    if (_player) {
        
        [_player disconnect];
        _player = nil;
        
        _playbackView.hidden = YES;
        _btnStopMedia.hidden = YES;
    }

}

-(IBAction)switchCamerasControl:(id)sender {
    
    if (_publisher)
        [_publisher switchCameras];
    
}


@end
