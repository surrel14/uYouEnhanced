#import "RootOptionsController.h"
#import "ColourOptionsController.h"
#import "ColourOptionsController2.h"

@interface RootOptionsController ()

@property (strong, nonatomic) UIButton *backButton;
@property (assign, nonatomic) UIUserInterfaceStyle pageStyle;

@end

@implementation RootOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"uYouEnhanced Extras Menu";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"YTSans-Bold" size:22], NSForegroundColorAttributeName: [UIColor whiteColor]}];

    [self setupBackButton];
    [self setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)setupBackButton {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSBundle *backIcon = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"uYouPlus" ofType:@"bundle"]];
    UIImage *backImage = [UIImage imageNamed:@"Back.png" inBundle:backIcon compatibleWithTraitCollection:nil];
    backImage = [self resizeImage:backImage newSize:CGSizeMake(24, 24)];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setTintColor:[UIColor systemBlueColor]];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBackButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = customBackButton;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (UIImage *)resizeImage:(UIImage *)image newSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RootTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];

    BOOL isPortrait = UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait;
    BOOL isPhone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;

    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Custom Theme Color";
            cell.detailTextLabel.text = isPortrait && isPhone ? @"" : @"You must go to uYouEnhanced settings and then go to 'Dark Mode' and set it to 'Custom Dark Mode' for it to work.";
            cell.imageView.image = [UIImage systemImageNamed:@"slider.horizontal.3"];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Custom Tint Color";
            cell.detailTextLabel.text = isPortrait && isPhone ? @"" : @"You must go to uYouEnhanced settings and have LowContrastMode enabled and then go to 'LowContrastMode Selector' and set it to 'Custom' for it to work.";
            cell.imageView.image = [UIImage systemImageNamed:@"drop.fill"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Clear Cache";
            UILabel *cache = [[UILabel alloc] init];
            cache.text = [self getCacheSize];
            cache.textColor = [UIColor secondaryLabelColor];
            cache.font = [UIFont systemFontOfSize:16];
            cache.textAlignment = NSTextAlignmentRight;
            [cache sizeToFit];
            cell.accessoryView = cache;
            cell.imageView.image = [UIImage systemImageNamed:@"trash"];
        }
    }

    [self applyColorSchemeForCell:cell];
}

- (void)applyColorSchemeForCell:(UITableViewCell *)cell {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    cell.imageView.tintColor = cell.textLabel.textColor;
}

- (NSString *)getCacheSize {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cachePath error:nil];
    
    unsigned long long int folderSize = 0;
    for (NSString *fileName in filesArray) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        folderSize += [fileAttributes fileSize];
    }

    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter.countStyle = NSByteCountFormatterCountStyleFile;

    return [formatter stringFromByteCount:folderSize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ColourOptionsController *colourOptionsController = [[ColourOptionsController alloc] init];
            UINavigationController *colourOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:colourOptionsController];
            colourOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:colourOptionsControllerView animated:YES completion:nil];
        }
        if (indexPath.row == 1) {
            ColourOptionsController2 *colourOptionsController2 = [[ColourOptionsController2 alloc] init];
            UINavigationController *colourOptionsController2View = [[UINavigationController alloc] initWithRootViewController:colourOptionsController2];
            colourOptionsController2View.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:colourOptionsController2View animated:YES completion:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            activityIndicator.color = [UIColor labelColor];
            [activityIndicator startAnimating];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryView = activityIndicator;

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
                });
            });
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self.tableView reloadData];
}

@end

@implementation RootOptionsController (Privates)

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
