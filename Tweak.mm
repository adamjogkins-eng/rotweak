#import <UIKit/UIKit.h>
#include <fstream>

// --- GLOBALS TO STORE STATES ---
BOOL fpsEnabled = YES;
BOOL lowLagEnabled = YES;

// --- CORE LOGIC: WRITES THE CONFIG ---
void updateRobloxConfig() {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *settingsDir = [libPath stringByAppendingPathComponent:@"Application Support/ClientSettings"];
    NSString *filePath = [settingsDir stringByAppendingPathComponent:@"ClientAppSettings.json"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:settingsDir withIntermediateDirectories:YES attributes:nil error:nil];

    // Build JSON based on toggles
    NSString *fpsVal = fpsEnabled ? @"120" : @"60";
    NSString *shadowVal = lowLagEnabled ? @"0" : @"1";
    NSString *pbrVal = lowLagEnabled ? @"1" : @"0";

    NSString *json = [NSString stringWithFormat:@"{\"DFIntTaskSchedulerTargetFps\":%@,\"FIntRenderShadowIntensity\":%@,\"FIntDebugTextureManagerSkipPBR\":%@}", fpsVal, shadowVal, pbrVal];

    [json writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// --- UI COMPONENTS ---
@interface ModMenu : UIView
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation ModMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 20;
        self.clipsToBounds = YES;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;

        // Glass Effect (Blur)
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurView.frame = self.bounds;
        [self addSubview:_blurView];

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"GEMINI OPTIMIZER";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [_blurView.contentView addSubview:title];

        // Toggle 1: FPS
        [self addToggleNamed:@"Unlock 120 FPS" yY:60 selector:@selector(toggleFPS:) isOn:fpsEnabled];
        // Toggle 2: Low Lag
        [self addToggleNamed:@"Extreme Low Lag" yY:110 selector:@selector(toggleLag:) isOn:lowLagEnabled];
        
        // Close Button
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(20, 170, frame.size.width-40, 40);
        close.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:0.8];
        close.layer.cornerRadius = 10;
        [close setTitle:@"Hide Menu" forState:UIControlStateNormal];
        [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [_blurView.contentView addSubview:close];
    }
    return self;
}

- (void)addToggleNamed:(NSString *)name yY:(CGFloat)y selector:(SEL)sel isOn:(BOOL)on {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 150, 30)];
    label.text = name;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [_blurView.contentView addSubview:label];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, y, 50, 30)];
    sw.onTintColor = [UIColor cyanColor];
    sw.on = on;
    [sw addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [_blurView.contentView addSubview:sw];
}

- (void)toggleFPS:(UISwitch *)sender { fpsEnabled = sender.on; updateRobloxConfig(); }
- (void)toggleLag:(UISwitch *)sender { lowLagEnabled = sender.on; updateRobloxConfig(); }
- (void)hide { self.hidden = YES; }
@end

// --- DRAGGABLE BUTTON TO OPEN MENU ---
@interface FloatingBtn : UIButton
@end
@implementation FloatingBtn { CGPoint last; }
- (void)touchesMoved:(NSSet*)t withEvent:(UIEvent*)e {
    self.center = [[t anyObject] locationInView:self.superview];
}
@end

// --- INITIALIZATION ---
ModMenu *menu;
__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        // Setup Menu (Hidden at start)
        menu = [[ModMenu alloc] initWithFrame:CGRectMake(win.center.x-125, win.center.y-110, 250, 230)];
        menu.hidden = YES;
        [win addSubview:menu];

        // Setup Floating Button
        FloatingBtn *btn = [FloatingBtn buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 50, 50);
        btn.backgroundColor = [UIColor cyanColor];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"G" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
        
        updateRobloxConfig(); // Initial run
    });
}

static void showMenu() { menu.hidden = !menu.hidden; }
