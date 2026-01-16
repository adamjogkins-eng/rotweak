#import <UIKit/UIKit.h>
#import <substrate.h>

// --- Configuration ---
#define MENU_TITLE @"iOSStrap Admin"

@interface iOSStrapMenu : UIView
@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) UIView *teleportMenu;
@property (nonatomic, strong) UIButton *floatingButton;
+ (instancetype)sharedInstance;
@end

@implementation iOSStrapMenu

+ (instancetype)sharedInstance {
    static iOSStrapMenu *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[iOSStrapMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return shared;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO; // Allow touches to pass through background
        [self setupFloatingButton];
        [self setupMainUI];
    }
    return self;
}

- (void)setupFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(100, 100, 60, 60);
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:1.0 alpha:0.9];
    self.floatingButton.layer.cornerRadius = 15; // Squared look like the logo you sent
    self.floatingButton.layer.borderWidth = 2;
    self.floatingButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.floatingButton setTitle:@"iOS" forState:UIControlStateNormal];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:pan];
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // UIWindow hack to ensure it stays on top
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:self.floatingButton];
    });
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.floatingButton.superview];
    self.floatingButton.center = CGPointMake(self.floatingButton.center.x + translation.x, self.floatingButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.floatingButton.superview];
}

- (void)setupMainUI {
    self.mainContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    self.mainContainer.center = self.center;
    self.mainContainer.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    self.mainContainer.layer.cornerRadius = 10;
    self.mainContainer.hidden = YES;
    self.mainContainer.userInteractionEnabled = YES;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text = MENU_TITLE;
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [self.mainContainer addSubview:title];

    self.mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    self.mainScroll.contentSize = CGSizeMake(300, 600);
    self.mainScroll.userInteractionEnabled = YES;
    [self.mainContainer addSubview:self.mainScroll];

    [self addBtn:@"Infinite Jump" y:10 act:@selector(toggleInfJump)];
    [self addBtn:@"Speed (200)" y:60 act:@selector(toggleSpeed)];
    [self addBtn:@"NoClip" y:110 act:@selector(toggleNoClip)];
    [self addBtn:@"Fly Mode" y:160 act:@selector(toggleFly)];
    [self addBtn:@"Teleport to Player >" y:210 act:@selector(showTeleportMenu)];

    [[UIApplication sharedApplication].keyWindow addSubview:self.mainContainer];
}

- (void)addBtn:(NSString *)name y:(CGFloat)y act:(SEL)s {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, y, 260, 40);
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    [btn addTarget:self action:s forControlEvents:UIControlEventTouchUpInside];
    [self.mainScroll addSubview:btn];
}

- (void)showTeleportMenu {
    self.teleportMenu = [[UIView alloc] initWithFrame:self.mainContainer.bounds];
    self.teleportMenu.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.teleportMenu.layer.cornerRadius = 10;
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.frame = CGRectMake(10, 10, 60, 30);
    [back setTitle:@"< Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(hideTeleportMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.teleportMenu addSubview:back];

    UIScrollView *pList = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    
    // Dynamic Player List (Mock data for compilation)
    NSArray *players = @[@"Player_Alpha", @"Guest_123", @"Build_Admin"];
    for (int i = 0; i < players.count; i++) {
        UIButton *pBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pBtn.frame = CGRectMake(10, i * 45, 280, 40);
        [pBtn setTitle:players[i] forState:UIControlStateNormal];
        [pBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [pBtn addTarget:self action:@selector(doTeleport:) forControlEvents:UIControlEventTouchUpInside];
        [pList addSubview:pBtn];
    }
    pList.contentSize = CGSizeMake(300, players.count * 45);
    [self.teleportMenu addSubview:pList];
    [self.mainContainer addSubview:self.teleportMenu];
}

- (void)toggleMenu { self.mainContainer.hidden = !self.mainContainer.hidden; }
- (void)hideTeleportMenu { [self.teleportMenu removeFromSuperview]; }
- (void)doTeleport:(UIButton *)s { NSLog(@"Teleporting to %@", s.titleLabel.text); }

// Command Logic Hooks
- (void)toggleInfJump { /* Memory Patch Here */ }
- (void)toggleSpeed { /* Memory Patch Here */ }
- (void)toggleNoClip { /* Memory Patch Here */ }
- (void)toggleFly { /* Memory Patch Here */ }

@end

// --- Constructor to start the menu ---
static __attribute__((constructor)) void initializeMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [iOSStrapMenu sharedInstance];
    });
}
