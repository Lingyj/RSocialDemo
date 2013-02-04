//
//  RSocialShareFormViewController.m
//  RSocialDemo
//
//  Created by Alex Rezit on 03/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialShareFormViewController.h"

NSString * const kRSocialShareContentKeyContent = @"content";

NSString * const kRSocialShareContentKeyImage = @"image";
NSString * const kRSocialShareContentKeyImageLink = @"imageLink";

NSString * const kRSocialShareContentKeyLink = @"link";
NSString * const kRSocialShareContentKeyLinkTitle = @"linkTitle";
NSString * const kRSocialShareContentKeyLinkDescription = @"linkDescription";
NSString * const kRSocialShareContentKeyLinkImageLink = @"linkImageLink";

NSUInteger const kRSocialShareFormTextLengthOffset = 20;

CGFloat const kRSocialShareFormBottomBarHeight = 44.0f;

@interface RSocialShareFormViewController ()

@property (nonatomic, strong) NSMutableDictionary *content;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButton;
@property (nonatomic, strong) UIBarButtonItem *doneBarButton;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *textLengthLabel;

@property (nonatomic, readonly) NSUInteger textLength;

// Actions
- (void)cancelButtonPressed:(UIButton *)button;
- (void)doneButtonPressed:(UIButton *)button;

// View control
- (void)updateButtonStatus;
- (void)updateTextCounter;
- (void)updateFrameInBounds:(CGRect)bounds;
- (void)dismiss;

@end

@implementation RSocialShareFormViewController

#pragma mark - Actions

- (void)cancelButtonPressed:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(shareFormViewControllerDidCancel:)]) {
        [self.delegate shareFormViewControllerDidCancel:self];
    }
    [self dismiss];
}

- (void)doneButtonPressed:(UIButton *)button
{
    self.content[kRSocialShareContentKeyContent] = self.contentTextView.text;
    if ([self.delegate respondsToSelector:@selector(shareFormViewController:didFinishWithContent:)]) {
        [self.delegate shareFormViewController:self didFinishWithContent:self.content];
    }
    [self dismiss];
}

#pragma mark - View control

- (void)updateButtonStatus
{
    NSUInteger textLength = self.textLength;
    self.doneBarButton.enabled = textLength && textLength <= self.maxTextLength;
}

- (void)updateTextCounter
{
    NSUInteger textLength = self.textLength;
    UILabel *textLengthLabel = self.textLengthLabel;
    
    // Color
    if (textLength > self.maxTextLength) {
        textLengthLabel.text = [NSString stringWithFormat:@"- %d", textLength - self.maxTextLength];
        textLengthLabel.textColor = [UIColor redColor];
    } else {
        textLengthLabel.text = [NSString stringWithFormat:@"%d", self.maxTextLength - textLength];
        textLengthLabel.textColor = [UIColor lightGrayColor];
    }
    
    // Hidden
    if (textLength > self.maxTextLength - kRSocialShareFormTextLengthOffset) {
        textLengthLabel.hidden = NO;
    } else {
        textLengthLabel.hidden = YES;
    }
}

- (void)updateFrameInBounds:(CGRect)bounds
{
    self.contentTextView.frame = CGRectMake(bounds.origin.x,
                                            bounds.origin.y,
                                            bounds.size.width,
                                            bounds.size.height - kRSocialShareFormBottomBarHeight);
    self.textLengthLabel.frame = CGRectMake(bounds.origin.x,
                                            bounds.origin.y + bounds.size.height - kRSocialShareFormBottomBarHeight,
                                            bounds.size.width,
                                            kRSocialShareFormBottomBarHeight);
}

- (void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(shareFormViewControllerDidDismiss:)]) {
            [self.delegate shareFormViewControllerDidDismiss:self];
        }
    }];
}

#pragma mark - Getters and setters

- (NSUInteger)textLength
{
    UITextView *textView = self.contentTextView;
    NSUInteger textLength = 0;
    for (NSUInteger i = 0; i < textView.text.length; i++) {
        unichar uc = [textView.text characterAtIndex:i];
        textLength += isascii(uc)?1:2;
    }
    return textLength;
}

#pragma mark - Life cycle

+ (void)promptWithContent:(NSDictionary *)content
                 delegate:(id<RSocialShareFormViewControllerDelegate>)delegate
{
    // Find the window on the top.
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *topWindow = application.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in application.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    
    // Present view controller.
    UINavigationController *navigationController = [RSocialShareFormViewController navigationControllerWithContent:content delegate:delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
    });
}

+ (UINavigationController *)navigationControllerWithContent:(NSDictionary *)content
                                                   delegate:(id<RSocialShareFormViewControllerDelegate>)delegate
{
    RSocialShareFormViewController *shareFormViewController = [[[[self class] alloc] init] autorelease];
    shareFormViewController.content = [content.mutableCopy autorelease];
    shareFormViewController.delegate = delegate;
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:shareFormViewController] autorelease];
    return navigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.maxTextLength = 140;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)] autorelease];
    self.cancelBarButton = cancelBarButton;
    
    UIBarButtonItem *doneBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)] autorelease];
    self.doneBarButton = doneBarButton;
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButton;
    self.navigationItem.rightBarButtonItem = self.doneBarButton;
    
    UITextView *contentTextView = [[[UITextView alloc] init] autorelease];
    contentTextView.delegate = self;
    contentTextView.font = [UIFont systemFontOfSize:18.0f];
    contentTextView.text = self.content[kRSocialShareContentKeyContent];
    self.contentTextView = contentTextView;
    [self.view addSubview:contentTextView];
    
    UILabel *textLengthLabel = [[[UILabel alloc] init] autorelease];
    textLengthLabel.backgroundColor = [UIColor clearColor];
    textLengthLabel.textAlignment = NSTextAlignmentRight;
    textLengthLabel.font = [UIFont systemFontOfSize:16.0f];
    self.textLengthLabel = textLengthLabel;
    [self.view addSubview:textLengthLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect viewBounds = self.view.bounds;
    [self updateFrameInBounds:viewBounds];
    
    [self.contentTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeightChanged:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? YES : toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateButtonStatus];
    [self updateTextCounter];
}

#pragma mark - Keyboard notification

- (void)keyboardHeightChanged:(NSNotification *)notification
{
    CGRect viewBounds = self.view.bounds;
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateFrameInBounds:CGRectMake(viewBounds.origin.x,
                                         viewBounds.origin.y,
                                         viewBounds.size.width,
                                         viewBounds.size.height - keyboardFrame.size.height)];
}

@end
