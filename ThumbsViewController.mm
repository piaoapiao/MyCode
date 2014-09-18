

#import "ThumbsViewController.h"
#import "AlbumsViewController.h"
#import "GlobalData.h"
#import "UIImageCVMatConverter.h"


@interface ThumbsViewController ()
@property (nonatomic,strong) NSMutableArray *imageViewArray;
@property (nonatomic,strong) NSMutableSet *drawSet;
@end

@implementation ThumbsViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectImage" object:nil];    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)loadSystemAlbum
{
    [[ZYAlbumData shareAlbumData] loadPhotoGroupFinished:^(NSMutableArray *array) {
        [[ZYAlbumData shareAlbumData] loadGroupPhotoes:[[ZYAlbumData shareAlbumData] sysAssetGroup] andSuccess:^()
         {
             [self.thumbsScrollView removeFromSuperview];
             self.thumbsScrollView = nil;
             _thumbsScrollView = nil;
             
             [[ZYAlbumData shareAlbumData] loadGroupPhotoes:[[ZYAlbumData shareAlbumData] currentGroup] andSuccess:^()
              {
                  NSLog(@"test");
              }];
             
             
             self.thumbsScrollView.frame = CGRectMake(0, 0, 320, AdoptHeight - 44);
             
             //需要放在前面一句后面
             self.thumbsScrollView.contentOffset = CGPointMake(0, [self.thumbsScrollView bottomOffset]);
         }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSystemAlbum];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_backGroud.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.hidden  = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss:) name:@"enterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPhoto:) name:@"selectImage" object:nil];
      
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"albums_btn.png"] forState:UIControlStateNormal];
    
    [rightBtn addTarget:self action:@selector(goToAlbums:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44 )];
    [rightButtonView addSubview:rightBtn];
   // rightButtonView.bounds = CGRectOffset(rightButtonView.bounds, 8, 0);

    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
	// Do any additional setup after loading the view.
}



-(void)dismiss:(NSNotification *)info
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)selectPhoto:(NSNotification *)info
{
    
    NSNumber *selectNumber =[info object];
    
    UIImage *image = [[ZYAlbumData shareAlbumData] originImageAtIndex:[selectNumber intValue]];
    UIImage *resizeImage=[UIImageCVMatConverter scaleAndRotateImageFrontCamera:image];
    
    [self.navigationController popViewControllerAnimated:NO];  //如果一个动画没做完，开始另外一个动画引发问题，设为NO
    
    if(_delegate && [_delegate respondsToSelector:@selector(selectedPhoto:)])
    {
        [_delegate selectedPhoto:resizeImage];
        [GlobalData shareData].iSEnterAlbum=1;
        [GlobalData shareData].iSEnterCamera=0;
        [GlobalData shareData].isReadFromLibrary=YES;
        [GlobalData shareData].isTouchAlbumorCamera=NO;
    }
    
}

//-(void)update:(NSNotification *)info
//{
//    [self viewWillAppear:YES];
//}

-(void)goToAlbums:(UIButton *)sender
{
    AlbumsViewController *albumsCtrl = [[AlbumsViewController alloc] init];
    [self.navigationController pushViewController:albumsCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.thumbsScrollView removeFromSuperview];
    self.thumbsScrollView = nil;
    _thumbsScrollView = nil;
    
    
        [[ZYAlbumData shareAlbumData] loadGroupPhotoes:[[ZYAlbumData shareAlbumData] currentGroup] andSuccess:^()
         {
             NSLog(@"test");
         }];
    

    self.thumbsScrollView.frame = CGRectMake(0, 0, 320, AdoptHeight - 44);
    
    //需要放在前面一句后面
    self.thumbsScrollView.contentOffset = CGPointMake(0, [self.thumbsScrollView bottomOffset]);
    
    if(![ZYAlbumData isAuthorAccessPhoto])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (AdoptHeight - 400 -44)/2, 320, 400)];
        imageView.image = [UIImage imageNamed:@"privacy_setting_btn.png"];
        [self.view addSubview:imageView];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(ThumbsScrollView *)thumbsScrollView
{
    if(!_thumbsScrollView)
    {
        _thumbsScrollView = [[ThumbsScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 480 - 44 -40)];
        _thumbsScrollView.controller = self;
        [self.view addSubview:_thumbsScrollView];
        
    }
    return _thumbsScrollView;
}

#pragma mark --ThumbViewDelegate
-(int)numberOfThumbsInScrollView
{
   return [[ZYAlbumData shareAlbumData] numberOfPhoto];
}

-(UIThumbView *)thumbViewForScrollView:(ThumbsScrollView *)thumbsView index:(NSNumber *)index
{
    UIThumbView *thumbView = [thumbsView dequeneReusedThumbView];
    
    if(!thumbView)
    {
        thumbView = [[UIThumbView alloc] initWithFrame:CGRectZero];
    }
    
    thumbView.tag = [index intValue];
    
    thumbView.image = [[ZYAlbumData shareAlbumData] thumbImageAtIndex:[index intValue]];
    
    return thumbView;
}


@end
