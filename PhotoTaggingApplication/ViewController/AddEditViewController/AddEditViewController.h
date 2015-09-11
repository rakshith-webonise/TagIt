

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DBHelper.h"
@interface AddEditViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>{
    
}
@property NSString *olduid;
@property BOOL calledFromEdit;
@end
