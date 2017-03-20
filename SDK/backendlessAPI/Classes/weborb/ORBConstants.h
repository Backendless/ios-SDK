//
//  ORBConstants.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#define ORBConstants_DESCRIBE_SERVICE @"DescribeService"
#define ORBConstants_INSPECTSERVICE @"InspectService"

//logging config constants
#define ORBConstants_NAME @"name"
#define ORBConstants_CLASS @"class"
#define ORBConstants_TYPE @"type"
#define ORBConstants_SERVICEID @"serviceId"
#define ORBConstants_LOG @"log"
#define ORBConstants_ENABLE @"enable"
#define ORBConstants_YES @"yes"
#define ORBConstants_NO @"no"

#define ORBConstants_CURRENT_POLICY @"currentPolicy"
#define ORBConstants_DATE_FORMATTER @"dateFormatter"    
#define ORBConstants_LOG_THREAD_NAME @"logThreadName"
#define ORBConstants_LOGGING_POLICY @"loggingPolicy"
#define ORBConstants_POLICY_NAME @"policyName"
#define ORBConstants_CLASS_NAME @"className"
#define ORBConstants_PARAMETER @"parameter"
#define ORBConstants_VALUE @"value"
#define ORBConstants_FILE_NAME @"fileName"

//call trace config constants
#define ORBConstants_QUEUE_FLUSH_THRESHOLD @"queueFlushThreshold"
#define ORBConstants_QUEUE_CHECK_WAIT_TIME @"queueCheckWaitTime"
#define ORBConstants_CALL_STORE_FOLDER @"callStoreFolder"
#define ORBConstants_CALL_STORE_BUFFER_SIZE @"callStoreBufferSize"
#define ORBConstants_MAX_CALLS_PER_FILE @"maxCallsPerCallStoreFile"

#define ORBConstants_TRC_ZIP @"-trc.zip"
#define ORBConstants_CALLTRACE @"calltrace"
#define ORBConstants_UNABLE_CREATE_CALLTRACE_FILE @"unable to create call trace file"

#define ORBConstants_ONRESULT @"/onResult"
#define ORBConstants_ONSTATUS @"/onStatus"
#define ORBConstants_NONE_HANDLERS_INSPECT_TARGETSERVICE @"None of the handlers were able to inspect the target service. The service may not be found: "

//console constants
#define ORBConstants_HTTP @"http"
#define ORBConstants_HTTPS @"https"

#define ORBConstants_GATEWAYURL_EQUALS @"gatewayURL="
#define ORBConstants_CHAR_COLONSLASHSLASH @"://"
#define ORBConstants_CHAR_COLON @":"
#define ORBConstants_ANDPERSANDHOSTADDRESS @"&hostAddress="

#define ORBConstants_REQUEST_ACTION_PARAM @"action"
#define ORBConstants_CONSOLE_ACTION_SERVICE_UPLOAD @"ConsoleServiceUpload"

// metadata constants
#define ORBConstants_CLIENT_ID @"clientId"
#define ORBConstants_REQUEST_HEADERS @"requestHeaders"
#define ORBConstants_RESPONSE_METADATA @"responseMetadata"
#define ORBConstants_CLIENT_MAPPING @"clientMapping_"
#define ORBConstants_REQUEST_IP @"requestIP"    

// service context
#define ORBConstants_ACTIVATION @"activation"

#define ORBConstants_SERVER @"server"
#define ORBConstants_ALLOW_SUBTOPICS @"allow-subtopics"

#define ORBConstants_MESSAGE_SERVICE_HANDLER @"message-service-handler"
#define ORBConstants_MESSAGE_STORAGE_POLICY @"message-storage-policy"
#define ORBConstants_MESSAGE_HANDLER @"message-factory"
#define ORBConstants_MP3_REQUEST_SUFFIX @"_to_mp3"

#define ORBConstants_DISCONNECT_SECONDS @"diconnect-seconds"

#define ORBConstants_IsRTMPChannel @"IsRTMP"

// this constant is duplicated on javascript side (keep it consistent)
#define ORBConstants_CLASS_NAME_FIELD @"javascript_class_alias"

// Azure
#define ORBConstants_STORAGE_ACCOUNT_CONFIGURATION @"DataConnectionString"
#define ORBConstants_WEBORB_AZURE_CONTAINER @"weborb"
#define ORBConstants_LOCAL_STORAGE @"MessagingStorage"

#define ORBConstants_CHANNEL_MY_LONG_POLLING_AMF @"my-long-polling-amf"
