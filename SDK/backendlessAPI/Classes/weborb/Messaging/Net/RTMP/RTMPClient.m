//
//  RTMPClient.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 21.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//


#import <Security/Security.h>
#import "RTMPClient.h"
#import "DEBUG.h"
#import "LicenseManager.h"
#import "CrowdNode.h"
#import "Datatypes.h"
#import "RTMPConstants.h"
#import "IRTMProtocol.h"
#import "IClientSharedObjectDelegate.h"
#import "IStreamPacket.h"
#import "IStreamDispatcher.h"
#import "RTMProtocol.h"
#import "BinaryStream.h"
#import	"FlashorbBinaryWriter.h"
#import "FlashorbBinaryReader.h"
#import "WebORBDeserializer.h"
#import "WebORBSerializer.h"
#import "BaseRTMPProtocolDecoder.h"
#import "BaseRTMPProtocolEncoder.h"
#import "Header.h"
#import "Packet.h"
#import "AnonymousObject.h"
#import "Call.h"
#import "PendingCall.h"
#import "Ping.h"
#import "Invoke.h"
#import "ClientSharedObject.h"
#import "Aggregate.h"
#import "AudioData.h"
#import "FlexMessage.h"
#import "IPendingServiceCall.h"
#import "V3Message.h"
#import "MetaData.h"

#if 1
#define DEFAULT_CHANNEL_ID 3
#define DEFAULT_STREAM_ID 0
#else
#define DEFAULT_CHANNEL_ID 4
#define DEFAULT_STREAM_ID 1
#endif

static NSString *LICENSE_IS_NEEDED = @"A license is needed to use a library. Contact Midnight Coders Sales to purchase the license";

@interface RTMPClient () {
    
	// delegates
    NSMutableArray  *owners;
    
    // thread
    NSThread        *socketThread;
    
	// socket
	NSString		*_host;
	int				_port;
    BOOL            useSSL;
	NSOutputStream	*outputStream;
	uint8_t			*outputBuffer;
    int             outputSize;
    int             bufferSize;
	NSInputStream	*inputStream;
	uint8_t			*inputBuffer;
	
	// context
    NSString        *_app;
	NSArray			*parameters;
	CrowdNode		*connectionParams;
	
	// protocol
	RTMProtocol		*rtmp;
    uint            state;
	BOOL			firstHandshake;
	uint			lengthHandshake;
	float			timeoutHandshake; // = 3.0 sec by default
	
	// invoke/notify
	int				invokeId;
	NSMutableArray	*pendingMessages;
	CrowdNode		*pendingCalls;
	
	// shared objects
	CrowdNode		*sharedObjects;
	
    // media stream players
	CrowdNode		*streamPlayers;
	
	// test
    int _testCount;
}

-(void)defaultInitialize;
-(void)splitURL:(NSString *)url;
-(void)connect:(NSString *)server port:(int)port;
-(void)connect:(NSString *)server port:(int)port app:(NSString *)application params:(NSArray *)params;
-(void)addPendingMessage:(Packet *)message;
-(void)issuedOpenTA;
-(void)eventFailed:(int)code description:(NSString *)description;
-(void)socketThreadMain;
-(void)scheduleSocketThread;
-(void)cancelSocketThread;
-(void)startOnSocketThread;
-(void)stopOnSocketThread;
-(BOOL)createSocket:(NSString *)host andPort:(int)port;
-(void)eraseSocket;
-(void)checkLicense;
-(void)checkServer;
-(void)sendFirstHandshake;
-(void)timeoutFirstHandshake;
-(void)repeatFirstHandshake;
-(void)sendSecondHandshake;
-(void)receiveHandshake;
-(void)sendConnect;
-(void)sendChunk;
-(void)receiveChunk;
-(NSString *)keyByIntId:(int)intId;
-(int)intIdByKey:(NSString *)strKey;
-(NSString *)randomSOName;
@end


@interface RTMPClient (IRTMPClientDelegate) <IRTMPClientDelegate>
@end

@interface RTMPClient (IRTMProtocol) <IRTMProtocol>
@end

@interface RTMPClient (IClientSharedObjectDelegate) <IClientSharedObjectDelegate>
@end


@implementation RTMPClient
@synthesize timeoutHandshake;

-(id)init {
	if ( (self=[super init]) ) {		
		[self defaultInitialize];
	}
	return self;
}

-(id)init:(NSString *)url {
	if ( (self=[super init]) ) {		
		[self defaultInitialize];
        [self splitURL:url];
        state = STATE_DISCONNECTED;
	}
	return self;    
}

