
#import "InitialViewController.h"
#import "DBHelper.h"
#import "TagItInfo.h"
#define CELL_IDENTIFIER @"cell"

@interface InitialViewController (){
    
    __weak IBOutlet UISearchBar *searchBar;
    
    __weak IBOutlet UITableView *tableViewTitleTagDisplay;
    NSString *CellIdentifier;
    NSMutableArray *arrayResultsForTitle;
    NSMutableArray *arrayResultsForTag;
    NSMutableArray *arrayOfFinalUids;
    NSArray *arrayFinalObjectsToDisplay;
    NSArray *arrayTempObjectsRetreivedFromDatabase;
    NSArray *commomItemsInTagTitle;
    NSString *keyWordToSearch;
    DBHelper *dbHelperObject;
    TagItInfo *tagItInfoModel;
    int uid;
    NSString *tempCellImageName;
}

@end

@implementation InitialViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    searchBar.delegate = self;
    CellIdentifier = CELL_IDENTIFIER;
    // tableViewTitleTagDisplay.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark:searchBar Delegate methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    tableViewTitleTagDisplay.hidden = NO;
    keyWordToSearch = searchBar.text;
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:
    //                              @"SELF contains[cd] %@", searchBar.text];
    
    [self getSearchResultsFromDatabase];
    
    //    if(arrayFinalObjectsToDisplay.count==0){
    //        [self displayAlertForNoResultsFound];
    //    }
    
    
    [tableViewTitleTagDisplay reloadData];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if(arrayFinalObjectsToDisplay.count==0){
        [self displayAlertForNoResultsFound];
    }
    else{
        [self resignFirstResponder];
    }
    
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // tableViewTitleTagDisplay.hidden= NO;
    // [self displayAlertForNoResultsFound];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //    [self getSearchResultsFromDatabase];
    //
    //    if(arrayFinalObjectsToDisplay.count==0){
    //        [self displayAlertForNoResultsFound];
    //    }
    //
    //    else{
    //        tableViewTitleTagDisplay.hidden = NO;
    //        [tableViewTitleTagDisplay reloadData];
    //    }
}


#pragma  mark :-tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return arrayFinalObjectsToDisplay.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CustomisedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"CustomisedTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        uid = (int)[[[arrayFinalObjectsToDisplay objectAtIndex:indexPath.row] valueForKey:@"uid"] integerValue];
        //adding tag to cell
        [cell.labelTag setTag:1];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.labelTitle.text = [[arrayFinalObjectsToDisplay objectAtIndex:indexPath.row]valueForKey:@"title"];
    
    cell.labelTag.text = [[arrayFinalObjectsToDisplay objectAtIndex:indexPath.row]valueForKey:@"tag"];
    
    tempCellImageName = [[arrayFinalObjectsToDisplay objectAtIndex:indexPath.row]valueForKey:@"image"];
    cell.imageViewCustomisedCell.image =[self fetchImagesFromDbWithFileName:tempCellImageName];
    //for adding bottom border
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height, self.view.bounds.size.width, 2)];
    bottomLineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:bottomLineView];
    
    return cell;
    
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *uid;
    uid = [[arrayFinalObjectsToDisplay objectAtIndex:indexPath.row]valueForKey:@"uid"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewDetailsController *viewDetailsControllerObject = [storyboard instantiateViewControllerWithIdentifier:@"ViewDetailsController"];
    viewDetailsControllerObject.uidForDb = uid;
    [self.navigationController pushViewController:viewDetailsControllerObject animated:true];
    
}


#pragma mark:-alertview delegate methods

