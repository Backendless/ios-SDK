//
//  RTMPConstants.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 16.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

// Data originated from a live encoder or stream.

#define DEFAULT_RTMP_PORT 1935
#define DEFAULT_CHUNK_SIZE 128
#define CHUNK_HEADER_MASK 0xC0
#define CHUNK_STREAM_MASK 0x3F
#define SOURCE_TYPE_LIVE  0x01
#define MEDIUM_INT_MAX 16777215
#define HANDSHAKE_SIZE 1536
//#define RTMP_BUFFER_SIZE 65535
#define RTMP_BUFFER_SIZE 0x20000
//#define RTMP_TRANSACTION_SIZE 1024
#define RTMP_TRANSACTION_SIZE 0x20000
#define IS_EXT_TIMESTAMP 0xFFFFFF

#define AS_ARRAY_MAP @"serializeAsArrayMap"
#define AS_ARRAY_METADATA @"serializeAsMetaData"

// maximum possible number of different RTMP channels
#define RTMP_CHANNELS 65599

typedef enum rtmp_channel RTMPChannel;
typedef enum rtmp_state ProtocolState;
typedef enum rtmp_headertype RTMPHeaderType;
typedef enum rtmp_messagetype RTMPMessageType;
typedef enum rtmp_stateso RTMPStateSO;

// channels used to for RTMP packets with different purposes (i.e. data, network control, remote procedure calls, etc.)
enum rtmp_channel
{
    RTMP_NETWORK_CHANNEL = 2,   ///< channel for network-related messages (bandwidth report, ping, etc)
    RTMP_SYSTEM_CHANNEL,        ///< channel for sending server control messages
    RTMP_SOURCE_CHANNEL,        ///< channel for sending a/v to server
    RTMP_VIDEO_CHANNEL = 8,     ///< channel for video data
    RTMP_AUDIO_CHANNEL,         ///< channel for audio data
};

enum rtmp_state
{
    STATE_HANDSHAKE = 0x00,
    STATE_CONNECT = 0x01,
    STATE_CONNECTED = 0x02,
    STATE_DISCONNECTED = 0x03,
    STATE_NEED_CONNECT = 0x04,
    //
    STATE_LOCKED = 0xFF,
};

enum rtmp_headertype
{
    HEADER_NEW = 0x00,
    HEADER_SAME_SOURCE = 0x01,
    HEADER_TIMER_CHANGE = 0x02,
    HEADER_CONTINUE = 0x03,
};

enum rtmp_messagetype
{
    TYPE_CHUNK_SIZE = 0x01,
    TYPE_ABORT = 0x02,
    TYPE_BYTES_READ = 0x03,
    TYPE_PING = 0x04,
    TYPE_SERVER_BANDWIDTH = 0x05,
    TYPE_CLIENT_BANDWIDTH = 0x06,
    // Unknown: 0x07
    TYPE_AUDIO_DATA = 0x08,
    TYPE_VIDEO_DATA = 0x09,
    // Unknown: 0x0A ...  0x0D
    TYPE_STREAM_METADATA_AMF3 = 0x0E,
    TYPE_FLEX_STREAM_SEND = 0x0F,
    TYPE_FLEX_SHARED_OBJECT = 0x10,
    TYPE_FLEXINVOKE = 0x11,
    TYPE_NOTIFY = 0x12,
    TYPE_SHARED_OBJECT = 0x13,
    TYPE_INVOKE = 0x14,
    TYPE_AGGREGATE = 0x16,
};

enum rtmp_stateso
{
    SO_CLIENT_UPDATE_DATA = 0x04, //update data
    SO_CLIENT_UPDATE_ATTRIBUTE = 0x05, //5: update attribute
    SO_CLIENT_SEND_MESSAGE = 0x06,  // 6: send message
    SO_CLIENT_STATUS = 0x07,  // 7: status (usually returned with error messages)
    SO_CLIENT_DELETE_DATA = 0x09, // 9: delete data
    SO_CLIENT_INITIAL_DATA = 0x0B, // 11: initial data
	//
    SO_CONNECT = 0x01,
    SO_DISCONNECT = 0x02,
    SO_SET_ATTRIBUTE = 0x03,
    SO_SEND_MESSAGE = 0x06,
    SO_DELETE_ATTRIBUTE = 0x0A,
    SO_LIST = 0x0B,
    SO_CONNECT_OK = 0x08,  
};

enum audio_codecs
{
    SUPPORT_SND_NONE = 0x0001,
    SUPPORT_SND_ADPCM = 0x0002,
    SUPPORT_SND_MP3 = 0x0004,
    SUPPORT_SND_NELLY8 = 0x0020,
    SUPPORT_SND_NELLY = 0x0040,
    SUPPORT_SND_G711A = 0x0080,
    SUPPORT_SND_G711U = 0x0100,
    SUPPORT_SND_NELLY16 = 0x0200,
    SUPPORT_SND_AAC = 0x0400,
    SUPPORT_SND_SPEEX = 0x0800,
    SUPPORT_SND_ALL = 0x0FFF,
    SUPPORT_SND_DEFAULT = SUPPORT_SND_AAC,
};

enum video_codecs
{
    SUPPORT_VID_UNUSED = 0x0001,
    SUPPORT_VID_JPEG = 0x0002,
    SUPPORT_VID_SORENSON = 0x0004,
    SUPPORT_VID_HOMEBREW = 0x0008,
    SUPPORT_VID_VP6 = 0x0010,
    SUPPORT_VID_VP6ALPHA = 0x0020,
    SUPPORT_VID_HOMEBREWV = 0x0040,
    SUPPORT_VID_H264 = 0x0080,
    SUPPORT_VID_ALL = 0x00FF,
    SUPPORT_VID_DEFAULT = SUPPORT_VID_H264,
};

/*/ actions
const NSString *ACTION_CONNECT = @"connect";
const NSString *ACTION_DISCONNECT = @"disconnect";
const NSString *ACTION_CREATE_STREAM = @"createStream";
const NSString *ACTION_DELETE_STREAM = @"deleteStream";
const NSString *ACTION_RELEASE_STREAM = @"releaseStream";
const NSString *ACTION_CLOSE_STREAM = @"closeStream";
const NSString *ACTION_PUBLISH = @"publish";
const NSString *ACTION_PAUSE = @"pause";
const NSString *ACTION_PAUSE_RAW = @"pauseRaw";
const NSString *ACTION_SEEK = @"seek";
const NSString *ACTION_PLAY = @"play";
const NSString *ACTION_STOP = @"disconnect";
const NSString *ACTION_RECEIVE_VIDEO = @"receiveVideo";
const NSString *ACTION_RECEIVE_AUDIO = @"receiveAudio";
const NSString *ACTION_INIT_STREAM = @"initStream";

// thread contect constants
const NSString *TC_CONNECTION = @"rtmp.tc.conn";
const NSString *TC_STREAMID = @"rtmp.tc.streamid";
const NSString *TC_CHANNELID = @"rtmp.tc.channelid";

const NSString *TRANSIENT_PREFIX = @"_transient";
const NSString *WEB_SOCKET_MODE = @"webSocketMode";
/*/
