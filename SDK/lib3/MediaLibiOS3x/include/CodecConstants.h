//
//  CodecConstants.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 8/12/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

typedef enum aidio_codec AudioCodecEnum;
enum aidio_codec 
{
    PCM = 0x00, 
    ADPCM = 0x01, 
    MP3 = 0x02, 
    PCM_LE = 0x03,
    NELLY_MOSER_16K = 0x04, 
    NELLY_MOSER_8K = 0x05, 
    NELLY_MOSER = 0x06,
    PCM_ALAW = 0x07, 
    PCM_MULAW = 0x08, 
    RESERVED = 0x09,
    AAC = 0x0A, 
    SPEEX = 0x0B, 
    MP3_8K = 0x0E,
    DEVICE_SPECIFIC = 0x0F,
    };

typedef enum video_codec VideoCodecEnum;
enum video_codec
{
    JPEG = 0x01, 
    H263 = 0x02, 
    SCREEN_VIDEO = 0x03, 
    VP6 = 0x04,
    VP6a = 0x05, 
    SCREEN_VIDEO2 = 0x06, 
    AVC = 0x07,
};

typedef enum video_frame_type VideoDataFrameTypeEnum;
enum video_frame_type
{
    UNKNOWNFRAME = 0,
    KEYFRAME = 1,
    INTERFRAME = 2,
    DISPOSABLE_INTERFRAME = 3,
};

typedef enum tag_constants TagConstants;
enum tag_constants
{    
    MASK_SOUND_TYPE = 0x01,
    FLAG_TYPE_MONO = 0x00,
    FLAG_TYPE_STEREO = 0x01,
    
    MASK_SOUND_SIZE = 0x02,
    FLAG_SIZE_8_BIT = 0x00,
    FLAG_SIZE_16_BIT = 0x01,
    
    MASK_SOUND_RATE = 0x0C,
    FLAG_RATE_5_5_KHZ = 0x00,
    FLAG_RATE_11_KHZ = 0x01,
    FLAG_RATE_22_KHZ = 0x02,
    FLAG_RATE_44_KHZ = 0x03,
    
    MASK_SOUND_FORMAT = 0xF0, // ?
    FLAG_FORMAT_RAW = 0x00,
    FLAG_FORMAT_ADPCM = 0x01,
    FLAG_FORMAT_MP3 = 0x02,
    FLAG_FORMAT_NELLYMOSER_8_KHZ = 0x05,
    FLAG_FORMAT_NELLYMOSER = 0x06,
    
    MASK_VIDEO_CODEC = 0x0F,
    MASK_VIDEO_FRAMETYPE = 0xF0, 
};
