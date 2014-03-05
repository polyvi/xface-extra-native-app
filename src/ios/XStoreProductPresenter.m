
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
//  XStoreProductPresenter.m
//
//

#import <xFace/XAppInfo.h>
#import <xFace/XUtils.h>

#import "XStoreProductPresenter.h"

@implementation XStoreProductPresenter

static XStoreProductPresenter *sStoreProductPresenterInstance;

+ (void) initialize
{
    if (self == [XStoreProductPresenter class])
    {
        sStoreProductPresenterInstance = [[XStoreProductPresenter alloc] init];
    }
}

+ (XStoreProductPresenter *)getInstance
{
    NSAssert((nil != sStoreProductPresenterInstance), nil);
    return sStoreProductPresenterInstance;
}

- (BOOL)presentStoreProductWithAppInfo:(XAppInfo *)appInfo
{
    BOOL ret = YES;
    if (NSClassFromString(@"SKStoreProductViewController"))
    {
        NSString *appleId = [appInfo appleId];
        if ([appleId length] > 0)
        {
            //appleID非空时：在当前app内展示native app安装包下载界面
            SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
            storeController.delegate = self;

            NSDictionary *productParameters = @{SKStoreProductParameterITunesItemIdentifier: appleId};
            [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
                if (!result)
                {
                    ALog(@"Faled to load store product with error:%@", [error localizedDescription]);
                }
            }];

            UIViewController *topVC = [XUtils topViewController];
            NSAssert(topVC, @"Top view controller view controller should not be nil!");
            [topVC presentViewController:storeController animated:NO completion:nil];
            return ret;
        }
    }

    //appleID为空时：跳转到App Store或其他应用展示native app安装包下载界面
    NSString *remotePkg = [appInfo prefRemotePkg];
    NSAssert(([remotePkg length] > 0), @"Remote package value should not be empty for native app!");

    NSURL *url = [NSURL URLWithString:remotePkg];
    ret = [[UIApplication sharedApplication] openURL:url];

    return ret;
}

#pragma SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end

