//
//  ViewController.h
//  google_mapapi_foriOSII
//
//  Created by spliang on 2014/7/18.
//  Copyright (c) 2014年 spliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "AsyncUdpSocket.h"
@interface ViewController : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate,AsyncUdpSocketDelegate>
{
    GMSMapView *myMapView;
    CLLocationManager *locationManager;
    GMSCameraPosition *camera;
    float my_latitude,my_longitude;
    CGRect screenBounds;
    CGFloat height,width;
    AsyncUdpSocket * __udpSocket;
}
- (IBAction)btnCheckIP:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *IPtext;
@property (weak, nonatomic) IBOutlet UITextField *latTextField;
@property (weak, nonatomic) IBOutlet UITextField *lonTextField;
@property (nonatomic, retain) NSString *myIP;
@property (weak, nonatomic) IBOutlet UITextField *car1_text;
@property (weak, nonatomic) IBOutlet UITextField *car2_text;
@property (weak, nonatomic) IBOutlet UITextField *car3_text;
@property (weak, nonatomic) IBOutlet UITextField *car4_text;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@end
