#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBDataProviderIdentity.h>
#import <BulletinBoard/BBSectionIcon.h>
#import <BulletinBoard/BBSectionIconVariant.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationIcon.h>
#import "../api/HBTSNotification.h"
#import <version.h>

static NSString *const kHBTSPlusAppIdentifier = @"ws.hbang.typestatusplus.app";
static NSString *const kHBTSPlusBulletinRecordIdentifier = @"ws.hbang.typestatusplus.notification";

@implementation HBTSPlusBulletinProvider

+ (instancetype)sharedInstance {
	static HBTSPlusBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		BBDataProviderIdentity *identity = [BBDataProviderIdentity identityForDataProvider:self];
		identity.sectionIdentifier = kHBTSPlusAppIdentifier;
		identity.sectionDisplayName = @"TypeStatus";
		self.identity = identity;

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedSetStatusBarNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

- (void)_receivedSetStatusBarNotification:(NSNotification *)nsNotification {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	// not enabled? don’t do anything
	if (!preferences.enabled) {
		return;
	}

	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:nsNotification.userInfo];

	// right off the bat, if there’s no title or content, stop right there.
	if (!notification.content || [notification.content isEqualToString:@""]) {
		return;
	}

	// if we need to remove previous bulletins, do so now
	if (!preferences.keepAllBulletins) {
		[self clearAllBulletins];
	}

	// if we’re in the right state to show a bulletin, do it
	if ([HBTSPlusStateHelper shouldShowBanner]) {
		[self showBulletinForNotification:notification];
	}
}

- (void)showBulletinForNotification:(HBTSNotification *)notification {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	// construct our bulletin
	BBBulletinRequest *bulletinRequest = [[BBBulletinRequest alloc] init];

	// set the basic stuff
	bulletinRequest.bulletinID = [NSUUID UUID].UUIDString;
	bulletinRequest.sectionID = kHBTSPlusAppIdentifier;

	// set the record id based on the keep all bulletins setting
	bulletinRequest.recordID = preferences.keepAllBulletins ? bulletinRequest.bulletinID : kHBTSPlusBulletinRecordIdentifier;

	// set the title to the app display name
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:notification.sourceBundleID];
	bulletinRequest.title = app.displayName;

	// if we’re using the app icon
	if (preferences.useAppIcon) {
		// get the icon
		SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
		UIImage *icon = [appIcon getUnmaskedIconImage:MIIconVariantSmall];

		// override the icon with what we have
		bulletinRequest.icon = [[BBSectionIcon alloc] init];
		[bulletinRequest.icon addVariant:[BBSectionIconVariant variantWithFormat:0 imageData:UIImagePNGRepresentation(icon)]];
	}

	// set all the rest
	bulletinRequest.message = notification.content;
	bulletinRequest.date = notification.date;
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.turnsOnDisplay = preferences.wakeWhenLocked;

	// set a callback to open the conversation
	bulletinRequest.defaultAction = [BBAction actionWithCallblock:^{
		// let the tap to open controller do its thing
		[[HBTSPlusTapToOpenController sharedInstance] receivedStatusBarTappedMessage:nil];
	}];

	BBDataProviderAddBulletin(self, bulletinRequest);
}

- (void)clearAllBulletins {
	// remove notifications with the unique id we use when the user has the keep all bulletins
	// preference off. we don't clear others, for now at least
	BBDataProviderWithdrawBulletinsWithRecordID(self, kHBTSPlusBulletinRecordIdentifier);
}

#pragma mark - BBDataProvider

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

@end

