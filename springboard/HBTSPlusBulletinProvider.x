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
#import <TypeStatusPlusProvider/HBTSNotification.h>

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

- (void)showMessagesBulletinWithContent:(NSString *)content {
	// construct a notification and pass it over to the main method
	HBTSNotification *notification = [[HBTSNotification alloc] init];
	notification.sourceBundleID = @"com.apple.MobileSMS";
	notification.content = content;
	[self showBulletinForNotification:notification];
}

- (void)showBulletinForNotification:(HBTSNotification *)notification {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.keepAllBulletins) {
		BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatusplus.notification");
	}

	BBBulletinRequest *bulletinRequest = [[[BBBulletinRequest alloc] init] autorelease];
	bulletinRequest.showsUnreadIndicator = NO;

	bulletinRequest.bulletinID = kHBTSPlusAppIdentifier;
	bulletinRequest.publisherBulletinID = kHBTSPlusAppIdentifier;
	bulletinRequest.recordID = kHBTSPlusAppIdentifier;

	_correctAppIdentifier = preferences.useAppIcon ? notification.sourceBundleID : kHBTSPlusAppIdentifier;

	// the correct app identifier can change in settings, so we don't put that in the dispatch_once
	bulletinRequest.sectionID = _correctAppIdentifier;

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

- (BOOL)migrateSectionInfo:(BBSectionInfo *)sectionInfo oldSectionInfo:(BBSectionInfo *)oldSectionInfo {
	return NO;
}

@end
