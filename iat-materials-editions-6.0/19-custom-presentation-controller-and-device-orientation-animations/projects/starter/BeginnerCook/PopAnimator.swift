//
//  PopAnimator.swift
//  BeginnerCook
//
//  Created by Santiago Pelaez Rua on 29/01/21.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    var dismissCompletion: (() -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let herbViewController = transitionContext.viewController(forKey: presenting ? .to: .from) as? HerbDetailsViewController
        let herbView = herbViewController!.view!
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(x: initialFrame.midX,
                                      y: initialFrame.midY)
            herbView.clipsToBounds = true
            herbViewController?.containerView.alpha = 0.0
            herbView.layer.cornerRadius = 20/xScaleFactor
        }
        
        if let toView = transitionContext.view(forKey: .to) {
            containerView.addSubview(toView)
        }
        containerView.bringSubviewToFront(herbView)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.0) {
            herbView.transform = self.presenting ? .identity : scaleTransform
            herbView.center = CGPoint(x: finalFrame.midX,
                                      y: finalFrame.midY)
            
            herbViewController?.containerView.alpha = self.presenting ? 1.0 : 0.0
            
        } completion: { _ in
            if !self.presenting {
                self.dismissCompletion?()
            } else {
            }
            transitionContext.completeTransition(true)
        }
        

        let roundCorners = CABasicAnimation(keyPath: "cornerRadius")
        roundCorners.duration = duration / 2
        if presenting {
            roundCorners.fromValue = CGFloat(20.0/xScaleFactor)
            roundCorners.toValue = CGFloat(0.0)
        } else {
            roundCorners.fromValue = CGFloat(0.0)
            roundCorners.toValue = CGFloat(20.0/xScaleFactor)
        }
        
        herbView.layer.add(roundCorners, forKey: nil)
    }
}
