#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@interface PHPrefsManager : NSObject
//                          required                           required                               optional                                 optional
- (id)initWithId:(NSString *)ident defaultValues:(NSDictionary *)defaultDict notification:(NSString *)notif notificationCallback:(void (^)(PHPrefsManager *))notifCB;

// Methods to get values:
- (id)objectForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
// Methods to set / remove values
- (void)setObject:(id)obj forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
// Saving prefs and notifying
- (void)save;
- (void)saveAndNotify;
- (void)notifyEveryone;
// Default values are used as a fallback when a specific key doesn't exist
@property (nonatomic, copy) NSDictionary *defaultValues;
// If you do not store your plist at /var/mobile/Library/Preferences override this to set full path
@property (nonatomic, retain) NSString *plistPath;

// PreferencesBundle methods similar to Karen (angelXwind)'s method
/*
 call readPreferenceValue: and setPreferenceValue: from your PSListController subclass in your preferences bundle.
 
 Add this in your PSListController implementation code:
 
 - (id)readPreferenceValue:(PSSpecifier*)specifier
 {
	return [prefsManager readPreferenceValue:specifier];
 }
 
 - (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
 {
	[prefsManager setPreferenceValue:value specifier:specifier];
 }
 */
- (id)readPreferenceValue:(id)specifier;
- (void)setPreferenceValue:(id)value specifier:(id)specifier;

@end
