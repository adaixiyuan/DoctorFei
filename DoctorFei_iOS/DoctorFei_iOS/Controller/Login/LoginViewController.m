//
//  LoginViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "LoginViewController.h"
#import <IHKeyboardAvoiding.h>
#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "DeviceUtil.h"
#import "DoctorAPI.h"
#import "APService.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *loginBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [IHKeyboardAvoiding setAvoidingView:self.view withTarget:self.loginBackgroundImageView];
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[self.phoneTextField.rac_textSignal, self.passwordTextField.rac_textSignal] reduce:^(NSString *phone, NSString *password){
        return @(phone.length == 11 && password.length > 5);
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"LoginRegisterSegueIdentifier"]) {
        [self.phoneTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
}

#pragma mark - Actions
- (IBAction)loginButtonClicked:(id)sender {
    [self.phoneTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    NSLog(@"%@",[APService registrationID]);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.dimBackground = YES;
    [hud setLabelText:@"登录中..."];
    NSDictionary *params = @{
                             @"username": self.phoneTextField.text,
                             @"password": self.passwordTextField.text,
                             @"sn": [APService registrationID]
                             };
    NSLog(@"%@",params);
    [DoctorAPI loginWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary *dataDict = [responseObject firstObject];
        hud.mode = MBProgressHUDModeText;
        if ([dataDict[@"state"]intValue] == 1) {
            hud.labelText = dataDict[@"msg"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"userId"] forKey:@"UserId"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"icon"] forKey:@"UserIcon"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"RealName"] forKey:@"UserRealName"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"hospital"] forKey:@"UserHospital"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"department"] forKey:@"UserDepartment"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"jobtitle"] forKey:@"UserJobTitle"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"Email"] forKey:@"UserEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:dataDict[@"OtherContact"] forKey:@"UserOtherContact"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            hud.labelText = @"登录错误";
            hud.detailsLabelText = dataDict[@"msg"];
        }
        [hud hide:YES afterDelay:1.5f];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
}
@end