#import <UIKit/UIKit.h>

@interface iOSStrapMenu : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIScrollView *mainScroll;
@property (nonatomic, strong) UIView *teleportMenu;
@property (nonatomic, strong) UIButton *floatingButton;
@end

@implementation iOSStrapMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self setupFloatingButton];
        [self setupMainUI];
    }
    return self;
}

- (void)setupFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(100, 100, 60, 60);
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    self.floatingButton.layer.cornerRadius = 30;
    self.floatingButton.layer.borderWidth = 2;
    self.floatingButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.floatingButton setTitle:@"iOS" forState:UIControlStateNormal];
    
    // Dragging Logic
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:pan];
    
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:self.floatingButton];
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
    self.mainContainer.layer.cornerRadius = 15;
    self.mainContainer.hidden = YES;
    
    // Header
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text = @"iOSStrap Admin";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.mainContainer addSubview:title];

    // Scrollable Area
    self.mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    self.mainScroll.contentSize = CGSizeMake(300, 500); // Expanded for scrolling
    [self.mainContainer addSubview:self.mainScroll];

    // --- Commands ---
    [self addCommandButton:@"Infinite Jump" yOffset:10 action:@selector(toggleInfJump)];
    [self addCommandButton:@"Speed Boost" yOffset:60 action:@selector(toggleSpeed)];
    [self addCommandButton:@"NoClip" yOffset:110 action:@selector(toggleNoClip)];
    [self addCommandButton:@"Fly Mode" yOffset:160 action:@selector(toggleFly)];
    
    // Teleport Button (Opens Sub-menu)
    UIButton *tpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tpBtn.frame = CGRectMake(20, 210, 260, 40);
    [tpBtn setTitle:@"Teleport to Player >" forState:UIControlStateNormal];
    [tpBtn setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1]];
    [tpBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [tpBtn addTarget:self action:@selector(showTeleportMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScroll addSubview:tpBtn];

    [[UIApplication sharedApplication].keyWindow addSubview:self.mainContainer];
}

- (void)addCommandButton:(NSString *)name yOffset:(CGFloat)y action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, y, 260, 40);
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.mainScroll addSubview:btn];
}

- (void)showTeleportMenu {
    self.teleportMenu = [[UIView alloc] initWithFrame:self.mainContainer.bounds];
    self.teleportMenu.backgroundColor = [UIColor blackColor];
    self.teleportMenu.layer.cornerRadius = 15;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(10, 10, 50, 30);
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(hideTeleportMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.teleportMenu addSubview:backBtn];

    UIScrollView *playerList = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    
    // Logic: Getting current players (Pseudo-logic for Roblox Engine Hook)
    NSArray *players = @[@"Player1", @"Player2", @"Admin_User", @"Guest_44"]; // Replace with actual engine call
    
    for (int i = 0; i < players.count; i++) {
        UIButton *pBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pBtn.frame = CGRectMake(10, i * 45, 280, 40);
        [pBtn setTitle:players[i] forState:UIControlStateNormal];
        [pBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [pBtn addTarget:self action:@selector(teleportToPlayer:) forControlEvents:UIControlEventTouchUpInside];
        [playerList addSubview:pBtn];
    }
    
    playerList.contentSize = CGSizeMake(300, players.count * 45);
    [self.teleportMenu addSubview:playerList];
    [self.mainContainer addSubview:self.teleportMenu];
}

// Actions
- (void)toggleMenu { self.mainContainer.hidden = !self.mainContainer.hidden; }
- (void)hideTeleportMenu { [self.teleportMenu removeFromSuperview]; }
- (void)teleportToPlayer:(UIButton *)sender {
    NSLog(@"Teleporting to: %@", sender.titleLabel.text);
    // Hook: Character.HumanoidRootPart.CFrame = Target.CFrame
}

// Command Placeholders for logic
- (void)toggleInfJump { /* Logic for Inf Jump */ }
- (void)toggleSpeed { /* Logic for WalkSpeed */ }
- (void)toggleNoClip { /* Logic for NoClip */ }
- (void)toggleFly { /* Logic for Fly */ }

@end
