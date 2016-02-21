#import "HBTSPlusBulletinProvider.h"
#import "../HBTSPlusPreferences.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBDataProviderIdentity.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>

static NSString *const kHBTSPlusAppIdentifier = @"ws.hbang.typestatusplus.app";

@implementation HBTSPlusBulletinProvider {
	NSString *_correctAppIdentifier;
}

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinWithContent:(NSString *)content appIdentifier:(NSString *)appIdentifier {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.keepAllBulletins) {
		BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatusplus.notification");
	}

	static BBBulletinRequest *bulletinRequest = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bulletinRequest = [[BBBulletinRequest alloc] init];
		bulletinRequest.showsUnreadIndicator = NO;

		bulletinRequest.bulletinID = kHBTSPlusAppIdentifier;
		bulletinRequest.publisherBulletinID = kHBTSPlusAppIdentifier;
		bulletinRequest.recordID = kHBTSPlusAppIdentifier;
	});

	[_correctAppIdentifier release];
	_correctAppIdentifier = preferences.useAppIcon ? appIdentifier : kHBTSPlusAppIdentifier;

	// the correct app identifier can change in settings, so we don't put that in the dispatch_once
	bulletinRequest.sectionID = _correctAppIdentifier;

	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appIdentifier];
	bulletinRequest.title = application.displayName;

	bulletinRequest.message = content;
	bulletinRequest.date = [NSDate date];
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.defaultAction = [BBAction actionWithLaunchBundleID:appIdentifier callblock:nil];

	BBDataProviderAddBulletin(self, bulletinRequest);
}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(NSUInteger)filter count:(NSUInteger)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	BBSectionInfo *sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
	return sectionInfo;
}

- (NSString *)sectionIdentifier {
	// return the app identifier. if it doesn't exist yet, just return the typestatus plus icon
	return _correctAppIdentifier ?: @"ws.hbang.typestatusplus.app";
}

- (NSString *)sectionDisplayName {
	return @"TypeStatus Plus";
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

- (BOOL)migrateSectionInfo:(BBSectionInfo *)arg1 oldSectionInfo:(BBSectionInfo *)arg2 {
	return NO;
}

#pragma mark - Memory management

- (void)dealloc {
	[_correctAppIdentifier release];

	[super dealloc];
}

@end
