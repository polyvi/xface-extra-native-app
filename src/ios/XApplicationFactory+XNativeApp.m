
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
//  XApplicationFactory.m
//
//

#import <xFace/XApplicationFactory.h>
#import <xFace/XAppInfo.h>
#import <xFace/XWebApplication.h>
#import <xFace/XConstants.h>

#import "XNativeApplication.h"

@implementation XApplicationFactory (XNativeApp)

+ (id<XApplication>)create:(XAppInfo *)appInfo
{
    id<XApplication> app = nil;
    if ( [[appInfo type] isEqualToString:APP_TYPE_NAPP] )
    {
        app = [[XNativeApplication alloc] initWithAppInfo:appInfo];
    }
    else
    {
        // FIXME:考虑到之前app.xml并没有定义"xapp",故此处没有验证app类型
        app = [[XWebApplication alloc] initWithAppInfo:appInfo];
    }
    return app;
}

@end