-(id)init:(NSString *)url andParams:(NSArray *)params {
 	if ( (self=[super init]) ) {		
		[self defaultInitialize];
        [self splitURL:url];
        parameters = (params) ? [params retain] : nil;
        state = STATE_DISCONNECTED;
	}
	return self;   
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC RTMPClient"];
	
	[self eraseSocket];
    
    [_host release];
    [_app release];
    [parameters release];
	
	[rtmp release];
    
    [owners removeAllObjects];
    [owners release];
	
	[connectionParams clear];
	[connectionParams release];
    
	[pendingMessages removeAllObjects];
	[pendingMessages release];
	
	[pendingCalls clear];
	[pendingCalls release];
	
	[sharedObjects clear];
	[sharedObjects release];
	
	[streamPlayers clear];
	[streamPlayers release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark getters / setters

-(id)getDelegates {
    return owners;
}

-(void)addDelegate:(id)owner {
    if (![self isDelegate:owner])
        [owners addObject:owner];
}

#pragma mark -
#pragma mark Public Methods

-(void)spawnSocketThread {
    
    if (state < STATE_DISCONNECTED) {
        [DebLog logY:@"RTMPClient -> spawnSocketThread: **** ERROR: SOCKET SHOULD BE DISCONNECTED"];
        return;
    }
    
    [self stopOnSocketThread];
    
    socketThread = [[NSThread alloc] initWithTarget:self selector:@selector(socketThreadMain) object:nil];
    [[socketThread threadDictionary] setObject:SOCKET_THREAD_IS_RUNNING  forKey:SOCKET_THREAD_IS_RUNNING ];
    [socketThread start];
}

-(NSThread *)getSocketThread {
    return socketThread;
}

-(BOOL)isDelegate:(id)owner {

    @synchronized (owners) {
        
        if (owners.count)
            for (id <IRTMPClientDelegate> _owner in owners)
                if (_owner == owner)
                    return YES;
        return NO;
    }
}

-(void)removeDelegate:(id)owner {
    
    @synchronized (owners) {
        
        @try {
            [owners removeObject:owner];
        }
        @catch (NSException *exception) {
            [DebLog logY:@"RTMPClient -> removeDelegate: EXCEPTION <%@> ", exception];
        }
    }
}

-(void)clearPendingCalls {
    
    @synchronized (pendingCalls) {
        [pendingCalls clear];
    }
}

-(NSArray *)rtmpWritingQueue {
    return [rtmp writingQueue];
}

-(int)pendingTypedPackets:(int)type streamId:(int)streamId {
    return [rtmp pendingTypedPackets:type streamId:streamId];
}

-(NSString *)getURL {
    
    if (state == STATE_NEED_CONNECT)
        return nil;
    
    NSString *url = (useSSL) ? @"rtmps://%@:%d/%@" : @"rtmp://%@:%d/%@";
    return [NSString stringWithFormat:url, _host, _port, _app];
}

-(void)connect {
    [self connect:_host port:_port app:_app params:parameters];
}

-(void)connect:(NSString *)url {
    [self connect:url andParams:nil];
}

-(void)connect:(NSString *)url andParams:(NSArray *)params {
    
    [self splitURL:url];
    if (parameters) [parameters release];
    parameters = (params) ? [params retain] : nil;
    
    state = STATE_DISCONNECTED;

    [self connect];
}

-(BOOL)connected {
    return (state <= STATE_CONNECTED);
}

-(void)disconnect {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
#if 0
    BOOL isThread = ([[socketThread threadDictionary] objectForKey:SOCKET_THREAD_IS_RUNNING] != nil);
    BOOL beContinue = (!isThread && (self.retainCount > 1)) || (isThread && (self.retainCount > 3));
    
    [DebLog log:@"RTMPClient -> disconnect: *** %@ *** <retainCount == %d", (state == STATE_DISCONNECTED)?@"ALREADY DISCONNECTED!":beContinue?@"CAN NOT BE DISCONNECTED!":@"DISCONNECT...", self.retainCount];
    
    if (beContinue)
        return;
#endif
    
    [self eraseSocket];
}

-(void)disconnect:(id)owner {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self removeDelegate:owner];
    BOOL beContinue = (BOOL)owners.count;
    
    [DebLog log:@"RTMPClient -> disconnect: *** %@ *** <owners.count == %d", (state == STATE_DISCONNECTED)?@"ALREADY DISCONNECTED!":beContinue?@"CAN NOT BE DISCONNECTED!":@"DISCONNECT...", owners.count];
    
    if (beContinue)
        return;
    
    [self eraseSocket];
}

-(int)invoke:(NSString *)method withArgs:(NSArray *)args responder:(id <IPendingServiceCallback>)responder {
    return [self invoke:method withArgs:args responder:responder transactionID:[self nextInvokeId] channelId:DEFAULT_CHANNEL_ID  streamId:DEFAULT_STREAM_ID];    
}

-(int)invoke:(NSString *)method withArgs:(NSArray *)args responder:(id <IPendingServiceCallback>)responder transactionID:(int)tID channelId:(int)cID streamId:(int)sID {
    
    [DebLog log:@"RTMPClient -> INVOKE: method = '%@', invokeId = %d, responder = %@, args = %@", method, tID, responder, args];
	
	// call constract
	Call *call = [[Call alloc] initWithMethod:method andArguments:args];
	call.sender = responder;
	
    // invoke message
	Invoke *invoke = [[Invoke alloc] initWithCall:call];
	invoke.invokeId = tID;	
	
    // save pending call
    [pendingCalls push:[self keyByIntId:invoke.invokeId] withObject:call];
	
    // invoke packet
	Packet *message = [Packet packet];	
	// header
	message.header.dataType = TYPE_INVOKE;
	message.header.channelId = cID;
    message.header.streamId = sID;
	// body
	BinaryStream *body = [[BaseRTMPProtocolEncoder coder] encodeMessage:invoke];
	[message.data write:body.buffer length:body.size];
	//[message.data print:YES];
    [self sendMessage:message];
	
	[invoke release];
	[call release];
    
    return tID;
}

-(void)flexInvoke:(NSString *)method message:(id)obj responder:(id <IPendingServiceCallback>)responder {
    
	// call constract
    id <IPendingServiceCall> call = [[PendingCall alloc] initWithMethod:method];
    [call registerCallback:responder];
    
    // flex message
    FlexMessage *flexPush = [[FlexMessage alloc] initWithCall:call];
    flexPush.obj = [NSArray arrayWithObject:obj];
    flexPush.invokeId = [self nextInvokeId];
    flexPush.streamId = DEFAULT_STREAM_ID;
	
    // save pending call
	[pendingCalls push:[self keyByIntId:flexPush.invokeId] withObject:call];
    
    // flex invoke packet
	Packet *message = [Packet packet];	
	// header
	message.header.dataType = TYPE_FLEXINVOKE;
	message.header.channelId = DEFAULT_CHANNEL_ID;
    message.header.streamId = DEFAULT_STREAM_ID;
	// body
	BinaryStream *body = [[BaseRTMPProtocolEncoder coder] encodeMessage:flexPush];
	[message.data write:body.buffer length:body.size];
	[message.data print:NO];
    [self sendMessage:message];
    
    [flexPush release];
    [call release];
}

-(void)metadata:(MetaData *)metadata streamId:(int)streamId channelId:(int)channelId timestamp:(int)timestamp {
    
    // metadata message
    if (metadata.metadata) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:metadata.metadata];
        [dict setObject:AS_ARRAY_METADATA forKey:AS_ARRAY_METADATA];
        metadata.metadata = dict;
    }
    
    // metadata packet
	Packet *message = [Packet packet];
	// header
	message.header.dataType = TYPE_NOTIFY;
	message.header.channelId = channelId;
    message.header.streamId = streamId;
    message.header.timerBase = 0;
    message.header.timerDelta = timestamp;
	// body
	BinaryStream *body = [[BaseRTMPProtocolEncoder coder] encodeMessage:metadata];
	[message.data write:body.buffer length:body.size];
	[message.data print:NO];
    [self sendMessage:message];
}

-(id <IClientSharedObject>)getSharedObject:(NSString *)name persistent:(BOOL)persistent owner:(id <ISharedObjectListener>)owner {
    
    if (!name) name = [self randomSOName];
    
    ClientSharedObject *so = [sharedObjects get:name];
    if (so) {
        [DebLog logN:@"Already connected to a shared object with this name"];
        if ([so isPersistentObject] != persistent) {
            [DebLog logN:@"...but with different persistence!"];
        }
    }
    else {
        so = [[ClientSharedObject alloc] initWithName:name persistent:persistent];
        so.delegate = self;
        so.owner = owner;
        [sharedObjects push:name withObject:so];
        [so connect];
    }
    
    return so;   
}

-(void)sendMessage:(Packet *)message {
    
    switch (state) {
            
        case STATE_LOCKED:
            [self clearPendingCalls];
            return;
            
        case STATE_NEED_CONNECT:
            [self clearPendingCalls];
            return;
            
        case STATE_DISCONNECTED:
            [self connect];
            [self addPendingMessage:message];
            return;
            
        case STATE_HANDSHAKE:
            [self addPendingMessage:message];
            return;
            
        default:
            [rtmp sendMessage:message];
            if ([rtmp shouldSendMessage])
                [self sendChunk];
            return;
    }
}

-(BOOL)addStreamPlayer:(id <IStreamDispatcher>)player streamId:(int)streamId {
    return [streamPlayers push:[self keyByIntId:streamId] withObject:player];
}

-(BOOL)removeStreamPlayer:(id <IStreamDispatcher>)player streamId:(int)streamId {
    return [streamPlayers pop:[self keyByIntId:streamId] withObject:player];    
}

-(void)setClientChunkSize:(int)size {
    
    if (size <= 0)
        return;
 	
	[DebLog log:@"RTMPClient -> setClientChunkSize: = %d", size];
    
    rtmp.writeChunkSize = size;
	
	Packet *message = [Packet packet];
	// header
	message.header.dataType = TYPE_CHUNK_SIZE;
	message.header.channelId = 2;	
	// body "server bandwidth"
	[message.data writeUInteger:size];	
	[self sendMessage:message];
}

