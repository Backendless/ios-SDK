//
//  MPCodecIDMapping.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 10/13/13.
//  Copyright (c) 2013 themidnightcoders.com. All rights reserved.
//

#include "libavcodec/version.h"

// new -> old codec ids mapping 
#if LIBAVCODEC_VERSION_MAJOR < 55

#define AV_CODEC_ID_MP3 CODEC_ID_MP3
#define AV_CODEC_ID_AAC CODEC_ID_AAC
#define AV_CODEC_ID_SPEEX CODEC_ID_SPEEX
#define AV_CODEC_ID_PCM_U8 CODEC_ID_PCM_U8
#define AV_CODEC_ID_PCM_S16BE CODEC_ID_PCM_S16BE
#define AV_CODEC_ID_PCM_S16LE CODEC_ID_PCM_S16LE
#define AV_CODEC_ID_ADPCM_SWF CODEC_ID_ADPCM_SWF
#define AV_CODEC_ID_NELLYMOSER CODEC_ID_NELLYMOSER
#define AV_CODEC_ID_PCM_MULAW CODEC_ID_PCM_MULAW
#define AV_CODEC_ID_PCM_ALAW CODEC_ID_PCM_ALAW
#define AV_CODEC_ID_VP6 CODEC_ID_VP6
#define AV_CODEC_ID_VP6F CODEC_ID_VP6F
#define AV_CODEC_ID_H264 CODEC_ID_H264
#define AV_CODEC_ID_FLV1 CODEC_ID_FLV1
#define AV_CODEC_ID_NONE CODEC_ID_NONE

#endif
