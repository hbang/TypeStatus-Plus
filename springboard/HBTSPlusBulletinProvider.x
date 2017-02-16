#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusTapToOpenController.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import "../api/HBTSNotification.h"
#import <version.h>

static NSString *const kHBTSPlusAppIdentifier = @"ws.hbang.typestatusplus.app";
static NSString *const kHBTSPlusBulletinRecordIdentifier = @"ws.hbang.typestatusplus.notification";

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

	// store the current app bundle id
	_currentAppIdentifier = preferences.useAppIcon ? [notification.sourceBundleID copy] : nil;

	// construct our bulletin
	BBBulletinRequest *bulletinRequest = [[BBBulletinRequest alloc] init];

	// set the basic stuff
	bulletinRequest.bulletinID = [NSUUID UUID].UUIDString;
	bulletinRequest.sectionID = kHBTSPlusAppIdentifier;
	bulletinRequest.parentSectionID = kHBTSPlusAppIdentifier;

	// set the record id based on the keep all bulletins setting
	bulletinRequest.recordID = preferences.keepAllBulletins ? bulletinRequest.bulletinID : kHBTSPlusBulletinRecordIdentifier;

	// on iOS 9, set the title to the app display name – iOS 10 already shows it
	if (!IS_IOS_OR_NEWER(iOS_10_0)) {
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:notification.sourceBundleID];
		bulletinRequest.title = application.displayName;
	}

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
	// remove notifications with the unique id we use when the user has the keep
	// all bulletins preference off. we don't clear others, for now at least
	BBDataProviderWithdrawBulletinsWithRecordID(self, kHBTSPlusBulletinRecordIdentifier);
}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(NSUInteger)filter count:(NSUInteger)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	return [BBSectionInfo defaultSectionInfoForType:0];
}

- (NSString *)sectionIdentifier {
	return _currentAppIdentifier ?: kHBTSPlusAppIdentifier;
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

- (BOOL)migrateSectionInfo:(BBSectionInfo *)sectionInfo oldSectionInfo:(BBSectionInfo *)oldSectionInfo {
	return NO;
}

@end
