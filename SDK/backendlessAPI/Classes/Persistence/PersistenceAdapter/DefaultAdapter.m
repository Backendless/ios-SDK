//
//  DefaultAdapter.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "DefaultAdapter.h"
#import "IAdaptingType.h"
#import "V3Message.h"
#import "ErrMessage.h"
#import "Responder.h"

@implementation DefaultAdapter

-(id)adapt:(id)type {
    V3Message *v3 = (V3Message *)[type defaultAdapt];
    if (v3.isError) {
        ErrMessage *result = (ErrMessage *)v3;
        return [Fault fault:result.faultString detail:result.faultDetail faultCode:result.faultCode];
    }
    return v3.body.body;
}

@end
