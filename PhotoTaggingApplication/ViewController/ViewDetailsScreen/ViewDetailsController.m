

#import "ViewDetailsController.h"
#import "DBHelper.h"

@interface ViewDetailsController (){
    UIBarButtonItem *barButtonEdit;
    UIBarButtonItem *barButtonCancel;
    NSArray *dataToDisplayFromDatabase;
    DBHelper *dbHelperObject;
    
    __weak IBOutlet UIImageView *imageViewDisplay;
    __weak IBOutlet UILabel *labelTag;
    
    __weak IBOutlet UIButton *buttonShowOnMap;
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
    labelTag.text = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"tag"];
    imageNameTemp = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"image"];
    imageViewDisplay.image = [self fetchImagesFromDbWithFileName:imageNameTemp];
    titleNameTemp = [[dataToDisplayFromDatabase objectAtIndex:0]valueForKey:@"title"];
    self.navigationItem.title = @"Title";
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



@end
