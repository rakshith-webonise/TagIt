
#import "MapDisplayViewController.h"

@interface MapDisplayViewController (){
    NSMutableData *responseData;
}

@end

@implementation MapDisplayViewController
@synthesize userCurrentLatitude;
@synthesize userCurrentLongitude;
@synthesize destinationLatitude;
@synthesize destinationLongitude;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initalizeMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

-(void)initalizeMap{
    float destLatitude;
    float destLongitude;
    float userLat;
    float userLong;
    NSString *source=@"origin=";
    NSString *destination=@"destination=";
    NSString *mainurl;
    NSString *trailingurl = @"&sensor=false";
    
    userLat = [userCurrentLatitude floatValue];
     userLong = [userCurrentLongitude floatValue];
    
    CLLocationCoordinate2D positionForCurrentLocation = CLLocationCoordinate2DMake(userLat, userLong);
    GMSMarker *markerForCurrentLocation = [GMSMarker markerWithPosition:positionForCurrentLocation];
    //self.view = self.mapViewForMap;
    
    markerForCurrentLocation.map = self.mapView;
    markerForCurrentLocation.title = @"You are here";
    markerForCurrentLocation.infoWindowAnchor = CGPointMake(1.0, 0.5);
    
    
    destLatitude = [destinationLatitude floatValue];
    destLongitude = [ destinationLongitude floatValue];
    CLLocationCoordinate2D destinationcoord = CLLocationCoordinate2DMake(destLatitude, destLongitude);
    GMSMarker *destinationMarker = [GMSMarker markerWithPosition:destinationcoord];

    destinationMarker.map = self.mapView;
    destinationMarker.title = @"Destination";
    destinationMarker.infoWindowAnchor = CGPointMake(1.0, 0.5);

    
    
   // marker.icon = [UIImage imageNamed:@"house"];//icon over marker
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:userLat
                                                            longitude:userLong
                                                                 zoom:8];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled  = YES;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.delegate = self;
    
    // set the source and destination
    mainurl = @"https://maps.google.com/maps/api/directions/json?";
    source = [source stringByAppendingString:userCurrentLatitude];
    source = [source stringByAppendingString:@","];
    source = [source stringByAppendingString:userCurrentLongitude];
    source = [source stringByAppendingString:@"&"];
    mainurl = [mainurl stringByAppendingString:source];
    destination = [destination stringByAppendingString:destinationLatitude];
    destination = [destination stringByAppendingString:@","];
    destination = [destination stringByAppendingString:destinationLongitude];
    mainurl = [mainurl stringByAppendingString:destination];
    mainurl = [mainurl stringByAppendingString:trailingurl];
    
//    NSString *urlString = [NSString stringWithFormat:@"https://maps.google.com/maps/api/directions/json?origin=18.5204303,73.8567437&destination=12.9715987,77.5945627&sensor=false"];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mainurl]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];


}

- (IBAction)buttonBackActionHandler:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
}
-(void)drawPolylinewithsteps{
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    // NSLog(@"%@",json);
    NSArray *routes = json[@"routes"];
    NSArray *legs = routes[0][@"legs"];
    NSArray *steps = legs[0][@"steps"];
    NSLog(@" length of steps %lu", (unsigned long)steps.count);
    NSMutableArray *polyStrings = [[NSMutableArray alloc]init];
    
    for (NSDictionary *stepdic in steps) {
        // NSLog(@"%@",stepdic);
        NSString *polyStr = [[stepdic objectForKey:@"polyline"] valueForKey:@"points"];
        NSLog(@"%@",polyStr);
        [polyStrings addObject:polyStr];
    }
    // Create a single path from the polystrings for a smooth line and create the final polyline
    NSLog(@" length of polystrings %lu",(unsigned long)polyStrings.count);
    GMSMutablePath *path = [GMSMutablePath path];
    for (NSString *polyStr in polyStrings) {
        GMSPath *p = [GMSPath pathFromEncodedPath:polyStr];
        for (NSUInteger i=0; i < p.count; i++) {
            [path addCoordinate:[p coordinateAtIndex:i]];
        }
    }
    
    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = 7;
    polyLine.strokeColor = [UIColor greenColor];
    polyLine.map = self.mapView;
    
    
    
}



#pragma mark:-nsurl coonection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSLog(@" data lenght : %lu",(unsigned long)responseData.length);
    [self drawPolylinewithsteps];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"failed due to error");
}


@end
