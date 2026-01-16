#import <UIKit/UIKit.h>

@interface iOSStrapMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *tpMenu;
@property (nonatomic, strong) UIButton *dot;
@end

@implementation iOSStrapMenu

// Use the constructor to inject the menu into the window
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window) {
            iOSStrapMenu *menu = [[iOSStrapMenu alloc] initWithFrame:window.bounds];
            [window addSubview:menu];
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Draggable Floating Button
    self.dot = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dot.frame = CGRectMake(50, 150, 60, 60);
    self.dot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    self.dot.layer.cornerRadius = 15; // Square-ish like the logo
    self.dot.layer.borderWidth = 1.5;
    self.dot.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.dot setTitle:@"iOS" forState:UIControlStateNormal];
    [self.dot addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.dot addGestureRecognizer:pan];
    [self addSubview:self.dot];

    // Main Menu Container
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    self.container.center = self.center;
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.98];
    self.container.layer.cornerRadius = 12;
    self.container.hidden = YES;
    self.container.userInteractionEnabled = YES;
    [self addSubview:self.container];

    // Scrollable List
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 300, 360)];
    self.scroll.contentSize = CGSizeMake(300, 500); 
    [self.container addSubview:self.scroll];

    // Speed Button
    UIButton *speed = [UIButton buttonWithType:UIButtonTypeSystem];
    speed.frame = CGRectMake(20, 20, 260, 45);
    [speed setTitle:@"WalkSpeed (200)" forState:UIControlStateNormal];
    [speed setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [speed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.scroll addSubview:speed];

    // TP Menu Button
    UIButton *tpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tpBtn.frame = CGRectMake(20, 75, 260, 45);
    [tpBtn setTitle:@"Teleport to Player >" forState:UIControlStateNormal];
    [tpBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [tpBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [tpBtn addTarget:self action:@selector(openTeleport) forControlEvents:UIControlEventTouchUpInside];
    [self.scroll addSubview:tpBtn];
}

- (void)toggle { self.container.hidden = !self.container.hidden; }

- (void)handlePan:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:self];
    self.dot.center = CGPointMake(self.dot.center.x + t.x, self.dot.center.y + t.y);
    [p setTranslation:CGPointZero inView:self];
}

- (void)openTeleport {
    self.tpMenu = [[UIView alloc] initWithFrame:self.container.bounds];
    self.tpMenu.backgroundColor = [UIColor blackColor];
    self.tpMenu.layer.cornerRadius = 12;
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.frame = CGRectMake(10, 10, 60, 30);
    [back setTitle:@"< Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(closeTeleport) forControlEvents:UIControlEventTouchUpInside];
    [self.tpMenu addSubview:back];

    UIScrollView *pl = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    NSArray *players = @[@"Player1", @"Player2", @"Admin"]; // Static list for stability
    for(int i=0; i<players.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(10, i*45, 280, 40);
        [b setTitle:players[i] forState:UIControlStateNormal];
        [pl addSubview:b];
    }
    pl.contentSize = CGSizeMake(300, players.count * 45);
    [self.tpMenu addSubview:pl];
    [self.container addSubview:self.tpMenu];
}

- (void)closeTeleport { [self.tpMenu removeFromSuperview]; }

@end
