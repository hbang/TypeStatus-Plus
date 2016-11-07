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

- (void)showMessagesBulletinWithContent:(NSString *)content {
	// construct a notification and pass it over to the main method
	HBTSNotification *notification = [[HBTSNotification alloc] init];
	notification.sourceBundleID = @"com.apple.MobileSMS";
	notification.content = content;
	[self showBulletinForNotification:notification];
}

- (void)showBulletinForNotification:(HBTSNotification *)notification {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	[self clearAllBulletins];

	BBBulletinRequest *bulletinRequest = [[BBBulletinRequest alloc] init];

	// set the bulletin id, which is just a UUID
	bulletinRequest.bulletinID = [NSUUID UUID].UUIDString;

	// set the record id based on the keep all bulletins setting
	bulletinRequest.recordID = preferences.keepAllBulletins ? @"ws.hbang.typestatusplus.notification" : bulletinRequest.bulletinID;

	// set the section id according to the user’s settings
	_currentAppIdentifier = [preferences.useAppIcon ? notification.sourceBundleID : kHBTSPlusAppIdentifier copy];
	bulletinRequest.sectionID = _currentAppIdentifier;

	// set the title to the app display name
	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:notification.sourceBundleID];
	bulletinRequest.title = application.displayName;

	// set all the rest
	bulletinRequest.message = notification.content;
	bulletinRequest.date = notification.date;
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.showsUnreadIndicator = NO;

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
	// return the app identifier. if it doesn't exist yet, just return the typestatus plus one
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
