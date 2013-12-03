
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XNativeApplication.m
//
//

#import <xFace/XAppInfo.h>
#import <xFace/XConstants.h>
#import <xFace/XUtils.h>

#import "XNativeApplication_Privates.h"
#import "XNativeApplication.h"
#import "XStoreProductPresenter.h"

@implementation XNativeApplication

@synthesize appInfo;

- (id) initWithAppInfo:(XAppInfo *)applicationInfo
{
    self = [super init];
    if (self)
    {
        self.appInfo = applicationInfo;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xAppDidFinishInstall:)
                                                     name:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:self];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *) getAppId
{
    NSAssert((nil != [self appInfo]), nil);
    return [[self appInfo] appId];
}

- (BOOL) isInstalled
{
    NSString *urlStr = [[self appInfo] entry];
    NSURL *url = [NSURL URLWithString:[self validateEntry:urlStr]];
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:url];
    return isInstalled;
}

- (BOOL) isNative
{
    return YES;
}

- (BOOL) loadWithParameters:(NSString *)params
{
    NSURL *url = nil;
    BOOL ret = [self isInstalled];
    if (ret)
    {
        //已安装时，通过custom URL启动native app
        //如果启动参数非空，则将custom URL scheme与启动参数进行组装后传递给native app
        NSString *urlStr = [self validateEntry:[[self appInfo] entry]];
        if ([params length])
        {
            urlStr = [urlStr stringByAppendingString:params];
        }

        url = [NSURL URLWithString:urlStr];
        ret = [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        //未安装时，展示native app安装界面
        ret = [[XStoreProductPresenter getInstance] presentStoreProductWithAppInfo:[self appInfo]];
    }

    return ret;
}

- (NSString*) getIconURL
{
    NSString* relativeIconPath = [appInfo icon];
    if (0 == [relativeIconPath length])
    {
        return nil;
    }

    NSString* appId = appInfo.appId;
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:appId relativeIconPath:relativeIconPath];

    NSString *iconURL = (nil == iconPath) ? nil : [[NSURL fileURLWithPath:iconPath] absoluteString];
    return iconURL;
}

#pragma mark app event

- (void) xAppDidFinishInstall:(NSNotification*)notification
{
    NSAssert(self == [notification object], nil);

    if (![self isInstalled])
    {
        NSAssert([self isNative], nil);
        [[XStoreProductPresenter getInstance] presentStoreProductWithAppInfo:[self appInfo]];
    }
    return;
}

#pragma mark Privates

-(NSString *)validateEntry:(NSString *)entry
{
    NSString *validatedEntry = entry;
    NSRange range = [validatedEntry rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];

    if(NSNotFound == range.location)
    {
        validatedEntry = [validatedEntry stringByAppendingString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
    }
    return validatedEntry;
}

@end
