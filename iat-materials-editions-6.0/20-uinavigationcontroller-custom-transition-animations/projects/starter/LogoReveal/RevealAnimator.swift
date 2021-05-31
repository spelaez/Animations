//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by Santiago Pelaez Rua on 8/02/21.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    var interactive = false
    let animationDuration = 1.0
    var operation = UINavigationController.Operation.push
    weak var storedContext: UIViewControllerContextTransitioning?
    
    private var pausedTime: CFTimeInterval = 0
    private var isLayerBased: Bool {
        return operation == .push
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view!.superview!)
        var progress: CGFloat = abs(translation.x / 200.0)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
        case .changed:
            update(progress)
        case .cancelled, .ended:
            if progress < 0.5 {
                cancel()
            } else {
                finish()
            }
            
            interactive = false
        default:
            break
        }
    }
    
    override func cancel() {
        if isLayerBased {
            restart(forFinishing: false)
        }
        super.cancel()
    }
    
    override func finish() {
        if isLayerBased {
            restart(forFinishing: true)
        }
        super.finish()
    }
    
    private func restart(forFinishing: Bool) {
        let transitionLayer = storedContext?.containerView.layer
        transitionLayer?.beginTime = CACurrentMediaTime()
        transitionLayer?.speed = forFinishing ? 1 : -1
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        if isLayerBased {
            let animationProgress = TimeInterval(animationDuration) * TimeInterval(percentComplete)
            storedContext?.containerView.layer.timeOffset = pausedTime + animationProgress
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if interactive && isLayerBased {
            let transitionLayer = transitionContext.containerView.layer
            pausedTime = transitionLayer.convertTime(CACurrentMediaTime(), from: nil)
            transitionLayer.speed = 0
            transitionLayer.timeOffset = pausedTime
        }
        
        storedContext = transitionContext
        
        if operation == .push {
            
            let fromVC = transitionContext.viewController(forKey: .from) as! MasterViewController
            let toVC = transitionContext.viewController(forKey: .to) as! DetailViewController
            
            transitionContext.containerView.addSubview(toVC.view)
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            animation.toValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, -10.0, 0.0),
                                                                           CATransform3DMakeScale(150.0, 150.0, 1.0)))
            animation.duration = animationDuration
            animation.delegate = self
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            let fadeIn = CABasicAnimation(keyPath: "opacity")
            fadeIn.fromValue = 0
            fadeIn.toValue = 1
            fadeIn.duration = animationDuration
            
            
            let maskLayer = RWLogoLayer.logoLayer()
            maskLayer.position = fromVC.logo.position
            toVC.view.layer.mask = maskLayer
            
            maskLayer.add(animation, forKey: nil)
            fromVC.logo.add(animation, forKey: nil)
            toVC.view.layer.add(fadeIn, forKey: nil)
        } else {
            let fromView = transitionContext.view(forKey: .from)!
            let toView = transitionContext.view(forKey: .to)!
            
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            
            UIView.animate(withDuration: animationDuration) {
                fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            context.completeTransition(!context.transitionWasCancelled)
            let fromVC = context.viewController(forKey: .from) as! MasterViewController
            
            fromVC.logo.removeAllAnimations()
            let toVC = context.viewController(forKey: .to) as! DetailViewController
            toVC.view.layer.mask = nil
        }
        storedContext = nil
    }
}
