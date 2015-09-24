

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DBHelper : NSObject {
    NSManagedObjectContext *context;
    NSFetchedResultsController *mfetchedResultsController;
    NSString *dbName;
    NSArray *dbColumns;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    BOOL inTransaction;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSArray *dbColumns;
@property (nonatomic, retain)  NSString *dbName;
@property (nonatomic, retain)  NSPersistentStoreCoordinator *persistentStoreCoordinator;


-(void)insertIntoTable:(NSDictionary*)dictionary;
- (NSFetchedResultsController *)fetchedResultsController;
-(void)deleteFromTable:(NSManagedObject*)mObject;
-(void)updateWithPredicate:(NSPredicate *) predicate withUpdatedKey:(NSDictionary *)updateKeyValue;
-(void)updateTableForKey:(NSString *)key withValue:(NSString *)value withUpdatedKey:(NSDictionary *)updateKeyValue;
-(NSArray *)fetch:(NSString *)strValue withKey:(NSString *)strKey;
-(NSArray *)fetchAll;
-(void)deleteAll;
-(NSArray*)fetchWithPredicate:(NSPredicate*)predicate;
-(void)updateFromTable:(NSManagedObject*)mObject withKey:(NSString *)key withValue:(NSString *)value;
-(BOOL)save;
-(void)startTransaction;
-(void)endTransaction;
-(void)updateIntValueFromTable:(NSManagedObject*)mObject withKey:(NSString *)key withValue:(NSNumber *)value;
-(NSArray*)fetchWithCondition:(NSPredicate*)predicate withAttributeKey:(NSString *)dbAttributeKey;
- (BOOL)coreDataHasEntriesForEntityName:(NSString *)entityName;
-(int)isRecordPresentForKey:(NSString *)strKey withValue:(NSNumber *)value;
-(void)deleteWithPredicate:(NSPredicate *) predicate;
-(NSArray *)fetchAllDistinct:(NSString *) attributeName;
-(NSArray *)fetch:(NSPredicate *)predicate;

@end
