//
//  WindowModalController.swift
//  MultiWindowModalExample
//
//  Created by 長内幸太郎 on 2020/01/24.
//  Copyright © 2020 長内幸太郎. All rights reserved.
//

import UIKit

/// UIWindowを生成しModalのように表示するための管理Class
final class WindowModalController {
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
    
    /// Modalの大きさ・状態
    var currentType: WindowSizeType = .none
    
    init() {
        window.layer.cornerRadius = 10
        window.clipsToBounds = true
    }
}

extension WindowModalController {
    
    /// present 内部の画面とサイズタイプ
    func present(viewController: UIViewController, windowSizeType: WindowSizeType) {
        self.currentType = windowSizeType
        
        present(viewController: viewController, viewSize: windowSizeType.frame.size, showHeight: windowSizeType.size.height, animated: true, completion: {
        })
    }
        
    /// present 内部の画面とサイズ（基本呼ばない）
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
    
    /// Windowを削除
    func deallocWindow() {
        window.isHidden = true
    }
}

// MARK: -

class WindowSizeType {
    enum Type {
        case none
        case small
        case midium
        case large
        case full
    }

    var noneHeight: CGFloat = 0
    var smallHeight: CGFloat = 120
    var midiumHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    var largeHeight: CGFloat = UIScreen.main.bounds.height - 50
    var fullHeight: CGFloat = UIScreen.main.bounds.height
    
    func height(_ type: Type) -> CGFloat {
        switch type {
        case .none:
            return noneHeight
        case .small:
            return smallHeight
        case .midium:
            return midiumHeight
        case .large:
            return largeHeight
        case .full:
            return fullHeight
        }
    }
    
    var screenHeightType: Type = .large
    var screenHeight: CGFloat {
        return height(screenHeightType)
    }
    
    var noneWidth: CGFloat = UIScreen.main.bounds.width
    var smallWidth: CGFloat = UIScreen.main.bounds.width
    var midiumWidth: CGFloat = UIScreen.main.bounds.width
    var largeWidth: CGFloat = UIScreen.main.bounds.width
    var fullWidth: CGFloat = UIScreen.main.bounds.width
        
    func frame(_ type: Type) -> CGRect {
        switch type {
        case .none:
            return CGRect(x: (UIScreen.main.bounds.width - noneWidth)/2.0, y: UIScreen.main.bounds.size.height, width: noneWidth, height: screenHeight)
        case .small:
            return CGRect(x: (UIScreen.main.bounds.width - smallWidth)/2.0, y: UIScreen.main.bounds.size.height - smallHeight, width: smallWidth, height: screenHeight)
        case .midium:
            return CGRect(x: (UIScreen.main.bounds.width - midiumWidth)/2.0, y: UIScreen.main.bounds.size.height - midiumHeight, width: midiumWidth, height: screenHeight)
        case .large:
            return CGRect(x: (UIScreen.main.bounds.width - largeWidth)/2.0, y: UIScreen.main.bounds.size.height - largeHeight, width: largeWidth, height: screenHeight)
        case .full:
            return CGRect(x: (UIScreen.main.bounds.width - fullWidth)/2.0, y: UIScreen.main.bounds.size.height - fullHeight, width: fullWidth, height: screenHeight)
        }
    }

}

// ここから

extension WindowModalController {
    func changeFrame(frame: CGRect) {
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: UIView.AnimationOptions(rawValue: 0),animations: {
            self.frame = frame
            self.navigationController?.isNavigationBarHidden = false
        }) { (finished) in
        }
    }
    
    func changeFrame(windowSizeType: WindowSizeType) {
        self.currentType = windowSizeType
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: [.allowUserInteraction], animations: {
            self.frame = windowSizeType.frame
//            self.navigationController?.isNavigationBarHidden = false
        }) { (finished) in
            if windowSizeType == .none {
                self.deallocWindow()
            }
        }
    }
    
    func changeFrameBounce(windowSizeType: WindowSizeType) {
        //TODO:UIActivityViewControllerみたいに動かしたい
    }
}

protocol WindowModalViewController: UIViewController {
    func dismissWindow()
}
extension WindowModalViewController {
    func dismissWindow() {
        if let nav = self.navigationController as? WindowModalNavigationController {
            nav.windowModalController?.changeFrame(windowSizeType: .none)
        }
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
        print(sender.state)
        switch sender.state {
        case .began:
            self.view.layer.removeAllAnimations()
            windowFrame = self.view.window?.frame
        case .changed:
            self.view.window?.changeFrame(baseFrame: windowFrame, y: sender.translation(in: self.view).y)
        case .cancelled, .ended:
            let move = sender.translation(in: view).y     // 上方向がマイナス
            print(move)
            
            if move < -50 { // 上に動かした
                if let windowModalController = windowModalController {
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
            else if move < 50 { // 動かす量が少ない
                if let windowModalController = windowModalController {
                    windowModalController.changeFrame(windowSizeType: windowModalController.currentType)
                }
            }
            else {  // 下に動かした
                if let windowModalController = windowModalController {
                    switch windowModalController.currentType {
                    case .none:
                        break
                    case .max:
                        windowModalController.changeFrame(windowSizeType: .semi)
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
        f.origin.y = max(WindowSizeType.max.frame.origin.y, f.origin.y)
        f.size.width += width
        f.size.height += height
        self.frame = f
    }
    
}
