

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@interface MapDisplayViewController : UIViewController<GMSMapViewDelegate,NSURLConnectionDelegate>{
    
   
}
@property NSString *userCurrentLatitude;
@property NSString *userCurrentLongitude;
@property NSString *destinationLatitude;
@property NSString *destinationLongitude;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end