-(int)writeStream:(uint)streamId data:(uint8_t *)data lenght:(uint)lenght {
    
    if (!data || !lenght)
        return -1;
    
    int result = 0;
    
    BinaryReader *buf = [[BinaryReader alloc] initWithStream:(char *)data andSize:lenght];
    char *l = [buf readChars:3];
    NSString *s = [NSString stringWithUTF8String:l];
    free(l);
    if ([s isEqualToString:@"FLV"]) {
        [buf seek:13];
#if 0
        printf("----------------------------------- FLV -----------------------------------------------------\n");
        [buf print:YES];
        printf("---------------------------------------------------------------------------------------------\n");
#endif
    }
    else {
        [buf begin];
    }
    
    // default channel ID
    uint channelId = RTMP_SOURCE_CHANNEL;
    
    while ([buf remaining] > 10) {
        
        // pick header options
        uint8_t type = [buf readByte];
        size_t size = [buf readUInt24BE];
        uint ts = [buf readUInt24BE] + ([buf readByte] << 24);
        [buf readUInt24BE];
        
#if 0   // toggle media channels
        switch (type) {
            case TYPE_AUDIO_DATA:
                channelId = RTMP_AUDIO_CHANNEL;
                break;
            case TYPE_VIDEO_DATA:
                channelId = RTMP_VIDEO_CHANNEL;
                break;
            default:
                channelId = RTMP_SOURCE_CHANNEL;
                break;
        }
#endif
        
        //printf("\nRTMPClient -> writeStream: type: %X, size: %zu, ts: %d flags: %1x\n", type, size, ts, [buf get]);

#if 1   // catch no media frame
        if ((type != TYPE_VIDEO_DATA) && (type != TYPE_AUDIO_DATA) && (type != TYPE_NOTIFY) ) {
            printf("\nRTMPClient -> writeStream: (ERROR) - no media frame\n");
            result = 1;
            break;
        }
#endif
        
        if ((size == 0) || [buf remaining] < size) {
            printf("\nRTMPClient -> writeStream: (ERROR) SIZE -> [buf remaining] = %d, size = %zu\n", [buf remaining], size);
            result = 2;
            break;
        }
        
        Packet *message = [Packet packet];
        // header
        message.header.dataType = type;
        message.header.channelId = channelId;
        message.header.streamId = streamId;
        message.header.timerBase = 0;
        message.header.timerDelta = ts;
        // body
        if (type == TYPE_NOTIFY) {
            [message.data writeByte:UTFSTRING_DATATYPE_V1];
            [message.data writeString:SET_DATA_FRAME];
        }
        char *frame = malloc(size);
        [buf read:frame length:size];
        [message.data write:frame length:size];
        free(frame);
        [buf readUInt32BE];
        [message.data print:NO];
        [self sendMessage:message];
    }
    
    [buf release];

    return result;
}


#pragma mark -
#pragma mark Private Methods

-(void)defaultInitialize {
    
    owners = [NSMutableArray new];
    
    socketThread = nil;
    
    _host = nil;
	_port = DEFAULT_RTMP_PORT;
    useSSL = NO;
    timeoutHandshake = 3.0f;
	
	_app = nil;
    parameters = nil;
	connectionParams = [CrowdNode new];
	
	inputStream = nil;
	outputStream = nil;
	inputBuffer = nil;
	outputBuffer = nil;
    outputSize = 0;
    bufferSize = 0;
	
	rtmp = [[RTMProtocol alloc] init];
	rtmp.delegate = self;
	
	invokeId = 1;
	pendingMessages = [NSMutableArray new];
	pendingCalls = [CrowdNode new];
	sharedObjects = [CrowdNode new];
    streamPlayers = [CrowdNode new];
    
    state = STATE_NEED_CONNECT;
}

-(void)splitURL:(NSString *)url {
    
    if (!url)
        return;
    
    NSURL *_url = [NSURL URLWithString:url];
    
    if (_host) [_host release];
    _host = [[_url host] retain];
    
    NSNumber *port = [_url port];
    _port = (port) ? [port intValue] : DEFAULT_RTMP_PORT;
    NSString *path = [_url path];
    
    if (_app) [_app release];
	_app = (path && path.length > 1) ? [[path  substringFromIndex:1] retain] : nil;
    
    NSString *scheme = [_url scheme];
    useSSL = (scheme) && [[scheme uppercaseString] isEqualToString:@"RTMPS"];    
	
    [DebLog logN:@"RTMPClient splitURL: '%@:%d/%@'", _host, _port, _app];
}

-(void)connect:(NSString *)server port:(int)port {
	[connectionParams push:@"objectEncoding" withObject:[NSNumber numberWithDouble:0.0f]];	
	[self createSocket:server andPort:port];
}

-(void)connect:(NSString *)server port:(int)port app:(NSString *)application params:(NSArray *)params {
	
	[DebLog logN:@"RTMPClient connect: '%@:%d/%@' with parameters: %@", server, port, application, params];
    
    if (!application || (application.length == 0)) {
        [self connect:server port:port];
        return;
    }
	
    NSString *protocol = (useSSL) ? @"rtmps://%@:%d/%@" : @"rtmp://%@:%d/%@";
    NSString *url = [NSString stringWithFormat:protocol, server, port, application];
	
	[DebLog log:@">>>>>>>>>>>>>>>> connect: url = '%@'", url];
	
    [connectionParams push:@"app" withObject:application];
	[connectionParams push:@"tcUrl" withObject:url];
	[connectionParams push:@"flashVer" withObject:@"MAC 10,0,32,18"];
	[connectionParams push:@"fpad" withObject:[NSNumber numberWithBool:NO]];
	[connectionParams push:@"audioCodecs" withObject:[NSNumber numberWithInt:SUPPORT_SND_ALL]]; //3191
	[connectionParams push:@"videoFunction" withObject:[NSNumber numberWithDouble:1]]; 
	[connectionParams push:@"pageUrl" withObject:nil];
	[connectionParams push:@"capabilities" withObject:[NSNumber numberWithInt:239]]; 
	[connectionParams push:@"swfUrl" withObject:nil];
	[connectionParams push:@"videoCodecs" withObject:[NSNumber numberWithInt:SUPPORT_VID_ALL]];
    [connectionParams push:@"objectEncoding" withObject:[NSNumber numberWithInt:3]];
    
    _app = application;
    if (parameters) [parameters release];
    parameters = (params) ? [[NSArray alloc] initWithArray:params] : nil;
	
	[self connect:server port:port];
}

-(void)addPendingMessage:(Packet *)message {
    
    @synchronized (pendingMessages) {
        [pendingMessages addObject:[message contentRetained]];
    }
}

-(void)issuedOpenTA {
	
    if (!inputStream || !outputStream) 
        return;

    if (([inputStream streamStatus] < NSStreamStatusOpen) || ([outputStream streamStatus] < NSStreamStatusOpen)) {
        
        [self connectFailedEvent:-1 description:@"Input or/and Output Stream is not opened (-1)"];
        [self eraseSocket];    
    }
}

-(void)eventFailed:(int)code description:(NSString *)description {
    
    [DebLog logY:@"RTMPClient -> eventFailed: code = %d, description = %@, calls = %d", code, description, [pendingCalls count]];
    
    if (![pendingCalls count])
        return;
    
    NSArray *keys = [pendingCalls keys];
    for (NSString *key in keys) {
        
        id item = [pendingCalls get:key];
        if (![item isMemberOfClass:[PendingCall class]])
            continue;
        
        NSArray *callbacks = [(PendingCall *)item getCallbacks];
        for (id callback in callbacks) 
            if ([callback conformsToProtocol:@protocol(IPendingServiceCallback)])
                [callback connectFailedEvent:code description:description];
    }
}

