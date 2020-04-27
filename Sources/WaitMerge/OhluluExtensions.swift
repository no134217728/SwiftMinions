//
//  OhluluExtensions.swift
//  SwiftMinions
//
//  Created by HIS HSIANG JIH on 2020/2/23.
//  Copyright © 2020 SwiftMinions. All rights reserved.
//

import UIKit

public extension CGSize {
    
    /// create size with square
    init(square: Double) {
        self.init(width: square, height: square)
    }
    
    /// create size with square
    init(square: Float) {
        self.init(width: square.cgfloatValue, height: square.cgfloatValue)
    }
    
    /// create size with square
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }
    
    /// create size with square
    init(square: Int) {
        self = .init(width: square, height: square)
    }
}


public extension CGRect {
    
    /// x, y is 0
    init(width: Double, height: Double) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
    
    /// x, y is 0
    init(width: Float, height: Float) {
        self.init(x: 0, y: 0, width: width.cgfloatValue, height: height.cgfloatValue)
    }
    
    /// x, y is 0
    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
    
    /// x, y is 0
    init(width: Int, height: Int) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
    
    /// x, y is 0
    init(square: Double) {
        self.init(x: 0, y: 0, width: square, height: square)
    }
    
    /// x, y is 0
    init(square: Float) {
        self.init(x: 0, y: 0, width: square.cgfloatValue, height: square.cgfloatValue)
    }
    
    /// x, y is 0
    init(square: CGFloat) {
        self.init(x: 0, y: 0, width: square, height: square)
    }
    
    /// x, y is 0
    init(square: Int) {
        self.init(x: 0, y: 0, width: square, height: square)
    }
}

public extension UIScreen {
    
    static var height: Double {
        return Double(UIScreen.heightf)
    }
    
    static var width: Double {
        return Double(UIScreen.widthf)
    }
    
    static var heightf: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var widthf: CGFloat {
        return UIScreen.main.bounds.width
    }
}

public extension Thread {
    static func mainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}

public extension UIWindow {
    
    static var safeAreaInset: UIEdgeInsets {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else {
            return .init(edge: 0)
        }
        
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            return .init(edge: 0)
        }
    }
    
    static var topViewController: UIViewController? {
        var result: UIViewController? = nil
        guard let window = UIApplication.shared.delegate?.window,
            var topViewController = window?.rootViewController else {
                return result
        }
        while let presentedVC = topViewController.presentedViewController {
            topViewController = presentedVC
        }
        result = topViewController
        return result
    }
    
    static func `switch`(
        toRootViewController viewController: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.35,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        _ completion: (() -> Void)? = nil) {
        guard let _window = UIApplication.shared.delegate?.window,
            let window = _window else {
                return
        }
        
        UIView.transition(with: window, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }
}

public extension UIImage {
    
    enum ImageMode {
        case fit, fill
    }
    
    func resizeImage(to size: CGSize,
                     isCircle: Bool = false,
                     mode: ImageMode = .fill) -> UIImage? {
        // 找出目前螢幕的scale，視網膜技術為2.0 or 3.0
        let scale = UIScreen.main.scale
        
        //產生畫布，第一個參數指定大小，第二個參數true:不透明(黑色底) false表示背景透明，scale為螢幕scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let widthRatio: CGFloat = size.width / self.size.width
        let heightRadio: CGFloat = size.height / self.size.height
        
        // max: fit
        // min: fill
        let ratio: CGFloat
        switch mode {
        case .fill:
            ratio = min(widthRatio, heightRadio)
        case .fit:
            ratio = max(widthRatio, heightRadio)
        }
        
        let imageSize: CGSize  = CGSize(width: floor(self.size.width*ratio), height: floor(self.size.height*ratio))
        
        //切成圓形
        if isCircle {
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            circlePath.addClip()
        }
        
        self.draw(in: CGRect(x: -(imageSize.width-size.width)/2.0,
                             y: -(imageSize.height-size.height)/2.0,
                             width: imageSize.width,
                             height: imageSize.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return smallImage
    }
    
    
    /// Create UIImage from UIColor
    /// - Parameter color: UIColor
    /// - Parameter size: CGSize, default value: 1x1
    static func create(from color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

fileprivate extension UIScrollView {
    func addObserver() {
        scrollViewObserverObj = observe(\.contentSize) { [weak self] (obj, change) in
            guard let self = self, self.enableHeightToFit else {
                return
            }
            
            var height = max(obj.contentSize.height + obj.contentInset.vertical,
                             self.minimunHeightToFit)
            
            if let maxHeight = self.maximunHeightToFit {
                height = min(maxHeight, height)
            }
            
            let heightContraint = obj.constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
            
            if let heightContraint = heightContraint {
                heightContraint.constant = height
            } else {
                obj.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
    }
    
    func removeObserver() {
        objc_removeAssociatedObjects(self)
    }
}

public extension UIStackView {
    
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
    
    func forceRemoveAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    func forceRemoveArrangedSubviews(_ views: [UIView]) {
        for view in views {
            if !subviews.contains(view) {
                continue
            }
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

public extension UIViewController {
    
    @objc func dismiss(_ animated: Bool = true, _ completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }
    
    @objc func present(_ vc: UIViewController, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        present(vc, animated: animated, completion: completion)
    }
}

public extension UIViewController {
    
    var isPresent: Bool {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first == self {
                return true
            }
        }
        return false
    }
}

public extension UIViewController {
    func addChild(viewController child: UIViewController, containerView: UIView) {
        addChild(child)
        containerView.bounds = child.view.bounds
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChild(viewController child: UIViewController) {
        guard parent != nil else { return }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

public extension UIView {
    enum AnimationType {
        case fadeOut
        case fadeIn
    }

    /// Animation type
    /// - Parameter type: set this value with AnimationType
    /// - Parameter duration: set this value to duration (default is 0.25)
    /// - Parameter delay: set this value to delay (default is 0)
    /// - Parameter completion:  optional completion handler (default is nil).
    func animation(
        type: AnimationType,
        duration: TimeInterval = 0.25,
        delay: TimeInterval = 0,
        _ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, animations: {
            self.alpha = type == .fadeOut ? 0 : 1
        }, completion: completion)
    }

    /// Animated with a horizontal shake, duration -> 0.35s
    /// - duration -> 0.35s
    /// - offsets -> [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0]
    func errorshake(completion:(() -> Void)? = nil) {
        shake(duration: 0.35,
              offsets: [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0],
              completion: completion)
    }
    
    func shake(duration: CFTimeInterval,
               offsets: [CGFloat],
               completion:(() -> Void)? = nil) {
        constraints.forEach { $0.isActive = false }
        translatesAutoresizingMaskIntoConstraints = true
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        
        animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = offsets
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
}
