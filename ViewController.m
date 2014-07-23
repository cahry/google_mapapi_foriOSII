//
//  ViewController.m
//  google_mapapi_foriOSII
//
//  Created by spliang on 2014/7/18.
//  Copyright (c) 2014年 spliang. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#define R 6371.004        //R  常數
#define Pi 3.14159265359  //pi 常數
#define DEFAULT_UDP_TIMEOUT 10

@interface ViewController ()

@end

@implementation ViewController
@synthesize latTextField,lonTextField,car1_text,car2_text,car3_text,car4_text,IPtext,btnCheck;
@synthesize myIP;
double latitude2,longitude2;
bool is_connect;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [latTextField setEnabled:NO];
    [lonTextField setEnabled:NO];[latTextField setEnabled:NO];[lonTextField setEnabled:NO];
    [UIApplication sharedApplication].idleTimerDisabled=YES; //不自動鎖螢幕
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [IPtext setText:@"140.116.245.11"];
    //[IPtext setPlaceholder:@"192.168.1.101"];
    [btnCheck setEnabled:NO];
    [IPtext setEnabled:NO];
    __udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [__udpSocket setDelegate:self];
    is_connect=YES;

    // 宣告 location manager (取得經緯度）[begin]
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    // 宣告 location manager (取得經緯度）[end]
    
    my_latitude=locationManager.location.coordinate.latitude;
    my_longitude=locationManager.location.coordinate.longitude;
    latTextField.text=[NSString stringWithFormat:@"%f",my_latitude];
    lonTextField.text=[NSString stringWithFormat:@"%f",my_longitude];
    
     camera = [GMSCameraPosition cameraWithLatitude:my_latitude
                                                            longitude:my_longitude
                                                                 zoom:12];
    screenBounds = [UIScreen mainScreen].bounds;
    height = CGRectGetHeight(screenBounds);
    width = CGRectGetWidth(screenBounds);
    NSLog(@"height=%f,width=%f",height,width);
    
    
    myMapView= [GMSMapView mapWithFrame:CGRectMake(0, 50, width, height/2) camera:camera];
    myMapView.myLocationEnabled = YES;
    myMapView.delegate=self;
    [self.view addSubview:myMapView];
    //self.view = myMapView;
    
    // Creates a marker in the center of the map.
    
    
    /*
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(22.998750+0.0015, 120.219188+0.0020);
    marker2.title = @"國立成功大學";
    marker2.snippet = @"Taiwan";
    marker2.map = myMapView;
    */
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark google_map api
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"Did long press at coordinate");
    [IPtext resignFirstResponder];
}
-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
    [IPtext resignFirstResponder];
}
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
   // NSLog(@"Did change camera pos. & pos. is %@",position);
}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(id)marker
{
    NSLog(@"Did tap info win.");
    [IPtext resignFirstResponder];
}
#pragma mark -

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
   // NSLog(@"Location has been changed!,lat=%f,lon=%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    
    my_latitude=newLocation.coordinate.latitude;
    my_longitude=newLocation.coordinate.longitude;
    latTextField.text=[NSString stringWithFormat:@" %03.4f",my_latitude];
    lonTextField.text=[NSString stringWithFormat:@" %03.4f",my_longitude];
    if(is_connect){
        [self sendToUDPServer:[NSString stringWithFormat:@"%@,%@",latTextField.text,lonTextField.text] address:IPtext.text port:904];
    }
    NSLog(@"Update!");
    /*
    camera = [GMSCameraPosition cameraWithLatitude:my_latitude
                                         longitude:my_longitude
                                              zoom:15];
    
    [myMapView animateToCameraPosition:camera];*/
    
    // Creates a marker in the center of the map.

	// Handle location updates
    
    

}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// Handle error
}

#pragma mark AutoRotate
-(BOOL)shouldAutorotate{
    return NO;
}
#pragma mark -

#pragma mark udp socket
-(void)sendSearchBroadcast{
    NSString* bchost=@"255.255.255.255"; //廣播封包
    [self sendToUDPServer:@"hello udp" address:bchost port:1025];
}

