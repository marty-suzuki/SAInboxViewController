# SAInboxViewController

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![Version](https://img.shields.io/cocoapods/v/SAInboxViewController.svg?style=flat)](http://cocoapods.org/pods/SAInboxViewController)
[![License](https://img.shields.io/cocoapods/l/SAInboxViewController.svg?style=flat)](http://cocoapods.org/pods/SAInboxViewController)

![](./SampleImage/sample.gif)

SAInboxViewController realizes Inbox like view transitioning.

You can launch sample project on web browser from [here](https://appetize.io/app/gxu9drpm7cqbe60mjqf2nv59t4?device=iphone5s&scale=75&orientation=portrait).

## Features

- [x] Inbox like view transitioning
- [x] Scrolling up to begining of contents transitioning
- [x] Scrolling down to end of contents transitioning
- [x] Header dragging transitioning
- [x] Left edge swiping transitioning
- [x] HeaderView hide animation
- [ ] Change StatusBar color with scrolling
- [x] Support Swift2.3
- [x] Support Siwft3

## Installation

#### CocoaPods

SAHistoryNavigationViewController is available through [CocoaPods](http://cocoapods.org). If you have cocoapods 1.1.0.rc.2 or greater, you can install
it, simply add the following line to your Podfile:

	pod "SAInboxViewController"


#### Manually

Add the [SAInboxViewController](./SAInboxViewController) directory to your project.

## Usage

If you install from cocoapods, you have to write `import SAInboxViewController`.

First of all, please use `SAInboxViewController` with `UINavigationController`.

There are two ViewControllers to realize Inbox transitioning. Please extend those ViewControllers.

1. `SAInboxViewController`... using as rootViewController
2. `SAInboxDetailViewController`... using as second ViewController

Those ViewControllers have `UITableView`, so implement ordinary `UITableView` behavior with that tableView.

If you use `UITableViewDelegate` in ViewController which extends `SAInboxDetailViewController`, please call super methods for below two methods.

```swift
override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
}

override func scrollViewDidScroll(scrollView: UIScrollView) {
	super.scrollViewDidScroll(scrollView)
}
```

If you want to present ViewController from rootViewController, implement `func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)` like this.

```swift
@objc(tableView:didSelectRowAtIndexPath:)
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let viewController = SAInboxDetailViewController()
    if let cell = tableView.cellForRow(at: indexPath), let image = headerView.screenshotImage() {
        SAInboxAnimatedTransitioningController.sharedInstance.configureCotainerView(self, cell: cell, cells: tableView.visibleCells, headerImage: image)
    }
    navigationController?.pushViewController(viewController, animated: true)
}
```

Implement `UINavigationControllerDelegate` methods, like this.

```swift
func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SAInboxAnimatedTransitioningController.sharedInstance.setOperation(operation)
}
```

## Customize
You can change HeaderView `barTintColor`, `tintColor` and `titleTextAttributes`.  
There are 2 ways to change HeaderView Appearance.

#### Application Base Appearance
SAInboxViewController class has Appearance property

```swift
SAInboxViewController.appearance.barTintColor = .black
SAInboxViewController.appearance.tintColor = .white
SAInboxViewController.appearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
```

#### ViewController Base Appearance
SAInboxViewController instance has Appearance property.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    appearance.barTintColor = .white
    appearance.tintColor = .black
    appearance.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]

    //Do not forget to set true
    enabledViewControllerBasedAppearance = true
}
```

## Requirements

- Xcode 8.0 or greater
- iOS 8.0 or greater
- [MisterFusion](https://github.com/szk-atmosphere/MisterFusion) (Swift DSL for AutoLayout)

## Author

Taiki Suzuki, s1180183@gmail.com

## License

SAInboxViewController is available under the MIT license. See the LICENSE file for more info.
