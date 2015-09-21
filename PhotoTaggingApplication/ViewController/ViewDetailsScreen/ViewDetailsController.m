

#import "ViewDetailsController.h"
#import "DBHelper.h"
#import "AddEditViewController.h"
#import "MapDisplayViewController.h"

@interface ViewDetailsController (){
    UIBarButtonItem *barButtonEdit;
    UIBarButtonItem *barButtonCancel;
    NSArray *dataToDisplayFromDatabase;
    DBHelper *dbHelperObject;
    CLLocationManager *coreLocationManager;
    
    __weak IBOutlet UIImageView *imageViewDisplay;
    __weak IBOutlet UILabel *labelTag;
    
    __weak IBOutlet UIButton *buttonShowOnMap;
    NSString *userCurrentLatitude;
    NSString *userCurrentLongitude;
    
    __weak IBOutlet UIButton *buttonDelete;
    
}

@end

@implementation ViewDetailsController
@synthesize uidForDb;
- (void)viewDidLoad {
    [super viewDidLoad];
    //set dis value dynamically
    [self makeUiBarButtonEdit];
    [self makeUiBarButtonCancel];
    NSLog(@"%@",uidForDb);
    [self fetchFromDb];
    [self displayDataOnController];
    buttonDelete.layer.cornerRadius = 5;
    buttonShowOnMap.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark:- uibarbutton initialise
-(void) makeUiBarButtonEdit{
    barButtonEdit = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(buttonEditActionHandler)];
    self.navigationItem.rightBarButtonItem = barButtonEdit;
    
}

#pragma  mark:-uibarbutton cancel initialize
-(void)makeUiBarButtonCancel{
    barButtonCancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(buttonCancelActionHandler)];
    self.navigationItem.leftBarButtonItem = barButtonCancel;
}

#pragma mark:-edit button action handler
-(void)buttonEditActionHandler{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddEditViewController *addEditViewControllerObject = [storyboard instantiateViewControllerWithIdentifier:@"AddEditViewController"];
    addEditViewControllerObject.olduid = uidForDb;
    addEditViewControllerObject.calledFromEdit = true;
    [self.navigationController pushViewController:addEditViewControllerObject animated:true];
    
}

#pragma mark:-buttonCancelActionHandler
-(void)buttonCancelActionHandler{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma database 
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)fetchFromDb{
    NSManagedObjectContext *context = [self managedObjectContext];
    dbHelperObject = [[DBHelper alloc]init];
    dbHelperObject.dbName = @"TagItInfo";
    dbHelperObject.context = context;
    NSPredicate *predicateForUid = [NSPredicate predicateWithFormat:@"(uid=%@)",uidForDb];
    dataToDisplayFromDatabase = [dbHelperObject fetchWithPredicate:predicateForUid];
    NSLog(@"%@",[[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"title"]);
    
  }

#pragma  mark:- display on controller

-(void)displayDataOnController{
    NSString *imageNameTemp;
    NSString *titleNameTemp;
    NSString *latitideValueTemp;
    
    labelTag.text = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"tag"];
    imageNameTemp = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"image"];
    imageViewDisplay.image = [self fetchImagesFromDbWithFileName:imageNameTemp];
    titleNameTemp = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"title"];
    self.navigationItem.title = titleNameTemp;
    //enable or disable the show on map button
    latitideValueTemp = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"latitude"];
    if([latitideValueTemp isEqualToString:@""]){
        [buttonShowOnMap setEnabled:false];
        [buttonShowOnMap setAlpha:0.4];
    }
}

#pragma mark:-fetch images
-(UIImage *)fetchImagesFromDbWithFileName : (NSString *)filename{
    UIImage *image;
    filename = [filename stringByAppendingString:@".png"];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = [path objectAtIndex:0];
    NSString *fileToRetreivePath = [documentpath stringByAppendingPathComponent:filename];
    NSLog(@"%@",fileToRetreivePath);
    NSData *imageData = [NSData dataWithContentsOfFile:fileToRetreivePath];
    image = [UIImage imageWithData:imageData];
    return image;
}


#pragma mark:- core location
-(void)getUserCurrentLocation{
    //initialise location manager
    
    coreLocationManager = [[CLLocationManager alloc]init];
    coreLocationManager.delegate = self;
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [coreLocationManager requestWhenInUseAuthorization];
    //[self->manager requestAlwaysAuthorization];
    
    [coreLocationManager startUpdatingLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error.debugDescription);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"location %@",newLocation);
    CLLocation *currentlocation = newLocation;
    if(currentlocation != nil){
        NSLog(@"%.8f",currentlocation.coordinate.latitude);
        NSLog(@"%.8f",currentlocation.coordinate.longitude);
    }
    
    userCurrentLatitude = [NSString stringWithFormat:@"%.8f",currentlocation.coordinate.latitude];
    userCurrentLongitude = [NSString stringWithFormat:@"%.8f",currentlocation.coordinate.longitude];

     [coreLocationManager stopUpdatingLocation];
    
}

#pragma  mark:- show on map button action handler
- (IBAction)buttonShowOnMao:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapDisplayViewController *mapObject = [storyboard instantiateViewControllerWithIdentifier:@"MapDisplayViewController"];
    mapObject.destinationLatitude = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"latitude"];
    mapObject.destinationLongitude = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"longitude"];
    //get user current location
    [self getUserCurrentLocation];
    mapObject.userCurrentLatitude = userCurrentLatitude;
    mapObject.userCurrentLongitude = userCurrentLongitude;
    
    
    [self.navigationController pushViewController:mapObject animated:true];

}








@end
