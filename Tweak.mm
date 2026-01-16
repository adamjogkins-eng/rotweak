#import <UIKit/UIKit.h>

@interface iOSStrapMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *tpMenu;
@property (nonatomic, strong) UIButton *dot;
@end

@implementation iOSStrapMenu

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win && @available(iOS 13.0, *)) {
            for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive) {
                    win = s.windows.firstObject; break;
                }
            }
        }
        if (win) {
            iOSStrapMenu *menu = [[iOSStrapMenu alloc] initWithFrame:win.bounds];
            [win addSubview:menu];
        }
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO; // Pass touches through to game
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Draggable Circle (The Toggle)
    self.dot = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dot.frame = CGRectMake(50, 150, 55, 55);
    self.dot.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    self.dot.layer.cornerRadius = 27.5;
    self.dot.layer.borderWidth = 2;
    self.dot.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.dot setTitle:@"iOS" forState:UIControlStateNormal];
    [self.dot addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.dot addGestureRecognizer:pan];
    [self addSubview:self.dot];

    // Main Scrollable Menu
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    self.container.center = self.center;
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.container.layer.cornerRadius = 20;
    self.container.hidden = YES;
    self.container.userInteractionEnabled = YES;
    [self addSubview:self.container];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 30)];
    title.text = @"iOSStrap - iPhone";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [self.container addSubview:title];

    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    self.scroll.contentSize = CGSizeMake(300, 500); // Scrollable height
    [self.container addSubview:self.scroll];

    [self addCmd:@"Infinite Jump" y:20];
    [self addCmd:@"WalkSpeed (200)" y:70];
    
    UIButton *tpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tpBtn.frame = CGRectMake(20, 120, 260, 45);
    [tpBtn setTitle:@"Teleport to Player >" forState:UIControlStateNormal];
    [tpBtn setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [tpBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [tpBtn addTarget:self action:@selector(openTP) forControlEvents:UIControlEventTouchUpInside];
    [self.scroll addSubview:tpBtn];
}

- (void)addCmd:(NSString *)name y:(CGFloat)y {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(20, y, 260, 45);
    [b setTitle:name forState:UIControlStateNormal];
    [b setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1]];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    b.layer.cornerRadius = 8;
    [self.scroll addSubview:b];
}

- (void)openTP {
    self.tpMenu = [[UIView alloc] initWithFrame:self.container.bounds];
    self.tpMenu.backgroundColor = [UIColor blackColor];
    self.tpMenu.layer.cornerRadius = 20;
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.frame = CGRectMake(10, 10, 60, 30);
    [back setTitle:@"< Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(closeTP) forControlEvents:UIControlEventTouchUpInside];
    [self.tpMenu addSubview:back];

    UIScrollView *plist = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300, 350)];
    NSArray *names = @[@"Player_1", @"Admin_User", @"Pro_Gamer"]; // Replace with engine list
    for (int i=0; i<names.count; i++) {
        UIButton *p = [UIButton buttonWithType:UIButtonTypeSystem];
        p.frame = CGRectMake(10, i*50, 280, 40);
        [p setTitle:names[i] forState:UIControlStateNormal];
        [p addTarget:self action:@selector(tpTo:) forControlEvents:UIControlEventTouchUpInside];
        [plist addSubview:p];
    }
    plist.contentSize = CGSizeMake(300, names.count * 50);
    [self.tpMenu addSubview:plist];
    [self.container addSubview:self.tpMenu];
}

- (void)toggle { self.container.hidden = !self.container.hidden; }
- (void)closeTP { [self.tpMenu removeFromSuperview]; }
- (void)tpTo:(UIButton *)s { NSLog(@"TP to %@", s.titleLabel.text); }
- (void)panned:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:self];
    self.dot.center = CGPointMake(self.dot.center.x + t.x, self.dot.center.y + t.y);
    [p setTranslation:CGPointZero inView:self];
}
@end

__attribute__((constructor)) static void init() { [iOSStrapMenu load]; }
