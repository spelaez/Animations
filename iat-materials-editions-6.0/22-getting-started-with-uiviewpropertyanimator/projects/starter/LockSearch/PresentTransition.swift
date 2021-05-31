//
//  PresentTransition.swift
//  Widgets
//
//  Created by Santiago Pelaez Rua on 22/02/21.
//  Copyright © 2021 Underplot ltd. All rights reserved.
//

import UIKit

class PresentTransition: UIPercentDrivenInteractiveTransition,
                         UIViewControllerAnimatedTransitioning {
  var auxAnimations: (() -> Void)?
  var animator: UIViewPropertyAnimator?
  var context: UIViewControllerContextTransitioning?
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.75
  }
  
  func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    return animator ?? transitionAnimator(using: transitionContext)
  }
  
  func transitionAnimator(using transitionContext:
                            UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    let duration = transitionDuration(using: transitionContext)
    let container = transitionContext.containerView
    let to = transitionContext.view(forKey: .to)!
    
    container.addSubview(to)
    
    to.transform = CGAffineTransform(scaleX: 1.33, y: 1.33)
      .concatenating(CGAffineTransform(translationX: 0.0, y: 30.0))
    to.alpha = 0
    
    let animator = UIViewPropertyAnimator(duration: duration,
                                          curve: .easeOut)
    
    animator.addAnimations({
      to.transform = CGAffineTransform(translationX: 0.0, y: 20)
    },
    delayFactor: 0.15)
    
    animator.addAnimations({
      to.alpha = 1.0
    }, delayFactor: 0.5)
    
    if let auxAnimations = auxAnimations {
      animator.addAnimations(auxAnimations)
    }
    
    animator.addCompletion { position in
      switch position {
      case .end:
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      default:
        transitionContext.completeTransition(false)
      }
    }
    
    animator.addCompletion { [unowned self] _ in
      self.animator = nil
    }
    
    self.animator = animator
    self.context = transitionContext
    
    animator.isUserInteractionEnabled = true
    
    return animator
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    transitionAnimator(using: transitionContext).startAnimation()
  }
  
  func interruptTransition() {
    guard let context = context else {
      return
    }
    
    context.pauseInteractiveTransition()
    pause()
  }
}