-(void)displayAlertForNoResultsFound{
    
    UIAlertController *alertForNoResults = [UIAlertController alertControllerWithTitle:@"Invalid!" message:@"No matching results found!" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction * defaultOkOption = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
    
    [alertForNoResults  addAction:defaultOkOption];
    
    [self presentViewController:alertForNoResults animated:YES completion:nil];
}


#pragma mark:-add button action handler
- (IBAction)buttonAddActionHandler:(UIBarButtonItem *)sender {
    tableViewTitleTagDisplay.hidden = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddEditViewController *addEditViewControllerObject = [storyboard instantiateViewControllerWithIdentifier:@"AddEditViewController"];
    [self.navigationController pushViewController:addEditViewControllerObject animated:true];
    
}


#pragma mark:- code data context
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark:- database operations
-(void)getSearchResultsFromDatabase{
    
    NSString *tempUidValue;
    NSString *tempString;
    NSMutableArray *tempArrayForSubtraction;
    NSMutableArray *tempArrayForFinalObjects;
    int lenghtOfArrayReturned;
    arrayResultsForTitle =[[NSMutableArray alloc]init];
    arrayResultsForTag = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    dbHelperObject = [[DBHelper alloc]init];
    dbHelperObject.dbName = @"TagItInfo";
    dbHelperObject.context = context;
    
    NSPredicate *predicateForTitle = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)",keyWordToSearch];
    NSPredicate *predicateForTag = [NSPredicate predicateWithFormat:@"tag CONTAINS[cd] %@",keyWordToSearch];
    
    arrayTempObjectsRetreivedFromDatabase = [dbHelperObject fetchWithPredicate:predicateForTitle];
    //    NSLog(@" value from titile %@",[[arrayTempObjectsRetreivedFromDatabase objectAtIndex:0]valueForKey:@"title"]);
    //     NSLog(@" value from uid %@",[[arrayTempObjectsRetreivedFromDatabase objectAtIndex:0]valueForKey:@"uid"]);
    //lenghtOfArrayReturned = (int)arrayTempObjectsRetreivedFromDatabase.count;
    NSLog(@" lenght of returned objects %d",lenghtOfArrayReturned);
    
    //add only id values to nsmutuable array
    for(int i=0;i<arrayTempObjectsRetreivedFromDatabase.count;i++){
        tempUidValue = [[arrayTempObjectsRetreivedFromDatabase objectAtIndex:i]valueForKey:@"uid"];
        [arrayResultsForTitle addObject:tempUidValue];
    }
    
    arrayTempObjectsRetreivedFromDatabase = [dbHelperObject fetchWithPredicate:predicateForTag];
    
    //add only id values to nsmutuable array
    for(int i=0;i<arrayTempObjectsRetreivedFromDatabase.count;i++){
        tempUidValue = [[arrayTempObjectsRetreivedFromDatabase objectAtIndex:i]valueForKey:@"uid"];
        [arrayResultsForTag addObject:tempUidValue];
    }
    
    
    NSLog(@"title : %@",arrayResultsForTitle);
    NSLog(@"tag : %@",arrayResultsForTag);
    
    //perform intersection
    
    NSMutableSet *set1 = [NSMutableSet setWithArray: arrayResultsForTitle];
    NSSet *set2 = [NSSet setWithArray: arrayResultsForTag];
    [set1 intersectSet: set2];
    commomItemsInTagTitle = [set1 allObjects];
    NSLog(@"intersection %@",commomItemsInTagTitle);
    
    //add allvalues from arraytitle to finaluids
    arrayOfFinalUids = [[NSMutableArray alloc]initWithArray:arrayResultsForTitle];
    // add only values not present in tag array to final array
    tempArrayForSubtraction = [NSMutableArray arrayWithArray:arrayResultsForTag];
    [tempArrayForSubtraction removeObjectsInArray:commomItemsInTagTitle];
    NSLog(@"%@",tempArrayForSubtraction);
    if(tempArrayForSubtraction.count>0){
        //append
        [arrayOfFinalUids addObjectsFromArray:tempArrayForSubtraction];
    }
    
    
    NSLog(@"%@",arrayOfFinalUids);
    
    
    
    //fetch all objects
    
    NSArray *fetchallobjects = [dbHelperObject fetchAll];
    
    for(int i=0;i<fetchallobjects.count;i++){
        NSLog(@"%@",[[fetchallobjects objectAtIndex:i]valueForKey:@"uid"]);
        NSLog(@"%@",[[fetchallobjects objectAtIndex:i]valueForKey:@"title"]);
    }
    //
    //    NSLog(@" count of fetched objects %lu",(unsigned long)fetchallobjects.count);
    ////    NSLog(@"%@",smething);
    ////    NSLog(@"%@",smething1);
    
    //from fetch all objects add only those whose ids match in finaluids
    tempArrayForFinalObjects = [[NSMutableArray alloc]init];
    
    for(int i=0;i<arrayOfFinalUids.count;i++){
        tempUidValue = [arrayOfFinalUids objectAtIndex:i];
        for(int j=0;j<fetchallobjects.count;j++){
            tempString = [[fetchallobjects objectAtIndex:j]valueForKey:@"uid"];
            if([tempUidValue isEqualToString:tempString]){
                [tempArrayForFinalObjects addObject:[fetchallobjects objectAtIndex:j]];
                break;
            }
        }
    }
    
    //add objects to fianl array
    arrayFinalObjectsToDisplay = [NSArray arrayWithArray:tempArrayForFinalObjects];
    
    
}

#pragma mark:- fetch images
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