-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port{
    
    NSLog(@"address:%@,port:%d,msg:%@",address,port,msg);
    //receiveWithTimeout is necessary or you won't receive anything
    [__udpSocket receiveWithTimeout:-1 tag:2]; //设置超时10秒發生callback(didNotSendDataWithTag function)
    [__udpSocket enableBroadcast:YES error:nil]; //如果你发送广播，这里必须先enableBroadcast
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [__udpSocket sendData:data toHost:address port:port withTimeout:10 tag:1]; //發送udp
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"data: %@",sock);
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [__udpSocket close];
    __udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [__udpSocket setDelegate:self];
    //當無法發送訊息的時候，返回異常訊息
    NSLog(@"Did not send data with tag");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示Q"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
    // You could add checks here
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    [__udpSocket close];
    __udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [__udpSocket setDelegate:self];
    
    //當無法接收訊息的時候，返回異常訊息
    NSLog(@"Did not receive data with tag");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示A"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];

}
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    [__udpSocket receiveWithTimeout:-1 tag:0];
    NSLog(@"host---->%@",host);
    
    //收到自己發的廣報訊息時不顯示出来
    NSMutableString *tempIP = [NSMutableString stringWithFormat:@"::ffff:%@",myIP];
    if ([host isEqualToString:self.myIP]||[host isEqualToString:tempIP])
    {
        //        return YES;
    }
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"msg=%@",msg);
    NSArray *msg1 = [msg componentsSeparatedByString: @";"];
    NSLog(@"RECV: %@~~~~%@!!!%@!!!%@!!!%@",msg,[msg1 objectAtIndex:0],[msg1 objectAtIndex:1],[msg1 objectAtIndex:2],[msg1 objectAtIndex:3]);
    NSArray *car1=[[msg1 objectAtIndex:0] componentsSeparatedByString:@","];
    NSArray *car2=[[msg1 objectAtIndex:1] componentsSeparatedByString:@","];
    NSArray *car3=[[msg1 objectAtIndex:2] componentsSeparatedByString:@","];
    NSArray *car4=[[msg1 objectAtIndex:3] componentsSeparatedByString:@","];
    
    latitude2=[[car1 objectAtIndex:0] doubleValue];
    longitude2=[[car1 objectAtIndex:1]doubleValue];
    
    /*
    const double DEGREES_TO_RADIANS = 0.0174532925;
    CLLocationDistance RR = 6371;	// mean radius of the earth in km
    CLLocationDegrees dLat = (latitude2 - my_latitude);
    CLLocationDegrees dLon = (longitude2 - my_longitude);
    double dLatRadians = dLat * DEGREES_TO_RADIANS;
    double dLonRadians = dLon * DEGREES_TO_RADIANS;
    double sinDLatRadiansOver2Squared = sin( dLatRadians / 2.0 ) * sin( dLatRadians / 2.0 );
    double cosLocation1InRadiansTimeCosLocation2InRadians =
    cos( my_latitude * DEGREES_TO_RADIANS ) * cos( latitude2 * DEGREES_TO_RADIANS );
    double sinDLonRadiansOver2Squared = (sin( dLonRadians / 2.0 ) * sin( dLonRadians / 2.0 ));
    double a = sinDLatRadiansOver2Squared + (cosLocation1InRadiansTimeCosLocation2InRadians * sinDLonRadiansOver2Squared);
    double c = 2.0 * atan2( sqrt( a ), sqrt( 1 - a ) );
    CLLocationDistance distance = R * c;*/
    
    double C=sinf(my_latitude)*sinf(latitude2)*cosf(my_longitude-longitude2)+cosf(my_latitude)*cosf(latitude2);
    double distance=R*acosf(C)*Pi/180;
    car1_text.text=[NSString stringWithFormat:@" %.3lf",distance];
    [myMapView clear];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(my_latitude, my_longitude);
    marker.title = @"車號777-HSNL";
    marker.snippet = @"目前位置";
    marker.map = myMapView;
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(latitude2, longitude2);
    marker2.title = @"車號222-HSIC";
    marker2.snippet =  [NSString stringWithFormat:@"距離：%.3lf公里",distance];
    marker2.map = myMapView;

    /**/
    latitude2=[[car2 objectAtIndex:0] doubleValue];
    longitude2=[[car2 objectAtIndex:1]doubleValue];
    /*
    dLat = (latitude2 - my_latitude);
    dLon = (longitude2 - my_longitude);
    dLatRadians = dLat * DEGREES_TO_RADIANS;
    dLonRadians = dLon * DEGREES_TO_RADIANS;
    sinDLatRadiansOver2Squared = sin( dLatRadians / 2.0 ) * sin( dLatRadians / 2.0 );
    cosLocation1InRadiansTimeCosLocation2InRadians =
    cos( my_latitude * DEGREES_TO_RADIANS ) * cos( latitude2 * DEGREES_TO_RADIANS );
    sinDLonRadiansOver2Squared = (sin( dLonRadians / 2.0 ) * sin( dLonRadians / 2.0 ));
    a = sinDLatRadiansOver2Squared + (cosLocation1InRadiansTimeCosLocation2InRadians * sinDLonRadiansOver2Squared);
    c = 2.0 * atan2( sqrt( a ), sqrt( 1 - a ) );
    distance = R * c;*/
    C=sinf(my_latitude)*sinf(latitude2)*cosf(my_longitude-longitude2)+cosf(my_latitude)*cosf(latitude2);
    distance=R*acosf(C)*Pi/180;
    car2_text.text=[NSString stringWithFormat:@" %.3lf",distance];
    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = CLLocationCoordinate2DMake(latitude2, longitude2);
    marker3.title = @"車號529-XUSC";
    marker3.snippet =  [NSString stringWithFormat:@"距離：%.3lf公里",distance];
    marker3.map = myMapView;
    
    latitude2=[[car3 objectAtIndex:0] doubleValue];
    longitude2=[[car3 objectAtIndex:1]doubleValue];
    /*
    dLat = (latitude2 - my_latitude);
    dLon = (longitude2 - my_longitude);
    dLatRadians = dLat * DEGREES_TO_RADIANS;
    dLonRadians = dLon * DEGREES_TO_RADIANS;
    sinDLatRadiansOver2Squared = sin( dLatRadians / 2.0 ) * sin( dLatRadians / 2.0 );
    cosLocation1InRadiansTimeCosLocation2InRadians =
    cos( my_latitude * DEGREES_TO_RADIANS ) * cos( latitude2 * DEGREES_TO_RADIANS );
    sinDLonRadiansOver2Squared = (sin( dLonRadians / 2.0 ) * sin( dLonRadians / 2.0 ));
    a = sinDLatRadiansOver2Squared + (cosLocation1InRadiansTimeCosLocation2InRadians * sinDLonRadiansOver2Squared);
    c = 2.0 * atan2( sqrt( a ), sqrt( 1 - a ) );
    distance = R * c; */
    C=sinf(my_latitude)*sinf(latitude2)*cosf(my_longitude-longitude2)+cosf(my_latitude)*cosf(latitude2);
    distance=R*acosf(C)*Pi/180;
    car3_text.text=[NSString stringWithFormat:@" %.3lf",distance];
    GMSMarker *marker4 = [[GMSMarker alloc] init];
    marker4.position = CLLocationCoordinate2DMake(latitude2, longitude2);
    marker4.title = @"車號398-SYCK";
    marker4.snippet =  [NSString stringWithFormat:@"距離：%.3lf公里",distance];
    marker4.map = myMapView;
    
    latitude2=[[car4 objectAtIndex:0] doubleValue];
    longitude2=[[car4 objectAtIndex:1]doubleValue];
    /*
    dLat = (latitude2 - my_latitude);
    dLon = (longitude2 - my_longitude);
    dLatRadians = dLat * DEGREES_TO_RADIANS;
    dLonRadians = dLon * DEGREES_TO_RADIANS;
    sinDLatRadiansOver2Squared = sin( dLatRadians / 2.0 ) * sin( dLatRadians / 2.0 );
    cosLocation1InRadiansTimeCosLocation2InRadians =
    cos( my_latitude * DEGREES_TO_RADIANS ) * cos( latitude2 * DEGREES_TO_RADIANS );
    sinDLonRadiansOver2Squared = (sin( dLonRadians / 2.0 ) * sin( dLonRadians / 2.0 ));
    a = sinDLatRadiansOver2Squared + (cosLocation1InRadiansTimeCosLocation2InRadians * sinDLonRadiansOver2Squared);
    c = 2.0 * atan2( sqrt( a ), sqrt( 1 - a ) );
    distance = R * c; */
    C=sinf(my_latitude)*sinf(latitude2)*cosf(my_longitude-longitude2)+cosf(my_latitude)*cosf(latitude2);
    distance=R*acosf(C)*Pi/180;
    car4_text.text=[NSString stringWithFormat:@" %.3lf",distance];
    GMSMarker *marker5 = [[GMSMarker alloc] init];
    marker5.position = CLLocationCoordinate2DMake(latitude2, longitude2);
    marker5.title = @"車號567-HUID";
    marker5.snippet = [NSString stringWithFormat:@"距離：%.3lf公里",distance];
    marker5.map = myMapView;
    
    
    
    
	//[udpSocket receiveWithTimeout:-1 tag:0];
    //[__udpSocket receiveWithTimeout:DEFAULT_UDP_TIMEOUT tag:1];
	return YES;//這行一定要有，否則就會到此結束

}
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"Socket has been closed!");
}
#pragma -



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [IPtext resignFirstResponder];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [IPtext resignFirstResponder];
}
- (IBAction)btnCheckIP:(id)sender {
    __udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    [__udpSocket setDelegate:self];
    is_connect=YES;
}
@end
