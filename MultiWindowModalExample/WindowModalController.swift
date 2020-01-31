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
    
    var windowSizeType = WindowSizeType()
    /// Modalの大きさ・状態
    var currentType: WindowSizeType.SizeType = .none
    
    var delegate: WindowModalControllerDelegate?
    
    var timer: Timer?
    
    init() {
        window.backgroundColor = .clear
    }
}

extension WindowModalController {
    
    /// present 内部の画面とサイズタイプ
    func present(viewController: UIViewController, sizeType: WindowSizeType.SizeType) {
        self.currentType = sizeType
        
        self.frame = windowSizeType.frame(WindowSizeType.SizeType.none)

        navigationController = WindowModalNavigationController(rootViewController: viewController)
        navigationController?.windowModalController = self
        
        window.makeKeyAndVisible()
        window.makeKey()
        
        //TODO: 移動
        let shadowView = UIView(frame: CGRect(origin: .zero, size: self.frame.size))
        shadowView.backgroundColor = .white
        shadowView.clipsToBounds = false
        shadowView.layer.cornerRadius = 20
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero//CGSize(width: 1, height: 1)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 3
        window.insertSubview(shadowView, at: 0)

        changeFrame(sizeType: sizeType)
    }
    
    /// Windowを削除
    func deallocWindow() {
        window.isHidden = true
    }
}

// MARK: -

/// 画面のサイズタイプ
class WindowSizeType {
    enum SizeType {
        case none
        case small
        case midium
        case large
        case full
    }
    
    // 変更可能
    var noneHeight: CGFloat = 0
    var smallHeight: CGFloat = 120
    var midiumHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    var largeHeight: CGFloat = UIScreen.main.bounds.height - 50
    var fullHeight: CGFloat = UIScreen.main.bounds.height
    
    var noneWidth: CGFloat = UIScreen.main.bounds.width
    var smallWidth: CGFloat = UIScreen.main.bounds.width
    var midiumWidth: CGFloat = UIScreen.main.bounds.width
    var largeWidth: CGFloat = UIScreen.main.bounds.width
    var fullWidth: CGFloat = UIScreen.main.bounds.width
   
    var maxType: SizeType = .large
    var screenHeightType: SizeType = .large
    var screenHeight: CGFloat {
        return height(screenHeightType)
    }
    
    /// スワイプ時の挙動定義（変更可能）
    var actionUp: [(from: SizeType, to: SizeType)] = [(.none, .none),
                                                      (.small, .large),
                                                      (.midium, .large),
                                                      (.large, .large)]
    var actionDown: [(from: SizeType, to: SizeType)] = [(.none, .none),
                                                        (.small, .none),
                                                        (.midium, .none),
                                                        (.large, .small)]
    
    func getActionUp(from: SizeType) -> SizeType? {
        return actionUp.first(where: { $0.from == from })?.to
    }
    func getActionDown(from: SizeType) -> SizeType? {
        return actionDown.first(where: { $0.from == from })?.to
    }

    func height(_ type: SizeType) -> CGFloat {
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
            
    func frame(_ type: SizeType) -> CGRect {
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

extension WindowModalController {
    func changeFrame(frame: CGRect) {
        // 60fpsでframeを送る
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true, block: { (timer) in
            self.delegate?.windowModalController(windowModalController: self, didMove: self.window.frameInAnimation)
        })
        timer?.fire()
        
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: UIView.AnimationOptions(rawValue: 0),animations: {
            self.frame = frame
            self.navigationController?.isNavigationBarHidden = false
        }) { (finished) in
            self.timer?.fire()
            self.timer?.invalidate()
        }
    }
    
    /// 画面サイズを変更する
    func changeFrame(sizeType: WindowSizeType.SizeType) {
        // 60fpsでframeを送る
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true, block: { (timer) in
            self.delegate?.windowModalController(windowModalController: self, didMove: self.window.frameInAnimation)
        })
        timer?.fire()
        
        self.currentType = sizeType
        UIView.perform(UIView.SystemAnimation.delete, on: [], options: [.allowUserInteraction], animations: {
            self.frame = self.windowSizeType.frame(sizeType)
        }) { (finished) in
            if sizeType == .none {
                self.deallocWindow()
            }
            
            self.timer?.fire()
            self.timer?.invalidate()
        }
    }
}

