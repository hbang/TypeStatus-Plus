#import "HBTSPlusBulletinProvider.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBDataProviderIdentity.h>

@implementation HBTSPlusBulletinProvider

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinWithTitle:(NSString *)title content:(NSString *)content {
	BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatusplus.notification");

	static BBBulletinRequest *bulletinRequest = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bulletinRequest = [[BBBulletinRequest alloc] init];
		bulletinRequest.bulletinID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.sectionID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.publisherBulletinID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.recordID = @"ws.hbang.typestatusplus.app";
		bulletinRequest.showsUnreadIndicator = NO;
	});

	bulletinRequest.title = title;
	bulletinRequest.message = content;
	bulletinRequest.date = [NSDate date];
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.defaultAction = [BBAction actionWithLaunchBundleID:@"com.apple.MobileSMS" callblock:nil];

	BBDataProviderAddBulletin(self, bulletinRequest);

}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(NSUInteger)filter count:(NSUInteger)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	BBSectionInfo *sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
	sectionInfo.sectionID = self.sectionIdentifier;
	return sectionInfo;
}

- (NSString *)sectionIdentifier {
	return @"ws.hbang.typestatusplus.app";
}

- (NSString *)sectionDisplayName {
	return @"TypeStatus";
}

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

- (BOOL)canPerformMigration {
	return YES;
}

- (id)defaultSubsectionInfos {
	return nil;
}

@end
