#import "PreferencesHelper.h"

@interface PSSpecifier : NSObject
- (NSDictionary *)properties;
@end

@interface PHPrefsManager ()
@property (assign) void (^notificationCallback)(PHPrefsManager *);
@property (nonatomic, copy) NSString *notificationName;
@property (nonatomic, retain) NSMutableDictionary *currentPrefsImplementation;
- (void)notificationReceived;
@end

static void got_notification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo )
{
    if (observer)
        [(PHPrefsManager *)observer notificationReceived];
}

@implementation PHPrefsManager
@synthesize notificationCallback, defaultValues, notificationName, currentPrefsImplementation, plistPath=_plistPath;

- (void)updateCurrentImplementation
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:self.defaultValues];

  NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[self plistPath]];
  [prefs addEntriesFromDictionary:plist];

  self.currentPrefsImplementation = prefs;
}

- (NSString *)identifier
{
    return [[self.plistPath lastPathComponent] stringByDeletingPathExtension];
}

- (void)setPlistPath:(NSString *)plistPath
{
    _plistPath = plistPath;
    [self updateCurrentImplementation];
}

- (id)initWithId:(NSString *)ident defaultValues:(NSDictionary *)defaultDict notification:(NSString *)notif notificationCallback:(void (^)(PHPrefsManager *))notifCB
{
 self = [self init];

    _plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", ident];
 self.defaultValues = defaultDict;
    
 if (notif)
 {
  self.notificationName = notif;
  self.notificationCallback = notifCB;
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, (CFNotificationCallback)got_notification,
  (CFStringRef)notif, NULL, CFNotificationSuspensionBehaviorCoalesce);
 }

 [self updateCurrentImplementation];

 return  self;
}

- (void)notificationReceived
{
  [self updateCurrentImplementation];
    
  if (self.notificationCallback)
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
    return ([self objectForKey:[specifier.properties objectForKey:@"key"]]) ?: [specifier.properties objectForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    
    if (!specifier) return;
    [self setObject:value forKey:[specifier.properties objectForKey:@"key"]];
    [self saveAndNotify];
}

- (void)dealloc
{
 self.defaultValues = nil;
 self.notificationName = nil;
 self.plistPath = nil;
 self.currentPrefsImplementation = nil;

 [super dealloc];
}

@end
