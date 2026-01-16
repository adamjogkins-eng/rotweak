#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <fstream>

// --- PREFERENCES STORAGE ---
static BOOL fpsEnabled = YES;
static BOOL shadowsEnabled = NO;
static BOOL lowResEnabled = YES;

// --- ENGINE LOGIC: UPDATES THE JSON ---
void syncBlockssSettings() {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folder = [libPath stringByAppendingPathComponent:@"Application Support/ClientSettings"];
    NSString *file = [folder stringByAppendingPathComponent:@"ClientAppSettings.json"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];

    // Map switches to Roblox Fast Flags
    NSString *fpsVal = fpsEnabled ? @"120" : @"60";
    NSString *shadVal = shadowsEnabled ? @"1" : @"0";
    NSString *texVal = lowResEnabled ? @"1" : @"0";

    NSString *json = [NSString stringWithFormat:
        @"{\"DFIntTaskSchedulerTargetFps\":%@,\"FIntRenderShadowIntensity\":%@,\"FIntDebugTextureManagerSkipPBR\":%@}", 
        fpsVal, shadVal, texVal];

    [json writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// --- THE UI INTERFACE ---
@interface BlockssMenu : UIView
@end

@implementation BlockssMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 22;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.85]; // Sleek dark glass

        // Header Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 30)];
        title.text = @"BLOCKSS OPTIMIZER";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:title];

        // ACTUAL SETTINGS ROWS
        [self addSettingRow:@"Unlock 120 FPS" y:60 action:@selector(toggleFPS:) isOn:fpsEnabled];
        [self addSettingRow:@"Enable Shadows" y:110 action:@selector(toggleShadows:) isOn:shadowsEnabled];
        [self addSettingRow:@"Texture Optimizer" y:160 action:@selector(toggleTextures:) isOn:lowResEnabled];
    }
    return self;
}

- (void)addSettingRow:(NSString *)title y:(CGFloat)y action:(SEL)selector isOn:(BOOL)on {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 160, 31)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [self addSubview:label];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, y, 50, 31)];
    sw.on = on;
    sw.onTintColor = [UIColor cyanColor];
    [sw addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    [self addSubview:sw];
}

// TOGGLE CALLBACKS
- (void)toggleFPS:(UISwitch *)s { fpsEnabled = s.on; syncBlockssSettings(); }
- (void)toggleShadows:(UISwitch *)s { shadowsEnabled = s.on; syncBlockssSettings(); }
- (void)toggleTextures:(UISwitch *)s { lowResEnabled = s.on; syncBlockssSettings(); }

@end

// --- INJECTION ENGINE ---
static BlockssMenu *mainMenu;
__attribute__((constructor))
static void startBlockss() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        mainMenu = [[BlockssMenu alloc] initWithFrame:CGRectMake(window.center.x - 135, 120, 270, 220)];
        [window addSubview:mainMenu];
        syncBlockssSettings(); // Apply defaults on boot
    });
}
