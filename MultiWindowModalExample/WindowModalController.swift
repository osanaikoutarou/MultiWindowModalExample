//
//  WindowModalController.swift
//  MultiWindowModalExample
//
//  Created by 長内幸太郎 on 2020/01/24.
//  Copyright © 2020 長内幸太郎. All rights reserved.
//

import UIKit

class WindowModalController {
    var window: UIWindow = UIWindow()
    var navigationController: WindowModalNavigationController? {
        get {
            return window.rootViewController as? WindowModalNavigationController
        }
        set {
            window.rootViewController = newValue
        }
    }
    var rootViewController: UIViewController? {
        return navigationController?.viewControllers.first
    }
    var topViewController: UIViewController? {
        return navigationController?.topViewController
    }
    
    var frame: CGRect {
        get {
            return window.frame
        }
        set {
            window.frame = newValue
        }
    }
    
    var currentType: WindowSizeType = .none
    
    init() {
        window.layer.cornerRadius = 10
        window.clipsToBounds = true
    }
    
    func present(viewController: UIViewController, windowSizeType: WindowSizeType) {
        self.currentType = windowSizeType
        
        present(viewController: viewController, viewSize: windowSizeType.frame.size, showHeight: windowSizeType.size.height, animated: true, completion: {
        })
    }
        
    func present(viewController: UIViewController,
                 viewSize: CGSize,
                 showHeight: CGFloat,
                 animated: Bool,
                 completion: (() -> Void)?) {
        self.frame = CGRect(x: 0,
                            y: UIScreen.main.bounds.height,
                            width: viewSize.width,
                            height: viewSize.height)
        let lastFrame = CGRect(x: 0,
                               y: UIScreen.main.bounds.height - showHeight,
                               width: viewSize.width,
                               height: viewSize.height)
        navigationController = WindowModalNavigationController(rootViewController: viewController)
        navigationController?.windowModalController = self
        
        window.makeKeyAndVisible()
        window.makeKey()
        
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: UIView.AnimationOptions(rawValue: 0), animations: {
            self.frame = lastFrame
        }) { (finished) in
            
        }
    }
    
    func deallocWindow() {
        window.isHidden = true
    }
}
extension WindowModalController {
    enum WindowSizeType {
        case none
        case max
        case semi

        var size: CGSize {
            switch self {
            case .max:
                return UIScreen.main.bounds.size
            case .semi:
                return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.5)
            case .none:
                return CGSize(width: UIScreen.main.bounds.size.width, height: 0)
            }
        }
        
        var frame: CGRect {
            switch self {
            case .max:
                return CGRect(x: 0, y: 50, width: size.width, height: size.height)
            case .semi:
                return CGRect(x: 0, y: UIScreen.main.bounds.size.height - size.height, width: size.width, height: WindowSizeType.max.size.height)
            case .none:
                return CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: size.width, height: WindowSizeType.max.size.height)
            }
        }
    }
    
}
extension WindowModalController {
    func changeFrame(frame: CGRect) {
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: UIView.AnimationOptions(rawValue: 0),animations: {
            self.frame = frame
            self.navigationController?.isNavigationBarHidden = false
        }) { (finished) in
        }
    }
    
    func changeFrame(windowSizeType: WindowSizeType) {
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: UIView.AnimationOptions(rawValue: 0),animations: {
            self.frame = windowSizeType.frame
//            self.navigationController?.isNavigationBarHidden = false
        }) { (finished) in
            self.currentType = windowSizeType
        }
    }
    
    func changeFrameBounce(windowSizeType: WindowSizeType) {
        //TODO:UIActivityViewControllerみたいに動かしたい
    }
}

class WindowModalNavigationController: UINavigationController {
    
    var windowFrame: CGRect?
    weak var windowModalController: WindowModalController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            windowFrame = self.view.window?.frame
        case .changed:
            self.view.window?.changeFrame(baseFrame: windowFrame, y: sender.translation(in: self.view).y)
        case .cancelled, .ended:
            let move = sender.translation(in: view).y     // 上方向がマイナス
            print(move)
            
            if move < -50 {
                if let windowModalController = windowModalController {
                    print("a")
                    switch windowModalController.currentType {
                    case .none:
                        break
                    case .max:
                        break
                    case .semi:
                        windowModalController.changeFrame(windowSizeType: .max)
                    }
                }
            }
            else if move < 50 {
                if let windowModalController = windowModalController {
                    print("b")
                    windowModalController.changeFrame(windowSizeType: windowModalController.currentType)
                }
            }
            else {
                if let windowModalController = windowModalController {
                    print("c")
                    switch windowModalController.currentType {
                    case .none:
                        break
                    case .max:
                        windowModalController.changeFrame(windowSizeType: .none)
                    case .semi:
                        windowModalController.changeFrame(windowSizeType: .none)
                    }
                }
            }
        default:
            break
        }
    }
}

extension UIView {
    func changeFrame(baseFrame: CGRect? = nil, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        var f = self.frame
        if let baseFrame = baseFrame {
            f = baseFrame
        }
        
        f.origin.x += x
        f.origin.y += y
        f.size.width += width
        f.size.height += height
        self.frame = f
    }
    
}