//------------------------------ SOCKET THREAD METHODS -------------------------------------------------------

/*/
-(void)socketThreadMain {
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *options = [socketThread threadDictionary];
    while ([options objectForKey:SOCKET_THREAD_IS_RUNNING]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
    
    socketThread = nil;
    
    [DebLog log:@"RTMPClient -> socketThreadMain: RELEASED"];
    
    [pool release];
}
/*/

-(void)socketThreadMain {

    while ([[socketThread threadDictionary] objectForKey:SOCKET_THREAD_IS_RUNNING]) {
        
        [DebLog logN:@"RTMPClient -> socketThreadMain: RUN LOOP"];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        @try {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
        @catch (NSException *exception) {
            [DebLog logY:@"RTMPClient -> socketThreadMain: EXCEPTION: %@", exception];
        }
        
        [pool release];
    }
    
    socketThread = nil;
    
    [DebLog log:@"RTMPClient -> socketThreadMain: RELEASED"];
}

-(void)scheduleSocketThread {
    
    if ([NSThread currentThread] != socketThread) {
        [DebLog logY:@"RTMPClient -> scheduleSocketThread: **** ERROR: THREAD IS NOT SOCKET THREAD [%@]", [NSThread isMainThread]?@"M":@"T"];
        return;
    }
    
    [DebLog log:@"RTMPClient -> startOnCurrentThread [%@]", [NSThread isMainThread]?@"M":@"T"];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStream open];
}

-(void)cancelSocketThread {
    
    if ([NSThread currentThread] != socketThread) {
        [DebLog logY:@"RTMPClient -> cancelSocketThread: **** ERROR: THREAD IS NOT SOCKET THREAD [%@]", [NSThread isMainThread]?@"M":@"T"];
        return;
    }
     
    [DebLog log:@"RTMPClient -> cancelSocketThread: [%@]", [NSThread isMainThread]?@"M":@"T"];
    
    if (inputStream) {
        [inputStream close];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [inputStream setDelegate:nil];
        [inputStream release];
        inputStream = nil;
    }
    
    if (outputStream) {
        [outputStream close];
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [outputStream setDelegate:nil];
        [outputStream release];
        outputStream = nil;
    }
    
    [[socketThread threadDictionary] removeObjectForKey:SOCKET_THREAD_IS_RUNNING];    
}

-(void)startOnSocketThread {
    
    if (!socketThread)
        socketThread = [NSThread currentThread];
    
    [self performSelector:@selector(scheduleSocketThread) onThread:socketThread withObject:nil waitUntilDone:YES];
}

-(void)stopOnSocketThread {
    
    if (!socketThread)
        return;
    
    [self performSelector:@selector(cancelSocketThread) onThread:socketThread withObject:nil waitUntilDone:NO];
}

//--------------------------------------------------------------------------------------------------------------------

/*	kCFStreamNetworkServiceType
 *
 * Discussion:
 * Property key to specify the type of service for the stream.  This
 * allows the system to properly handle the request with respect to
 * routing, suspension behavior and other networking related attributes
 * appropriate for the given service type.  The service types supported
 * are documented below.  Most streams should not need to set this
 * property.
 */
/*
 CFN_EXPORT const CFStringRef kCFStreamNetworkServiceType		__OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_4_0);
 
 // supported network service types:
 CFN_EXPORT const CFStringRef kCFStreamNetworkServiceTypeVoIP __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_4_0);		// voice over IP control
 CFN_EXPORT const CFStringRef kCFStreamNetworkServiceTypeVideo __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);		// interactive video
 CFN_EXPORT const CFStringRef kCFStreamNetworkServiceTypeBackground __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);	// background
 CFN_EXPORT const CFStringRef kCFStreamNetworkServiceTypeVoice __OSX_AVAILABLE_STARTING(__MAC_10_7, __IPHONE_5_0);		// interactive voice data
 */

-(BOOL)createSocket:(NSString *)host andPort:(int)port {
	
	if (!host || ![NSURL URLWithString:host]) {
		[DebLog log:@"Socket host '%@' is not a valid URL", host]; 
        [self connectFailedEvent:-2 description:@"Socket host is not a valid URL (-2)"];
		
        return NO;
	}
	
	if (outputStream && inputStream)
		[self eraseSocket];
	
	[DebLog log:@"Socket: '%@:%d' will be CREATED, [self retainCount] = %d", host, port, [self retainCount]];
    
    @synchronized(self) {
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)host, port, &readStream, &writeStream);
        
        inputStream = (NSInputStream *)readStream;
        outputStream = (NSOutputStream *)writeStream;
        
        if (!inputStream || !outputStream) {
            [DebLog log:@"Socket:'%@:%d' is not allowed", host, port];
            [self connectFailedEvent:-3 description:@"Input or/and Output Stream is not created (-3)"];
            
            return NO;
        }
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [self startOnSocketThread];
        
        //
        if (useSSL) {
            
            NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      // ssl
                                      [NSNumber numberWithBool:NO], kCFStreamSSLAllowsExpiredCertificates,
                                      [NSNumber numberWithBool:NO], kCFStreamSSLAllowsExpiredRoots,
                                      [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                                      kCFNull, kCFStreamSSLPeerName,
                                      kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
                                      // background
                                      kCFStreamNetworkServiceTypeBackground, kCFStreamNetworkServiceType,
                                      nil];
            
            CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
            CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
            
            [DebLog log:@"Socket use the options:\n %@", settings];
        }
        
        [DebLog log:@"Socket OPENED! inputStatus: %d, outputStatus: %d [%@]", [inputStream streamStatus], [outputStream streamStatus], [NSThread isMainThread]?@"M":@"T"];
        
        inputBuffer = malloc(RTMP_BUFFER_SIZE);
        outputBuffer = malloc(RTMP_BUFFER_SIZE);
        outputSize = 0;
        bufferSize = 0;
        
        if (outputBuffer && inputBuffer) {
            
            [self performSelector:@selector(issuedOpenTA) withObject:nil afterDelay:5.0f];
            
            [pendingMessages removeAllObjects];
            
            state = STATE_HANDSHAKE;		
            firstHandshake = YES;
            
            [DebLog logN:@"createSocket: FINISH [self retainCount] = %d", [self retainCount]];
            
            return YES;
        }
    }
    
    [self connectFailedEvent:-4 description:@"Input or/and Output Stream buffer(s) in not allocated (-4)"];
	[self eraseSocket];
	
    return NO;
}

-(void)eraseSocket {
    
    if (state == STATE_DISCONNECTED)
        return;
	
    state = STATE_DISCONNECTED;
    
    @synchronized(self) {
        
        @try {
            
            [self stopOnSocketThread];
            
            if (inputBuffer) {
                free(inputBuffer);
                inputBuffer = nil;
            }
            
            if (outputBuffer) {
                free(outputBuffer);
                outputBuffer = nil;
            }
            
            outputSize = 0;
            bufferSize = 0;
            
            [rtmp clearContext];
            [pendingMessages removeAllObjects];
            [pendingCalls clear];
            [sharedObjects clear];
            [streamPlayers clear];
            
        }
        @catch (NSException *exception) {
            [DebLog log:@"RTMPClient -> eraseSocket: *** EXCEPTION %@ <%@>", exception.name, exception.reason];
        }
    }
}

