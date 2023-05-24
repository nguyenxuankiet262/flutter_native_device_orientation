//
//  OrientationListener.m
//  native_device_orientation
//
//  Created by Sebastiaan de Smet on 21/01/2019.
//


#import "OrientationListener.h"

@implementation OrientationListener {
    UIDeviceOrientation lastDeviceOrientation;
    NSString* lastOrientation;
}

- (void)startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved {

    if (@available(iOS 16.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *scene = (UIWindowScene *)array[0];
        [UIViewController attemptRotationToDeviceOrientation];
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:maskOrientation];
        [scene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {}];
    } else {
        UIDevice *device = [UIDevice currentDevice];
        [device beginGeneratingDeviceOrientationNotifications];
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    self.observer = [nc addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

        NSString* orientation = [self getDeviceOrientation];

        if (![orientation isEqualToString:(self->lastOrientation)]) {
            self->lastOrientation = orientation;
            orientationRetrieved(orientation);
        }
    }];

    self-> lastOrientation = [self getDeviceOrientation];
    orientationRetrieved(lastOrientation);
}

- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved{
    NSString* orientation = [self getDeviceOrientation];
    orientationRetrieved(orientation);
}

- (NSString*)getDeviceOrientation {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            return PORTRAIT_UP;
        case UIInterfaceOrientationPortraitUpsideDown:
            return PORTRAIT_DOWN;
        case UIInterfaceOrientationLandscapeRight:
            // return left for right as UIInterfaceOrientation is 'the amount needed
            // to rotate to get back to normal', not the actual rotation
            return LANDSCAPE_LEFT;
        case UIInterfaceOrientationLandscapeLeft:
            // return right for left, see above
            return LANDSCAPE_RIGHT;
        default:
            return UNKNOWN;
            break;
    }
}

- (void)stopOrientationListener {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (@available(iOS 16.0, *)) {
        UIDevice *device = [UIDevice currentDevice];
        [device endGeneratingDeviceOrientationNotifications];
    }
    [nc removeObserver:self.observer];
    self.observer = NULL;
}

@end
