

#import "AddEditViewController.h"

@interface AddEditViewController (){
    UIBarButtonItem *barButtonSave,*barButtonCancel;
    UIImagePickerController *uiImagePicker;
    UIImage *imageForButtonClickToAdd;
    
    __weak IBOutlet UIButton *buttonClickToAddImage;
    
    __weak IBOutlet UISwitch *switchGeoLocation;
     CLLocationManager *coreLocationManager;
    BOOL userLocationObtained;
    BOOL galleryselected;
    __weak IBOutlet UITextField *textFieldTitle;
    
    __weak IBOutlet UITextField *textFieldTag;
     NSDictionary *TagitInfoDictionaryForInsert;
    DBHelper *dbHelperObject;
    NSString *imageForDb,*titleForDb,*tagForDb,*uidoldForDb,*uidnewForDb,*latitudeForDb,*longitudeForDb;
    NSArray *arrayDataObtainedFromDb;
}

@end

@implementation AddEditViewController
@synthesize olduid;
@synthesize calledFromEdit;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialiseCancelBarButton];
    [self initialiseSaveBarRightButton];
    //set default values for latitude and longitude
    latitudeForDb = @"";
    longitudeForDb = @"";
    if(calledFromEdit){
        [self initialiseViewControllerForEdit];
    }
    
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   }

#pragma mark:-adding save bar button
-(void)initialiseSaveBarRightButton{
    barButtonSave = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonSaveActionHandler)];
    self.navigationItem.rightBarButtonItem = barButtonSave;
}

#pragma mark:-adding cancel button
-(void)initialiseCancelBarButton{
   

    barButtonCancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonCancelActionHandler)];
    self.navigationItem.leftBarButtonItem = barButtonCancel;
}

#pragma mark:-barbutton save action handler

-(void)barButtonSaveActionHandler{
    // logic to handle if switch for geo location is enabled
    //check of called from edit
    if(calledFromEdit){
       // delete prev entry and add new entry
        [self deleteFromDbForUid:olduid];
    }
    
    if(switchGeoLocation.on){
        [self getUserCurrentLocation];
    }
   
    //set all values
   
    [self insertIntoDatabase];
    
    [self.navigationController popViewControllerAnimated:true];
}

#pragma  mark:- barbutton cancel action handler
-(void)barButtonCancelActionHandler{
    
    [self.navigationController popToRootViewControllerAnimated:true];
}


#pragma mark:- alert controller button image clicked
- (IBAction)buttonImageDisplayerActionHandler:(UIButton *)sender {
    
    //display alert view controller to select from camera or gallery
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Input alert!!"
                                                                   message:@"Select image from "
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {[self openCameraForImage];}];
    
    UIAlertAction * optional = [UIAlertAction actionWithTitle:@"Photo Gallery" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {[self openGalleryForImage];}];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [alert addAction:optional];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark:- camera open handler
-(void)openCameraForImage{
    
    uiImagePicker = [[UIImagePickerController alloc]init];
    uiImagePicker.delegate = self;
    uiImagePicker.allowsEditing = YES;
    uiImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:uiImagePicker animated:YES completion:NULL];
}


#pragma mark:- gallery open handler
-(void)openGalleryForImage{
    //display uiimagepicker
    galleryselected = TRUE;
    uiImagePicker = [[UIImagePickerController alloc]init];
    uiImagePicker.delegate = self;
    uiImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:uiImagePicker animated:YES completion:nil];
}

#pragma mark:-uiimagepicker delegate methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if(galleryselected){
        imageForButtonClickToAdd = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //set title to null and image for button
        [buttonClickToAddImage setTitle:@"" forState:UIControlStateNormal ];
        [buttonClickToAddImage setImage:imageForButtonClickToAdd forState:UIControlStateNormal];
        [self dismissViewControllerAnimated:true completion:nil];
    }
    //if camera is selected
    else{
        
        imageForButtonClickToAdd = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [buttonClickToAddImage setTitle:@"" forState:UIControlStateNormal];
        [buttonClickToAddImage setImage:imageForButtonClickToAdd forState:UIControlStateNormal];
        [self dismissViewControllerAnimated:true completion:nil];
    }
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


#pragma  mark:- core data context
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


#pragma mark:- database operations


