  //
//  EUExLocation.m
//  AppCan
//
//  Created by AppCan on 11-9-7.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "EUExLocation.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"
#import "SBJSON.h"
#import "JSON.h"

@implementation EUExLocation
{
    int flage;
}

-(id)initWithBrwView:(EBrowserView *) eInBrwView{
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc{
	if (myLocation) {
		[myLocation closeLocation];
		[myLocation release];
		myLocation = nil;
	}
	[super dealloc];
}
-(void)openLocation:(NSMutableArray *)inArguments {
    if (![CLLocationManager locationServicesEnabled]) {
        //设备未打开定位服务
        [self jsSuccessWithName:@"uexLocation.cbOpenLocation" opId:0  dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        // 当前程序未打开定位服务
        [self jsSuccessWithName:@"uexLocation.cbOpenLocation" opId:0  dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
        return;
    }
     myLocation = [[Location alloc] initWithEuexObj:self];
    [myLocation openLocation:inArguments];
}
-(void)closeLocation:(NSMutableArray *)inArguments{
    if (myLocation) {
        [myLocation closeLocation];
    }
}

-(void)getAddress:(NSMutableArray *)inArguments {
    NSString *inLatitude = [inArguments objectAtIndex:0];
    NSString *inLongitude = [inArguments objectAtIndex:1];
    if ([inArguments count]>2) {
        flage=[[inArguments objectAtIndex:2]intValue];
    }
    
    if (-90<[inLatitude intValue]<90||-180<[inLongitude intValue]<180) {
        if (![self isConnectionAvailable]){
            [self jsSuccessWithName:@"uexLocation.cbGetAddress" opId:1 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@"无网络连接,请检查你的网络"];
        }
        else{
            [myLocation getAddressWithLot:inLongitude Lat:inLatitude];
        }
    }else {
        [self jsFailedWithOpId:0 errorCode:1120201 errorDes:UEX_ERROR_DESCRIBE_ARGS];
    }
}
-(void)uexLocationWithLot:(double)inLog Lat:(double)inLat {
    NSString *jsStr = [NSString stringWithFormat:@"if(uexLocation.onChange!=null){uexLocation.onChange(%f,%f)}",inLat,inLog];
    [self.meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
}
//地址回调
-(void)uexLocationWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData{
    
    if (inData) {
        NSMutableArray *array=(NSMutableArray *)[inData componentsSeparatedByString:@";"];
        NSMutableDictionary *jsonDict=[NSMutableDictionary dictionary];
        NSArray *arrayKey=[NSArray arrayWithObjects:@"formatted_address",@"location",@"addressComponent",nil];
        
        for (int i=0;i<[array count] ; i++) {
            NSString *value=[NSString stringWithFormat:@"%@",[array objectAtIndex:i]];
            NSString *key=[NSString stringWithFormat:@"%@",[arrayKey objectAtIndex:i]];
            [jsonDict setValue:value forKey:key];
        }
        
        if (flage==1) {
            
            NSString *json=[jsonDict JSONFragment];
            [self jsSuccessWithName:@"uexLocation.cbGetAddress" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:json];
        }
        else {
            NSString *adr=[jsonDict objectForKey:@"formatted_address"];
            
            NSString *adrStr = [NSString stringWithFormat:@"uexLocation.cbGetAddress(\"%d\",\"%d\",\"%@\")",inOpId,inDataType,adr];
            [self.meBrwView stringByEvaluatingJavaScriptFromString:adrStr];
            
        }
    }
}

-(void)clean{
	if (myLocation) {
		[myLocation closeLocation];
		[myLocation release];
		myLocation = nil;
	}
}
-(BOOL) isConnectionAvailable{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    return [reach isReachable];
}

@end