-(void)printHandshake {
    // display
    for (int i = 0; i < HANDSHAKE_SIZE; i++) {
        if (i % 16 == 0) printf("\n%04x - ", i);
        printf("%02x ", outputBuffer[i]%0x100);
    }
    printf("\n\n");    
}

-(void)checkLicense {
    
    NSString *URL = [self getURL];
    //[DebLog logY:@">>>>>>>>>>>>> checkLicense <%@> ... ", URL];
    if ([LicenseManager isExclusiveRtmpUrl:[NSURL URLWithString:URL]] || [LicenseManager isLicenseByOwnBundleIdentifier]) {
        //[DebLog logY:@">>>>>>>>>>>>> ... checkLicense -> YES"];
        return;
    }
    
    //[DebLog logY:@">>>>>>>>>>>>> ... checkLicense -> NO: BREAK THE CONNECTION"];
    
    [self eraseSocket];
    [self connectFailedEvent:-7 description:LICENSE_IS_NEEDED];

    state = STATE_LOCKED;
}

-(void)checkServer {    
#if TARGET_IPHONE_SIMULATOR
    // Don't check the license if running on the iPhone simulator.
    //[DebLog log:@">>>>>>>>>> License won't be checked (SIMULATOR)"];
#else	
    const uint8_t sign[] = {0xA7, 0x21, 0x03, 0x0F, 0x15};
    for (int i = 0; i < 5; i++) {
        if (outputBuffer[i*256+outputBuffer[1531+i]] == sign[i])
            continue;        
        //[DebLog logY:@">>>>>>>>>> License will be checked"];
        [self performSelector:@selector(checkLicense) withObject:nil afterDelay:LICENSE_TIMER_CRITERIUM];
        
        return;        
    }    
    //[DebLog logY:@">>>>>>>>>> License won't be checked (WEBORB)"];
#endif
}

-(void)sendFirstHandshake {
	
	if (!firstHandshake)
		return;
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    // random handshake
    if (SecRandomCopyBytes(kSecRandomDefault, HANDSHAKE_SIZE+1, (uint8_t *)outputBuffer) != 0)
        for (int i = 0; i <= HANDSHAKE_SIZE; i++)
            outputBuffer[i] = (char)i;
#else
    for (int i = 0; i <= HANDSHAKE_SIZE; i++)
        outputBuffer[i] = (char)i;
#endif
    
    
    // handshake leader == 0x03
    outputBuffer[0] = 0x03;
    
    // client version == 0 - (int)zero
    for (int i = 5; i <= 8; i++)
      outputBuffer[i] = 0x00;
	
    // output
	NSInteger len = [outputStream write:outputBuffer maxLength:HANDSHAKE_SIZE+1];
	if (len > 0)
		[DebLog log:@"First Handshake -> wrote %d bytes", len];
	else 
		[DebLog log:@"First Handshake -> socket write error"];
	//
	firstHandshake = NO;
	lengthHandshake = 0;
    
    [self performSelector:@selector(timeoutFirstHandshake) withObject:nil afterDelay:timeoutHandshake];
}

-(void)timeoutFirstHandshake {
    
    if (state != STATE_HANDSHAKE)
        return;
    
    [DebLog log:@"First Handshake didn't have the Response (timeout = %g)", timeoutHandshake];
    
    [self connectFailedEvent:-5 description:@"First Handshake didn't have the Response (-5)"];
	[self eraseSocket];
}

-(void)repeatFirstHandshake {
    
    if (state != STATE_HANDSHAKE)
        return;
    
    [DebLog log:@"repeat First Handshake!"];
    
    firstHandshake = YES;
    [self sendFirstHandshake];
}

-(void)sendSecondHandshake {
	
    NSInteger len = [outputStream write:outputBuffer maxLength:HANDSHAKE_SIZE];
	if (len > 0)
		[DebLog log:@"Second Handshake -> wrote %d bytes", len];
	else 
		[DebLog log:@"Second Handshake -> socket write error"];
}

-(void)receiveHandshake {	
	
    NSInteger len = [inputStream read:inputBuffer maxLength:2*HANDSHAKE_SIZE+1];
	if (len > 0)
		[DebLog log:@"Receive Handshake -> read %d bytes, leader = %d", len, inputBuffer[0]];
	else {
		[DebLog log:@"Receive Handshake -> socket read error"];
        return;
    }
    
    int shift = (lengthHandshake)?0:1;
	if (lengthHandshake < HANDSHAKE_SIZE) 
    for (int i = 0; i < len; i++)
        outputBuffer[i+lengthHandshake] = inputBuffer[i+shift];
	
    lengthHandshake += (len - shift);	
	if (lengthHandshake < 2*HANDSHAKE_SIZE) 
		return;
    
    //[self printHandshake];
    
    // CHECK THE WEBORB SIGN
    [self checkServer];
	
	[self sendSecondHandshake];
	state = STATE_CONNECT;	
	
    [self sendConnect];
}

-(void)sendConnect {
	
	Packet *message = [Packet packet];
	WebORBSerializer *writer = [WebORBSerializer writer:message.data];
	
	// header
	message.header.dataType = TYPE_INVOKE;
	message.header.channelId = 3;
	
	// body
	id obj = @"connect";
	[writer serialize:obj];
	obj = [NSNumber numberWithDouble:1.0f];
	[writer serialize:obj];
	obj = [AnonymousObject objectType:connectionParams.node];
	[writer serialize:obj];
	if (parameters) 
        for (id element in parameters)
            [writer serialize:element];
	//[message.data print:YES];
    [self sendMessage:message];
}

#define _OUTPUT_CHANK_ NO

-(void)sendChunk {
    
    @synchronized (self) {
        
        BinaryStream *chunk = [rtmp sendingChunk];
        if (!chunk) {
            [DebLog log:_OUTPUT_CHANK_ text:@"sendChunk -> didn't write !!!!!"];
            return;
        }
        
        if (bufferSize <= 0) {
            bufferSize = chunk.size;
            outputSize = 0;
            [DebLog logN:@"sendChunk -> started ( out %d, rest %d ) bytes ---->", outputSize, bufferSize];
        }
        
        // single transaction is limited by RTMP_TRANSACTION_SIZE
        int size = (bufferSize < RTMP_TRANSACTION_SIZE) ? bufferSize : RTMP_TRANSACTION_SIZE;
        memmove(outputBuffer, &chunk.buffer[outputSize], size);
        int result = [outputStream write:outputBuffer maxLength:size];
        if (result < 0) {
            NSError *error = [outputStream streamError];
            [DebLog logY:@"RTMPClient -> sendChunk: result = %d (error code = %d <%@>)", result, [error code], [error localizedDescription]];
            return;
        }
        
        outputSize += result;
        bufferSize -= result;
        if (bufferSize <= 0)
            [rtmp sentChunk];
        
        [DebLog log:_OUTPUT_CHANK_ text:@"sendChunk -> wrote %d ( out %d, rest %d ) bytes ---->", result, outputSize, bufferSize];
    }
}

