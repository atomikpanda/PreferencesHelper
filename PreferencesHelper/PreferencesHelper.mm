#import "PreferencesHelper.h"

@interface PSSpecifier : NSObject
- (NSDictionary *)properties;
@end

@interface PHPrefsManager ()
@property (assign) void (^notificationCallback)(PHPrefsManager *);
@property (nonatomic, retain) NSString *notificationName;
@property (nonatomic, retain) NSString *identifer;
@property (nonatomic, retain) NSMutableDictionary *currentPrefsImplementation;
@end

@implementation PHPrefsManager
@synthesize notificationCallback, defaultValues, notificationName, identifer, currentPrefsImplementation;

- (NSString *)plistPath
{
  return [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.identifer];
}

- (void)updateCurrentImplementation
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:self.defaultValues];

  NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[self plistPath]];
  [prefs addEntriesFromDictionary:plist];

  self.currentPrefsImplementation = prefs;
}

+ (id)managerWithId:(NSString *)ident defaultValues:(NSDictionary *)defaultDict notification:(NSString *)notif notificationCallback:(void (^)(PHPrefsManager *))notifCB
{
 PHPrefsManager *manager = [[PHPrefsManager alloc] init];

 manager.identifer = ident;
 manager.defaultValues = defaultDict;

 if (notif)
 {
  manager.notificationName = notif;
  manager.notificationCallback = notifCB;
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)^void (void) {
    [manager notificationReceived];
  },
  (CFStringRef)notif, NULL, CFNotificationSuspensionBehaviorCoalesce);
 }

 [manager updateCurrentImplementation];

 return [manager autorelease];
}

- (void)notificationReceived
{
  [self updateCurrentImplementation];
  self.notificationCallback(self);
}

- (id)objectForKey:(NSString *)key
{
  id obj = [self.currentPrefsImplementation objectForKey:key];

  return obj;
}

- (BOOL)boolForKey:(NSString *)key;
{
  id obj = [self objectForKey:key];
  if (!obj) obj = @(NO);
  return [obj boolValue];
}

- (float)floatForKey:(NSString *)key;
{
  id obj = [self objectForKey:key];
  if (!obj) obj = @(0.0f);
  return [obj floatValue];
}

- (int)intForKey:(NSString *)key;
{
  id obj = [self objectForKey:key];
  if (!obj) obj = @(0);
  return [obj intValue];
}

- (void)setObject:(id)obj forKey:(NSString *)key
{
 [self.currentPrefsImplementation setObject:obj forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
  [self.currentPrefsImplementation removeObjectForKey:key];
}

- (void)save
{
 [self.currentPrefsImplementation writeToFile:[self plistPath] atomically:YES];
}

- (void)notifyEveryone
{
  if (self.notificationName)
   CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)self.notificationName, NULL, NULL, YES);
}

- (void)saveAndNotify
{
  [self save];
  [self notifyEveryone];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    return ([self objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    [self setObject:value forKey:specifier.properties[@"key"]];
    [self saveAndNotify];
}

- (void)dealloc
{
 self.defaultValues = nil;
 self.notificationName = nil;
 self.identifer = nil;
 self.currentPrefsImplementation = nil;

 [super dealloc];
}

@end
