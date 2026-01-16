#import <UIKit/UIKit.h>

@interface iOSStrapMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *tpMenu;
@property (nonatomic, strong) UIButton *dot;
@end

@implementation iOSStrapMenu

// This automatically starts the menu when the dylib loads
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win) {
            iOSStrapMenu *menu = [[iOSStrapMenu alloc] initWithFrame:win.bounds];
            [win addSubview:menu];
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
    // 1. Draggable Toggle Dot
    self.dot = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dot.frame = CGRectMake(40, 100, 50, 50);
    self.dot.backgroundColor = [UIColor blackColor];
    self.dot.layer.cornerRadius = 10;
    self.dot.layer.borderColor = [UIColor whiteColor].CGColor;
    self.dot.layer.borderWidth = 2;
    [self.dot setTitle:@"iOS" forState:UIControlStateNormal];
    [self.dot addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.dot addGestureRecognizer:pan];
    [self addSubview:self.dot];

    // 2. Main Scrollable Container
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 380)];
    self.container.center = self.center;
    self.container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    self.container.layer.cornerRadius = 15;
    self.container.hidden = YES;
    self.container.userInteractionEnabled = YES;
    [self addSubview:self.container];

    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 280, 340)];
    self.scroll.contentSize = CGSizeMake(280, 600); // Ensures scrolling works
    [self.container addSubview:self.scroll];

    // 3. Teleport Sub-Menu Button
    UIButton *tpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    tpBtn.frame = CGRectMake(10, 20, 260, 45);
    [tpBtn setTitle:@"Teleport to Player >" forState:UIControlStateNormal];
    [tpBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [tpBtn addTarget:self action:@selector(showTP) forControlEvents:UIControlEventTouchUpInside];
    [self.scroll addSubview:tpBtn];
}

- (void)showTP {
    self.tpMenu = [[UIView alloc] initWithFrame:self.container.bounds];
    self.tpMenu.backgroundColor = [UIColor blackColor];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    back.frame = CGRectMake(10, 10, 60, 30);
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(hideTP) forControlEvents:UIControlEventTouchUpInside];
    [self.tpMenu addSubview:back];

    UIScrollView *plist = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 280, 330)];
    // Add player buttons here dynamically
    [self.tpMenu addSubview:plist];
    [self.container addSubview:self.tpMenu];
}

- (void)toggle { self.container.hidden = !self.container.hidden; }
- (void)hideTP { [self.tpMenu removeFromSuperview]; }
- (void)pan:(UIPanGestureRecognizer *)p {
    CGPoint t = [p translationInView:self];
    self.dot.center = CGPointMake(self.dot.center.x + t.x, self.dot.center.y + t.y);
    [p setTranslation:CGPointZero inView:self];
}

@end