-(void)receiveChunk {
	
	NSInteger len = [inputStream read:inputBuffer maxLength:RTMP_BUFFER_SIZE];
    if (len < 0) {
        NSError *error = [inputStream streamError];
        [DebLog logY:@"RTMPClient -> receiveChunk: result = %d (error code = %d <%@>)", len, [error code], [error localizedDescription]];
        return;
	}
	
	[DebLog logN:@"receiveChunk -> read %d bytes <---", len];
	
	BinaryStream *chunk = [[BinaryStream alloc] initWithStream:(char *)inputBuffer andSize:len];
	[chunk print:NO];
	[rtmp receivedChunk:chunk];
	[chunk release];
}

-(int)nextInvokeId {
	return invokeId++;
}

-(NSString *)keyByIntId:(int)intId {
	return [NSString stringWithFormat:@"%d", intId];
}

-(int)intIdByKey:(NSString *)strKey {
	return [strKey intValue];
}

-(NSString *)randomSOName {
    return [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
}


// EVENTS

-(void)errorOccured:(NSError *)error {
    
	[self eraseSocket];
    [self connectFailedEvent:[error code] description:[error localizedDescription]];
}

-(void)endEncountered {
    
	[self eraseSocket];
    [self connectFailedEvent:-12 description:@"NSStreamEventEndEncountered"];
}

#pragma mark -
#pragma mark NSStreamDelegate Methods

-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	
	[DebLog logN:@"STREAM %@ handleEvent [%@]", stream, [NSThread isMainThread]?@"M":@"T"];
    
    if (state == STATE_DISCONNECTED)
        return;
    
    // common events
	if (inputStream && outputStream) 
        switch (eventCode) {
            case NSStreamEventErrorOccurred: {
                
                NSError *error = [stream streamError];
                
                [DebLog logY:@"RTMPClient <NSStreamDelegate> NSStreamEventErrorOccurred: domain = %@, code = %d (%@)", [error domain], [error code], [error localizedDescription]];
                
                [self performSelector:@selector(errorOccured:) withObject:error afterDelay:0.1f];
                break;
            }
            case NSStreamEventEndEncountered: {
                                
                [DebLog logY:@"RTMPClient <NSStreamDelegate> NSStreamEventEndEncountered: stream = %@ [%@]", stream, [NSThread isMainThread]?@"M":@"T"];
                
                [self performSelector:@selector(endEncountered) withObject:nil afterDelay:0.1f];
                break;
            }
            default:
                break;
        }
	
    // output events
    if (stream == outputStream)
		switch (eventCode) {
			case NSStreamEventOpenCompleted: {
				[DebLog logN:@"RTMPClient <NSStreamDelegate> NSStreamEventOpenCompleted -> outputStatus: %d", [outputStream streamStatus]];
				break;
			}
			case NSStreamEventHasSpaceAvailable: {				
				[DebLog log:_OUTPUT_CHANK_ text:@"RTMPClient <NSStreamDelegate> NSStreamEventHasSpaceAvailable -> outputStatus: %d, RTMP state = %d", [outputStream streamStatus], state];
				
                switch (state) {
					case STATE_HANDSHAKE:
                        if (useSSL)
                            [self performSelector:@selector(sendFirstHandshake) withObject:nil afterDelay:0.5f];
                        else
                            [self sendFirstHandshake];
                        break;
					case STATE_CONNECTED:
						[self sendChunk];
						break;
					default:
						break;
				}
				break;
			}
            default:
                break;
		}
	
    // input events
    if (stream == inputStream)
		switch (eventCode) {
			case NSStreamEventOpenCompleted: {
				[DebLog logN:@"RTMPClient <NSStreamDelegate> NSStreamEventOpenCompleted -> inputStatus: %d", [inputStream streamStatus]];
				break;
			}
			case NSStreamEventHasBytesAvailable: {
				[DebLog logN:@"RTMPClient <NSStreamDelegate> NSStreamEventHasBytesAvailable -> inputStatus: %d, RTMP state = %d", [inputStream streamStatus], state];
				
				switch (state) {
					case STATE_HANDSHAKE:
						[self receiveHandshake];
						break;
					case STATE_CONNECT:
					case STATE_CONNECTED:
						[self receiveChunk];
						break;
					default:
						break;
				}
				break;
			}
            default:
                break;
		}
}

@end


@implementation RTMPClient (IRTMPClientDelegate)

-(void)connectedEventThreaded {
    
    @synchronized (owners) {
        
        if (owners.count)
            for (id <IRTMPClientDelegate> owner in owners)
                if ([owner respondsToSelector:@selector(connectedEvent)]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [owner connectedEvent];
                    });
                }
    }
}

-(void)disconnectedEventThreaded {
    
    [self eventFailed:-6 description:@"Socket was disconnected (-6)"];
    
    @synchronized (owners) {
        
        if (owners.count)
            for (id <IRTMPClientDelegate> owner in owners)
                if ([owner respondsToSelector:@selector(disconnectedEvent)]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [owner disconnectedEvent];
                    });
                }
    }
}

-(void)connectFailedEventThreaded:(NSString *)description {
    
    [self eventFailed:-7 description:description];
    
    @synchronized (owners) {
        
        if (owners.count)
            for (id <IRTMPClientDelegate> owner in owners)
                if ([owner respondsToSelector:@selector(connectFailedEvent:description:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [owner connectFailedEvent:-7 description:description];
                    });
                }
    }
}

