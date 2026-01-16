#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <fstream>

// --- UI TOGGLE STATES ---
static BOOL fpsEnabled = YES;
static BOOL lowLagEnabled = YES;

// --- CONFIG WRITER ---
void updateRobloxConfig() {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *settingsDir = [libPath stringByAppendingPathComponent:@"Application Support/ClientSettings"];
    NSString *filePath = [settingsDir stringByAppendingPathComponent:@"ClientAppSettings.json"];
    [[NSFileManager defaultManager] createDirectoryAtPath:settingsDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *fps = fpsEnabled ? @"120" : @"60";
    NSString *shdw = lowLagEnabled ? @"0" : @"1";
    NSString *pbr = lowLagEnabled ? @"1" : @"0";

    NSString *json = [NSString stringWithFormat:@"{\"DFIntTaskSchedulerTargetFps\":%@,\"FIntRenderShadowIntensity\":%@,\"FIntDebugTextureManagerSkipPBR\":%@}", fps, shdw, pbr];
    [json writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// --- THE MENU UI ---
@interface ModMenu : UIView
@end

@implementation ModMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 20;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8]; // Dark rounded box

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
        title.text = @"GEMINI OPTIMIZER";
        title.textColor = [UIColor cyanColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:title];

        // Toggle Buttons
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        hideBtn.frame = CGRectMake(25, 150, 200, 40);
        [hideBtn setTitle:@"CLOSE MENU" forState:UIControlStateNormal];
        hideBtn.backgroundColor = [UIColor grayColor];
        hideBtn.layer.cornerRadius = 10;
        [hideBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideBtn];
    }
    return self;
}
- (void)hideMenu { self.hidden = YES; }
@end

// --- FLOATING BUTTON ---
@interface FloatingBtn : UIButton
@end
@implementation FloatingBtn
- (void)touchesMoved:(NSSet*)t withEvent:(UIEvent*)e {
    self.center = [[t anyObject] locationInView:self.superview];
}
@end

// --- APP START ---
static ModMenu *myMenu;
__attribute__((constructor))
static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        myMenu = [[ModMenu alloc] initWithFrame:CGRectMake(50, 100, 250, 210)];
        myMenu.hidden = YES;
        [win addSubview:myMenu];

        FloatingBtn *fb = [FloatingBtn buttonWithType:UIButtonTypeCustom];
        fb.frame = CGRectMake(10, 200, 50, 50);
        fb.backgroundColor = [UIColor cyanColor];
        fb.layer.cornerRadius = 25;
        [fb setTitle:@"G" forState:UIControlStateNormal];
        [fb addTarget:myMenu action:@selector(setHidden:) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:fb];
        
        updateRobloxConfig();
    });
}