// MARK: -

/// UIWindow -> WindowModalNavigationController -> UIViewController となっている場合に
/// UIViewControllerに適用するprotocol
protocol WindowModalControllerDelegate: UIViewController {
    /// 閉じる
    func dismissWindowModal()
    
    ///
    func windowModalController(windowModalController: WindowModalController, didMove windowFrame: CGRect)
}
extension WindowModalControllerDelegate {
    func dismissWindowModal() {
        guard let nav = self.navigationController as? WindowModalNavigationController,
            let controller = nav.windowModalController else {
                return
        }
        
        controller.changeFrame(sizeType: .none)
    }
    
    func windowModalController(windowModalController: WindowModalController, didMove windowFrame: CGRect) {
    }
}

/// UIWindow -> WindowModalNavigationController
class WindowModalNavigationController: UINavigationController {
    
    var windowFrame: CGRect?
    weak var windowModalController: WindowModalController?
    
    var isDefaultNavigationBarHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デフォルトで
        isNavigationBarHidden = isDefaultNavigationBarHidden

//        view.layer.cornerRadius = 10
//        view.clipsToBounds = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        guard let windowModalController = windowModalController else {
            return
        }
        
        switch sender.state {
        case .began:
            self.view.layer.removeAllAnimations()
            windowFrame = self.view.window?.frame
            
            windowModalController.delegate?.windowModalController(windowModalController: windowModalController, didMove: self.windowModalController?.window.frameInAnimation ?? .zero)
            
        case .changed:
            self.view.window?.changeFrame(baseFrame: windowFrame, fullFrameHeight: WindowSizeType().height(windowModalController.windowSizeType.maxType), y: sender.translation(in: self.view).y)

            windowModalController.delegate?.windowModalController(windowModalController: windowModalController, didMove: self.windowModalController?.window.frameInAnimation ?? .zero)
            
        case .cancelled, .ended:
            let move = sender.translation(in: view).y     // 上方向がマイナス
            let vector = sender.velocity(in: view).y      // 上方向がマイナス
            
            let currentType = windowModalController.currentType
            if move < -40 && vector < -40 { // 上に動かした
                if let nextSizeType = windowModalController.windowSizeType.getActionUp(from: currentType) {
                    windowModalController.changeFrame(sizeType: nextSizeType)
                }
            }
            else if move > 40 && vector > 40 { // 下に動かした
                if let nextSizeType = windowModalController.windowSizeType.getActionDown(from: currentType) {
                    windowModalController.changeFrame(sizeType: nextSizeType)
                }
            }
            else {
                windowModalController.changeFrame(sizeType: currentType)
            }
            
        default:
            break
        }
    }
}

extension UIView {
    func changeFrame(baseFrame: CGRect? = nil, fullFrameHeight: CGFloat, x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        var f = self.frame
        if let baseFrame = baseFrame {
            f = baseFrame
        }
        
        f.origin.x += x
        f.origin.y += y
        f.origin.y = max(UIScreen.main.bounds.height - fullFrameHeight, f.origin.y)
        f.size.width += width
        f.size.height += height
        self.frame = f
    }
    
}

private extension UIView {
    /// アニメーション中のframeを取る方法
    var frameInAnimation: CGRect {
        return self.layer.presentation()?.frame ?? .zero
    }
}
//private extension UIWindow {
//    /// アニメーション中のframeを取る方法
//    var frameInAnimation: CGRect {
//        return self.layer.presentation()?.frame ?? .zero
//    }
//}