-(void)resultReceivedThreaded:(id <IServiceCall>)call {
    
    @synchronized (owners) {
        
        [DebLog log:@"RTMPClient -> resultReceived: owners.count = %d", owners.count];
        
        if (owners.count) {
            
            for (id <IRTMPClientDelegate> owner in owners) {
                if ([owner respondsToSelector:@selector(resultReceived:)]) {
                    [owner performSelector:@selector(resultReceived:) withObject:call];
                }
                else {
                    [DebLog log:@"RTMPClient -> resultReceived: owner = %@ have not this selector!", owner];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark IRTMPClientDelegate Methods

 
-(void)connectedEvent {
    [self performSelector:@selector(connectedEventThreaded) onThread:socketThread withObject:nil waitUntilDone:NO];
}

-(void)disconnectedEvent {
    [self performSelector:@selector(disconnectedEventThreaded) onThread:socketThread withObject:nil waitUntilDone:NO];
}

-(void)connectFailedEvent:(int)code description:(NSString *)description {
    NSString *event = [[NSString stringWithFormat:@"fault code = %d < %@ >", code, description] retain];
    ([NSThread currentThread] == socketThread) ? [self connectFailedEventThreaded:event] :
    [self performSelector:@selector(connectFailedEventThreaded:) onThread:socketThread withObject:event waitUntilDone:YES];
}

-(void)resultReceived:(id <IServiceCall>)call {
    ([NSThread currentThread] == socketThread) ? [self resultReceivedThreaded:call] :
    [self performSelector:@selector(resultReceivedThreaded:) onThread:socketThread withObject:call waitUntilDone:YES];
}

@end


@implementation RTMPClient (IRTMProtocol)

#pragma mark -
#pragma mark Private Event Methods

-(void)onValidation:(Packet *)message {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:message.data.buffer andSize:message.data.size];
	int pingEvent = [reader readUnsignedShort];
    [reader release];
	
	[DebLog log:@"<<<<<<<<<<<<<<<<<< ping (???) event = %d", pingEvent];
	
	Packet *_message = [Packet packet];
	// header
	_message.header.dataType = TYPE_PING;
	_message.header.channelId = 2;
	// body "pong"
	[_message.data writeUInt16:PONG_SERVER];
	[_message.data writeUInteger:(int)CFAbsoluteTimeGetCurrent()];
	[self sendMessage:_message];
    
    [DebLog log:@">>>>>>>>>>>>>>>>>>> pong"];
    
}

-(void)onPing:(Packet *)message {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:message.data.buffer andSize:message.data.size];
	int pingEvent = [reader readUnsignedShort];
    [reader release];
	
	[DebLog log:@"<<<<<<<<<<<<<<<<<< ping event = %d", pingEvent];
    
    if (pingEvent != PING_CLIENT)
        return;
	
	Packet *_message = [Packet packet];
	// header
	_message.header.dataType = TYPE_PING;
	_message.header.channelId = 2;
	// body "pong"
	[_message.data writeUInt16:PONG_SERVER];
	[_message.data writeUInteger:(int)CFAbsoluteTimeGetCurrent()];
	[self sendMessage:_message];
    
    [DebLog log:@">>>>>>>>>>>>>>>>>>> pong"];
}

-(void)onChunkSize:(Packet *)message {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:message.data.buffer andSize:message.data.size];
	int chunkSize = [reader readInteger];
    [reader release];
    
    if (chunkSize) rtmp.readChunkSize = chunkSize;
	
	[DebLog log:@">>>>>>>>>>>>>>>>>>> setChunkSize = %d", chunkSize];
}

-(void)onServerBandwidth:(Packet *)message {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:message.data.buffer andSize:message.data.size];
	int bandwidth = [reader readInteger];
    [reader release];
 	
	[DebLog log:@">>>>>>>>>>>>>>>>>>> server bandwidth = %d", bandwidth];
	
	Packet *_message = [Packet packet];
	// header
	_message.header.dataType = TYPE_SERVER_BANDWIDTH;
	_message.header.channelId = 2;	
	// body "server bandwidth"
	[_message.data writeUInteger:bandwidth];	
	[self sendMessage:_message];
}

-(void)onClientBandwidth:(Packet *)message {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:message.data.buffer andSize:message.data.size];
	int bandwidth= [reader readInteger];
    [reader release];
	
	[DebLog log:@">>>>>>>>>>>>>>>>>>> client bandwidth = %d", bandwidth];
}

-(void)onInvoke:(Packet *)message {
    
    Invoke *invoke = (Invoke *)message.message;            
    NSString *invokeKey = [self keyByIntId:invoke.invokeId];
    [invoke.call setInvokeId:invoke.invokeId];
    
    Call *callback = (state == STATE_CONNECTED) ? [pendingCalls get:invokeKey] : nil;
    if (callback) {
        id <IPendingServiceCallback> sender = callback.sender;
        [DebLog log:@"RTMPClient -> onInvoke (PENDING): invokeId = %@, sender = %@", invokeKey, callback.sender];
        if (sender) {
            [sender resultReceived:invoke.call];
        }
        [pendingCalls pop:invokeKey withObject:callback];
    }
    else {
        Call *call = invoke.call;
        call.status = STATUS_SUCCESS_RESULT;
        
        [DebLog log:@"RTMPClient -> onInvoke: call.serviceMethodName = %@ <NSString ? %@>, call.arguments.count = %d", call.serviceMethodName, [call.serviceMethodName isKindOfClass:[NSString class]]?@"YES":@"NO", call.arguments.count];
        
        if ([call.serviceMethodName isKindOfClass:[NSString class]] && [call.serviceMethodName isEqualToString:@"_result"]) {
            
            if (call.arguments.count > 0) {
                
                NSDictionary *dict = [call.arguments objectAtIndex:0];
                NSString *code = [dict isKindOfClass:[NSDictionary class]] ? [dict valueForKey:@"code"] : nil;
                
                if (code && [code isKindOfClass:[NSString class]] && [code isEqualToString:@"NetConnection.Connect.Success"]) {
                    
                    [DebLog log:@"RTMPClient -> onInvoke: call.arguments = %@\n", call.arguments];
                    
                    state = STATE_CONNECTED;
                    
                    @synchronized (pendingMessages) {
                        
                        // send all pending messages
                        if (pendingMessages.count) {
                            
                            [DebLog log:@"RTMPClient -> onInvoke: pendingMessages.count = %d", pendingMessages.count];
                            
                            for (int i = 0; i < pendingMessages.count; i++)
                                if (![rtmp sendMessage:(Packet *)[pendingMessages objectAtIndex:i]])
                                    [DebLog logY:@"ERROR: RTMPClient -> onInvoke: pending message didn't add for sending"];
                            
                            if ([rtmp shouldSendMessage])
                                [self sendChunk];
                            
                            [pendingMessages removeAllObjects];
                        }
                    }
                   
                    [self connectedEvent];
                    
                    return;
                }
            }
        }
        
        [self resultReceived:call];
    }
}

#pragma mark -
#pragma mark Private Methods

-(id <IStreamDispatcher>)getStream:(Packet*)message {
    
    NSString *key = [self keyByIntId:message.header.streamId];
    id <IStreamDispatcher> stream = [streamPlayers get:key];
    if (!stream) {
        [DebLog log:@"RTMPClient -> getStream: No stream player is for streamId = %@", key];
        return nil;
    }
    
    return stream;
}

-(bool)checkTimestampValidity:(Packet*)message {
    return true;
}

-(void)dispatchMultimediaFrame:(id <IStreamPacket, IRTMPEvent>)frame message:(Packet*)message {
	
    [DebLog logN:@"RTMPClient -> dispatchMultimediaFrame: channelId = %d, dataType = 0x%02x, data.size = %d", message.header.channelId, message.header.dataType, message.data.size];
    
    id <IStreamDispatcher> stream = [self getStream:message];
    if (!stream)
        return;
    
    [frame setSourceType:SOURCE_TYPE_LIVE];
    [frame setTimestamp:message.header.timerDelta];
    [stream dispatchEvent:frame];
}

#pragma mark -
#pragma mark IRTMProtocol Methods

