# Preferences Helper
*A static library that manages preferences easily.*


## How to Use PHPrefsManager

**Something like this could go into your constructor:**

     NSString *const tweakId = @"com.baileyseymour.mytweak";
     NSString *const prefsNotification = @"com.baileyseyomur.mytweak-prefsChanged";
     
     NSDictionary *defaultDict = @{@"enabled":@(YES), @"sliderValue":@(0.5), @"unlockText":@"I like slide to unlock"};
     
     prefsManager = [[PHPrefsManager alloc] initWithId:tweakId defaultValues:defaultDict notification:prefsNotification notificationCallback:^void (PHPrefsManager *manager) {
      // do something after Preferences are reloaded

     }];
 ---
## Init Options for PHPrefsManager
The method below is the proper way to initialize  `PHPrefsManager`

    - (id)initWithId:(NSString *)ident defaultValues:(NSDictionary *)defaultDict notification:(NSString *)notif notificationCallback:(void (^)(PHPrefsManager *))notifCB
    
### args
`arg1` = **bundle identifier**  `(NSString)`

*This should be the identifier of your tweak and will be used to load your plist file.*

`arg2` = **default values** `(NSDictionary)`  

*The default values from this Dictionary are used as a fallback when a specific key doesn't exist*.

`arg3` = **notification name** `(NSString)` | *optional*

*`PHPrefsManager` will listen for this notification to load updates and post this notification when prefs are saved.*

`arg4` = **notification callback (block)** `(void (^)(PHPrefsManager *))` | *optional*

*This block will be run when preferences are reloaded into `PHPrefsManager`.*

*Notification callback is optional as Preferences Helper already updates itself (no need to reload any dictionary)*

---

## Retrieving Preference Values
The methods below are pretty straightforward.
You can use `-objectForKey:` like you would with a `NSDictionary` or a convenience methods like `-boolForKey:`.

    - (id)objectForKey:(NSString *)key;
    - (BOOL)boolForKey:(NSString *)key;
    - (float)floatForKey:(NSString *)key;
    - (int)intForKey:(NSString *)key;
    
 ---
 
## Setting Preference Values

 You can use `- (void)setObject:(id)obj forKey:(NSString *)key` to set values.
Removing  values can be done by `- (void)removeObjectForKey:(NSString *)key;`.

---
 
## Saving
Saving is really easy.  
Most of the time you will want to use `- (void)saveAndNotify;`  
If for some reason you don't want to post a notification you can just `- (void)save;`  
*You can always post the notification later via `- (void)notifyEveryone;`*

---
## Implementing with PreferenceBundles
Preferences Helper uses a similar method to the way shown here [iphonedevwiki](http://www.iphonedevwiki.net/index.php/PreferenceBundles#Loading_Preferences_into_sandboxed.2Funsandboxed_processes_in_iOS_8) aka Karen (angelXwind)'s method.

The way this works is you override setPreferenceValue:specifier and readPreferenceValue: in your `PSListController`.

`PHPrefsManager` has methods that take care of all of the hard work.

**Add this in your `PSListController` implementation code:**
 
     - (id)readPreferenceValue:(PSSpecifier*)specifier
     {
    	return [prefsManager readPreferenceValue:specifier];
     }
 
     - (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier
     {
    	[prefsManager setPreferenceValue:value specifier:specifier];
     }
     
  *note prefsManager is a `PHPrefsManager` object.
  
---  
## Building and Linking

- Build the Xcode project and it will give you a static library named `libPreferencesHelper.a`.
- Copy it to the same folder as your Makefile and add this line to your Makefile:
   `mytweak_LDFLAGS = -L. -lPreferencesHelper` to link it.
- You will also have to include the header file `PreferencesHelper.h` in your code.
- Also note you will most likely need to link your PreferenceBundle to `libPreferencesHelper.a` by adding the same lines to your Makefile.