-(void)deleteFromDbForUid:(NSString *)uid{
    dbHelperObject = [[DBHelper alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    dbHelperObject.context = context;
    dbHelperObject.dbName = @"TagItInfo";
    NSPredicate *predicateForDelete = [NSPredicate predicateWithFormat:@"(uid=%@)",uid];
    [dbHelperObject deleteWithPredicate:predicateForDelete];
    
}
-(void)insertIntoDatabase{
    NSString *tempString;
    int tempIntUidValue;
    dbHelperObject = [[DBHelper alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    dbHelperObject.context = context;
    dbHelperObject.dbName = @"TagItInfo";

    
    //fetch all values
    arrayDataObtainedFromDb = [dbHelperObject fetchAll];
    tempString = [[arrayDataObtainedFromDb lastObject]valueForKey:@"uid"];
    tempIntUidValue = (int)[tempString integerValue];
    tempIntUidValue += tempIntUidValue;
    //initialise all values for insert
    titleForDb = textFieldTitle.text;
    tagForDb = textFieldTag.text;
    uidnewForDb = [NSString stringWithFormat:@"%d",tempIntUidValue];
    
    //save image into backend b4 inserting
    NSString *imageName = textFieldTitle.text;
    imageName = [imageName stringByAppendingString:textFieldTag.text];
    //before appending png get the name of image
    imageForDb = imageName;
    
    imageName = [imageName stringByAppendingString:@".png"];
    
    [self saveImageToPhoneWithImageName:imageName];
    
    [self makeDictionaryFromModel];
    
    [dbHelperObject insertIntoTable:TagitInfoDictionaryForInsert];
    
    NSLog(@"done inserting");
}

-(void) makeDictionaryFromModel{
    
    TagitInfoDictionaryForInsert = [NSDictionary dictionaryWithObjects:@[titleForDb,tagForDb,uidnewForDb,imageForDb,latitudeForDb,longitudeForDb] forKeys:@[@"title",@"tag",@"uid",@"image",@"latitude",@"longitude"]];
    NSLog(@"make dictionary %@",TagitInfoDictionaryForInsert);
   
}

#pragma mark :- saving image to phone

-(void)saveImageToPhoneWithImageName:(NSString*)imageName{
    
    NSData *imageBuffer = UIImagePNGRepresentation([buttonClickToAddImage imageForState:UIControlStateNormal]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = [paths objectAtIndex:0];
    
    NSString *filepath = [documentpath stringByAppendingPathComponent:imageName];
    NSLog(@"%@",filepath);
   
    [imageBuffer writeToFile:filepath atomically:YES];

}

#pragma  mark:-corelocation delegate methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error.debugDescription);
    userLocationObtained = false;
    //set switch off and show alert
    [switchGeoLocation setOn:NO animated:true];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"location %@",newLocation);
    CLLocation *currentlocation = newLocation;
    if(currentlocation != nil){
        NSLog(@"%.8f",currentlocation.coordinate.latitude);
        NSLog(@"%.8f",currentlocation.coordinate.longitude);
    }
    userLocationObtained = true;
    //setting latitude and longitude values
    latitudeForDb = [NSString stringWithFormat:@"%.8f",currentlocation.coordinate.latitude];
    longitudeForDb = [NSString stringWithFormat:@"%.8f",currentlocation.coordinate.longitude];
    [coreLocationManager stopUpdatingLocation];
}


#pragma  mark:-intialize screen for edit
-(void)initialiseViewControllerForEdit{
    NSString *tempString;
    NSManagedObjectContext *context = [self managedObjectContext];
    dbHelperObject = [[DBHelper alloc]init];
    dbHelperObject.dbName = @"TagItInfo";
    dbHelperObject.context = context;
    NSPredicate *predicateForUid = [NSPredicate predicateWithFormat:@"(uid=%@)",olduid];
    arrayDataObtainedFromDb = [dbHelperObject fetchWithPredicate:predicateForUid];
    //initialise values
    tempString = [[arrayDataObtainedFromDb objectAtIndex:0]valueForKey:@"title"];
    textFieldTitle.text =tempString;
    tempString = [[arrayDataObtainedFromDb objectAtIndex:0]valueForKey:@"tag"];
    textFieldTag.text = tempString;
    tempString = [[arrayDataObtainedFromDb objectAtIndex:0]valueForKey:@"image"];
    imageForButtonClickToAdd = [self fetchImagesFromDbWithFileName:tempString];
    //set image to button
    [buttonClickToAddImage setTitle:@"" forState:UIControlStateNormal];
    [buttonClickToAddImage setImage:imageForButtonClickToAdd forState:UIControlStateNormal];

    
}

#pragma  mark:- fetchimage from phone
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





@end