-(void)receivedMessage:(Packet *)message {
	
	int channelId = message.header.channelId;
	uint dataType = message.header.dataType;

	[DebLog logN:@"RTMPClient -> receivedMessage: channelId = %d, dataType = 0x%02x, data.size = %d", channelId, dataType, message.data.size];
    [message.data print:NO];

	//******************* PROCESS ***********************
	
	switch (dataType) {
        
        // CHUNK_SIZE
		case TYPE_CHUNK_SIZE: {
			if (channelId == 2) {
				[DebLog logN:@"RTMPClient -> receivedMessage: CHUNK_SIZE"];
				[self onChunkSize:message];
				return;
			}
			break;
		}
#if 0
        // TYPE_BYTES_READ
		case TYPE_BYTES_READ: {
			if (channelId == 2) {
				[DebLog logN:@"RTMPClient -> receivedMessage: TYPE_BYTES_READ"];
				[self onValidation:message];
				return;
			}
			break;
		}
#endif
            
		// PING
		case TYPE_PING: {
			if (channelId == 2) {
				[DebLog logN:@"RTMPClient -> receivedMessage: USER CONTROL MESSAGE (PING)"];
				[self onPing:message];
				return;
			}
			break;
		}
            
        // SERVER_BANDWIDTH
		case TYPE_SERVER_BANDWIDTH: {
			if (channelId == 2) {
				[DebLog logN:@"RTMPClient -> receivedMessage: SERVER_BANDWIDTH"];
				[self onServerBandwidth:message];
				return;
			}
			break;
		}
            
        // CLIENT_BANDWIDTH
		case TYPE_CLIENT_BANDWIDTH: {
			if (channelId == 2) {
				[DebLog logN:@"RTMPClient -> receivedMessage: CLIENT_BANDWIDTH"];
				[self onClientBandwidth:message];
				return;
			}
			break;
		}
            
        // FLEXINVOKE
        case TYPE_FLEXINVOKE: {
			[[BaseRTMPProtocolDecoder decoder] decodePacket:message];
            FlexMessage *flexInvoke = (FlexMessage *)message.message;
            NSArray *args = [flexInvoke.call getArguments];
            id obj = (args && (args.count > 0)) ? [args objectAtIndex:0] : nil;
            
            [DebLog logN:@"RTMPClient -> receivedMessage: (TYPE_FLEXINVOKE) invokeId = %d, obj = %@", flexInvoke.invokeId, obj];
            
            if (!obj || !flexInvoke.invokeId) {
                [self onInvoke:message];
                
                return;
            }
            
            if (![obj isKindOfClass:[V3Message class]]) {
                    
                return;
            }
            
            //-----------------------------------------------------------
            
            NSString *invokeKey = [self keyByIntId:flexInvoke.invokeId];
            [flexInvoke.call setInvokeId:flexInvoke.invokeId];
            
            PendingCall *callback = (state == STATE_CONNECTED) ? [pendingCalls get:invokeKey] : nil;
            if (callback) {
                [callback setResult:obj];
                NSArray *callbacks = [callback getCallbacks];
                [DebLog logN:@"RTMPClient -> receivedMessage: callbacks = %d", (callbacks)?callbacks.count:-1];
                if (callbacks && callbacks.count)
                    for (id <IPendingServiceCallback> sender in callbacks)
                        if (sender) {
                            [sender resultReceived:callback];
                        }
                [pendingCalls pop:invokeKey withObject:callback];
            }
            
            //-------------------------------------------------------------
            
            break;
        }
            
		// NOTYFY & METADATA
        case TYPE_NOTIFY: {
            [[BaseRTMPProtocolDecoder decoder] decodePacket:message];
            if ([message.message isMemberOfClass:[NotifyEvent class]]) {
                [self onInvoke:message];
                break;
            }
            
            id <IRTMPEvent, IStreamPacket> frame = (id <IRTMPEvent, IStreamPacket>)message.message;
            [self dispatchMultimediaFrame:frame message:message];
            break;
        }
        
        // INVOKE
		case TYPE_INVOKE: {
			[[BaseRTMPProtocolDecoder decoder] decodePacket:message];
			[self onInvoke:message];
            break;
		}
            
        // SHARED OBJECT	
		case TYPE_SHARED_OBJECT: {
#if 0
            NSLog(@"RTMPClient -> receivedMessage: (TYPE_SHARED_OBJECT)\n");
            [message.data print:YES];
#endif
			[[BaseRTMPProtocolDecoder decoder] decodePacket:message];
			SharedObjectMessage *msg = (SharedObjectMessage *)message.message;
            
            [DebLog logN:@"RTMPClient -> receivedMessage: (TYPE_SHARED_OBJECT) %@", msg];
            
            ClientSharedObject *so = [sharedObjects get:[msg getName]];
            if (!so) {
                [DebLog log:@"RTMPClient -> receivedMessage: Ignoring request for non-existend SO: %@", msg];
                return;
            } 
#if 0
            if ([so isPersistentObject] != [msg isPersistent]) {
                [DebLog log:@"RTMPClient -> receivedMessage: Ignoring request for wrong-persistent SO: %@ <> %@", @([so isPersistentObject]), @([msg isPersistent])];
                //return; // TEMP !!!!
            }
#endif
            [so dispatchEvent:msg];
            break;
        }
            
        // AUDIO DATA & VIDEO DATA
		case TYPE_AUDIO_DATA:
        case TYPE_VIDEO_DATA: {
            [[BaseRTMPProtocolDecoder decoder] decodePacket:message];            
            if (![self checkTimestampValidity:message])
                break;          
            
            id <IRTMPEvent, IStreamPacket> frame = (id <IRTMPEvent, IStreamPacket>)message.message; 
            
            [DebLog logN:@"RTMPClient -> receivedMessage: non aggregate multimedia:\n HEADER = %@\ntype = %d, timestamp = %d, size = %lu", [message.header toString], dataType, [message.header getTimer], [frame getData].size];
            
            [self dispatchMultimediaFrame:frame message:message];      
            break;
        }
            
        // AGGREGATE
        case TYPE_AGGREGATE: {
			[[BaseRTMPProtocolDecoder decoder] decodePacket:message];            
            if (![self checkTimestampValidity:message])
                break;
            
            NSArray* events = [(Aggregate *)message.message getEvents];
            for (id <IRTMPEvent, IStreamPacket> frame in events) {
                
                [DebLog logN:@"RTMPClient -> receivedMessage: aggregate multimedia:\n HEADER = %@\ntype = %d, timestamp = %d, size = %lu", [message.header toString], dataType, [message.header getTimer], [frame getData].size];
                
                [self dispatchMultimediaFrame:frame message:message];
            }
            break;
        }
        
        // Unknown
        default: {
            [DebLog logN:@"RTMPClient -> receivedMessage: (UNKNOWN) HEADER = %@\n", [message.header toString]];
            [message.data print:NO];
			break;
        }
	}
	
	//***************************************************
	
    [DebLog logN:@"RTMPClient -> receivedMessage: FINISHED"];
}

@end


@implementation RTMPClient (IClientSharedObjectDelegate)

#pragma mark -
#pragma mark IClientSharedObjectDelegate Methods

-(void)makeUpdateMessage:(id <ISharedObjectMessage>)message {
    
	Packet *msg = [Packet packet];	
	// header
	msg.header.dataType = TYPE_SHARED_OBJECT;
	msg.header.channelId = DEFAULT_CHANNEL_ID;
	msg.header.streamId = DEFAULT_STREAM_ID;
	// body
	BinaryStream *body = [[BaseRTMPProtocolEncoder coder] encodeMessage:message];
	[msg.data write:body.buffer length:body.size];
	[self sendMessage:msg];
#if 0
    NSLog(@"RTMPClient -> makeUpdateMessage: (TYPE_SHARED_OBJECT)\n");
    [msg.data print];
#endif
}

@end


@implementation AsynCall

-(id)initWithCall:(id)processor method:(SEL)sel {
    
    self = [super init];
    
    if ( self ) {
        owner = processor;
        method = sel;
    }
    return self;
}

+(id)call:(id)processor method:(SEL)sel {
    return [[[AsynCall alloc] initWithCall:processor method:sel] autorelease];
}

#pragma mark -
#pragma mark IPendingServiceCallback Methods 

-(void)resultReceived:(id <IServiceCall>)call {
    
    if ([call getStatus] != STATUS_PENDING) // this call is not a server response
        return;
   
    NSArray *args = [call getArguments];
    id result = (args.count) ? [args objectAtIndex:0] : nil;
    
    if ([owner respondsToSelector:method])
        [owner performSelector:method withObject:result];
}

-(void)connectFailedEvent:(int)code description:(NSString *)description {
}

@end

