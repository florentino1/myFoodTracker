//
//  main.m
//  myFoodTracker
//
//  Created by 莫玄 on 2021/4/10.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "singleMeal.h"
#import "DBManager.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;

    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
