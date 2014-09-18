

#import "AlbumsViewController.h"

@interface AlbumsViewController ()

@property (nonatomic,strong) UIScrollView *albumsScrollView;

@property (nonatomic,strong) NSMutableArray *assetGroupArray;

@end

@implementation AlbumsViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterBackground" object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_backGroud.png"] forBarMetrics:UIBarMetricsDefault];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss:) name:@"enterBackground" object:nil];
    
    self.assetGroupArray = [[ZYAlbumData shareAlbumData] groupArray];

    self.albumsScrollView.frame = CGRectMake(0, 0, 320, AdoptHeight - 44);
    
    [self showAlbums];
    
    if(![ZYAlbumData isAuthorAccessPhoto])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (AdoptHeight - 400 -44)/2, 320, 400)] ;
        imageView.image = [UIImage imageNamed:@"privacy_setting_btn.png"];
        [self.view addSubview:imageView];
    }
	// Do any additional setup after loading the view.
}

-(void)exitAlbum:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)dismiss:(NSNotification *)info
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIScrollView *)albumsScrollView
{
    if(!_albumsScrollView)
    {
        _albumsScrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_albumsScrollView];
    }
    return _albumsScrollView;
}

-(void)showAlbums
{
    int padding = 10;
    int lineNum = 3;
    
    float imageWidth = self.view.frame.size.width/lineNum -padding*(lineNum +1)/lineNum;
    
    float imageHeight = imageWidth;
    
    UIImageView *backGroundView = [[UIImageView alloc] init];
    backGroundView.userInteractionEnabled = YES;
    backGroundView.image = [UIImage imageNamed:@"big_backGround.png"];
    [self.albumsScrollView addSubview:backGroundView];
    
    for(int i = 0;i<self.assetGroupArray.count;i++)
    {
        int imageIndex = i%lineNum;
        
        int imagerow = i/lineNum;
        
        float imageXOffset = padding + (imageWidth + padding)*imageIndex;
        
        float imageYOffset = padding + (imageHeight + padding+25)*imagerow ;
        
        ALAssetsGroup *temp = (ALAssetsGroup *)(self.assetGroupArray[i]);
        
        int numImages =  temp.numberOfAssets;
        
        NSString *albumName =  [temp valueForProperty:ALAssetsGroupPropertyName];
        
        UILabel *albumNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(imageXOffset, imageYOffset +imageHeight +2,
                                                                          imageWidth, 20)];
        [albumNameLbl setTextAlignment:NSTextAlignmentCenter];
        albumNameLbl.backgroundColor = [UIColor clearColor];
        albumNameLbl.textColor = [UIColor whiteColor];
        albumNameLbl.text = albumName;
        [self.albumsScrollView addSubview:albumNameLbl];

        
        UILabel *numberPhotoLbl = [[UILabel alloc] initWithFrame:CGRectMake(imageXOffset, imageYOffset +imageHeight + 22,
                                                                            imageWidth, 10)];
        numberPhotoLbl.font = [UIFont systemFontOfSize:10];
        [numberPhotoLbl setTextAlignment:NSTextAlignmentCenter];
        numberPhotoLbl.backgroundColor = [UIColor clearColor];
        numberPhotoLbl.textColor  = [UIColor whiteColor];
        numberPhotoLbl.text = [NSString stringWithFormat:@"%d %@",numImages,ZYNSLocal(@"Photoes", nil)];
        [self.albumsScrollView addSubview:numberPhotoLbl];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageXOffset, imageYOffset, imageWidth, imageHeight)];
        [[imageView layer] setBorderWidth:1];
        
        [[imageView layer] setBorderColor:[UIColor whiteColor].CGColor];
        imageView.tag = i;
        
        imageView.image = [UIImage imageWithCGImage:((ALAssetsGroup *)([self.assetGroupArray objectAtIndex:i])).posterImage];
        
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGuest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(selectAlbum:)];
        tapGuest.numberOfTouchesRequired = 1; //手指数
        tapGuest.numberOfTapsRequired = 1; //tap次数

        [imageView addGestureRecognizer:tapGuest];

        [self.albumsScrollView addSubview:imageView];
        
        [self.albumsScrollView setContentSize:CGSizeMake(320, imageYOffset + imageHeight + padding )];
      
    }
    float h = MAX(self.albumsScrollView.contentSize.height, AdoptHeight - 44);
    backGroundView.frame = CGRectMake(0, 0, 320, h);
}

-(void)selectAlbum:(UITapGestureRecognizer *)sender
{
    int tag = sender.view.tag;
    [[ZYAlbumData shareAlbumData] setCurrentGroup:[self.assetGroupArray objectAtIndex:tag]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
