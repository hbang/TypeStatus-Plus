#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusTapToOpenController.h"
#import "HBTSPlusPreferences.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <BulletinBoard/BBDataProviderIdentity.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import "../api/HBTSNotification.h"

static NSString *const kHBTSPlusAppIdentifier = @"ws.hbang.typestatusplus.app";

@implementation HBTSPlusBulletinProvider {
	NSString *_currentAppIdentifier;
}

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinForNotification:(HBTSNotification *)notification {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	[self clearAllBulletins];

	// store the current app bundle id
	_currentAppIdentifier = preferences.useAppIcon ? [notification.sourceBundleID copy] : nil;

	// construct our bulletin
	BBBulletinRequest *bulletinRequest = [[BBBulletinRequest alloc] init];

	// set the basic stuff
	bulletinRequest.bulletinID = [NSUUID UUID].UUIDString;
	bulletinRequest.sectionID = kHBTSPlusAppIdentifier;
	bulletinRequest.parentSectionID = kHBTSPlusAppIdentifier;

	// set the record id based on the keep all bulletins setting
	bulletinRequest.recordID = preferences.keepAllBulletins ? bulletinRequest.bulletinID : @"ws.hbang.typestatusplus.notification";

	// set the title to the app display name
	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:notification.sourceBundleID];
	bulletinRequest.title = application.displayName;

	// set all the rest
	bulletinRequest.message = notification.content;
	bulletinRequest.date = notification.date;
	bulletinRequest.lastInterruptDate = [NSDate date];

	// set a callback to open the conversation
	bulletinRequest.defaultAction = [BBAction actionWithCallblock:^{
		// let the tap to open controller do its thing
		[[HBTSPlusTapToOpenController sharedInstance] receivedStatusBarTappedMessage:nil];
	}];

	BBDataProviderAddBulletin(self, bulletinRequest);
}

- (void)clearAllBulletins {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	// if the user has set us to only keep one notification, withdraw previous
	// notifications
	if (!preferences.keepAllBulletins) {
		BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatusplus.notification");
	}
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
	return _currentAppIdentifier ?: kHBTSPlusAppIdentifier;
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

- (BOOL)migrateSectionInfo:(BBSectionInfo *)sectionInfo oldSectionInfo:(BBSectionInfo *)oldSectionInfo {
	return NO;
}

@end
