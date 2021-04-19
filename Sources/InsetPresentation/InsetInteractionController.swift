import UIKit

class InsetInteractionController: NSObject, InteractionControlling {
  var interactionInProgress = false
  private weak var viewController: InsetPresentable!
  private weak var transitionContext: UIViewControllerContextTransitioning?
  private var interactionDistance: CGFloat = 0
  private var interruptedTranslation: CGFloat = 0
  private var presentedFrame: CGRect?
  private var cancellationAnimator: UIViewPropertyAnimator?
  
  lazy var panGesture: VerticalPanGesture = {
    VerticalPanGesture(target: self, action: #selector(onPan(_:)))
  }()
  
  init(viewController: InsetPresentable) {
    self.viewController = viewController
    
    super.init()
    addGestureRecognizers(in: viewController.view)
  }
}

// MARK: - Gestures

extension InsetInteractionController {
  private func addGestureRecognizers(in view: UIView) {
    view.addGestureRecognizer(panGesture)
  }
  
  private func removeGestureRecognizers(in view: UIView) {
    view.removeGestureRecognizer(panGesture)
  }
  
  @objc func onPan(_ gestureRecognizer: VerticalPanGesture) {
    guard let superview = gestureRecognizer.view?.superview else {
      return
    }
    
    let translation = gestureRecognizer.translation(in: superview).y
    let velocity = gestureRecognizer.velocity(in: superview).y
    
    switch gestureRecognizer.state {
    case .began:
      gestureBegan()
      
    case .changed:
      gestureChanged(translation: translation + interruptedTranslation, velocity: velocity)
      
    case .cancelled:
      gestureCancelled(translation: translation + interruptedTranslation, velocity: velocity)
      
    case .ended:
      gestureEnded(translation: translation + interruptedTranslation, velocity: velocity)
      
    default:
      break
    }
  }
  
  private func gestureBegan() {
    disableOtherTouches()
    cancellationAnimator?.stopAnimation(true)
    
    if let presentedFrame = presentedFrame {
      interruptedTranslation = viewController.view.frame.minY - presentedFrame.minY
    }
    
    if !interactionInProgress {
      interactionInProgress = true
      
      viewController.dismiss(animated: true)
    }
  }
  
  private func gestureChanged(translation: CGFloat, velocity: CGFloat) {
    var progress = interactionDistance == 0 ? 0 : (translation / interactionDistance)
    if progress < 0 {
      progress /= (1.0 + abs(progress * 20))
    }
    
    update(progress: progress)
  }
  
  private func gestureCancelled(translation: CGFloat, velocity: CGFloat) {
    cancel(initialSpringVelocity: makeSpringVelocity(distanceToTravel: -translation, gestureVelocity: velocity))
  }
  
  private func gestureEnded(translation: CGFloat, velocity: CGFloat) {
    if velocity > 300 || (translation > interactionDistance / 2.0 && velocity > -300) {
      let v = makeSpringVelocity(
        distanceToTravel: interactionDistance - translation,
        gestureVelocity: velocity
      )
      
      finish(initialSpringVelocity: v)
    } else {
      let v = makeSpringVelocity(
        distanceToTravel: -translation,
        gestureVelocity: velocity
      )
      
      cancel(initialSpringVelocity: v)
    }
  }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension InsetInteractionController {
  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    let presentedViewController = transitionContext.viewController(forKey: .from)!
    presentedFrame = transitionContext.finalFrame(for: presentedViewController)
    self.transitionContext = transitionContext
    interactionDistance = transitionContext.containerView.bounds.height - presentedFrame!.minY
  }
  
  func update(progress: CGFloat) {
    guard let transitionContext = transitionContext,
          let presentedFrame = presentedFrame else {
      return
    }
    
    transitionContext.updateInteractiveTransition(progress)
    let presentedViewController = transitionContext.viewController(forKey: .from)!
    presentedViewController.view.frame = CGRect(
      x: presentedFrame.minX,
      y: presentedFrame.minY + interactionDistance * progress,
      width: presentedFrame.width,
      height: presentedFrame.height
    )
    
    if let modalPresentationController = presentedViewController.presentationController as? InsetPresentationController {
      modalPresentationController.dimming.alpha = 1.0 - progress
    }
  }
  
  func cancel(initialSpringVelocity: CGFloat) {
    guard let transitionContext = transitionContext,
          let presentedFrame = presentedFrame else {
      return
    }
    
    let presentedViewController = transitionContext.viewController(forKey: .from)!
    
    let timingParameters = UISpringTimingParameters(
      dampingRatio: 0.8,
      initialVelocity: CGVector(dx: 0, dy: initialSpringVelocity)
    )
    cancellationAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)
    
    cancellationAnimator?.addAnimations {
      presentedViewController.view.frame = presentedFrame
      if let modalPresentationController = presentedViewController.presentationController as? InsetPresentationController {
        modalPresentationController.dimming.alpha = 1.0
      }
    }
    
    cancellationAnimator?.addCompletion { _ in
      transitionContext.cancelInteractiveTransition()
      transitionContext.completeTransition(false)
      
      self.interactionInProgress = false
      
      self.enableOtherTouches()
    }
    
    cancellationAnimator?.startAnimation()
  }
  
  func finish(initialSpringVelocity: CGFloat) {
    guard let transitionContext = transitionContext,
          let presentedFrame = presentedFrame else {
      return
    }
    
    let presentedViewController = transitionContext.viewController(forKey: .from) as! InsetPresentable
    let dismissedFrame = CGRect(
      x: presentedFrame.minX,
      y: transitionContext.containerView.bounds.height,
      width: presentedFrame.width,
      height: presentedFrame.height
    )
    
    let timingParameters = UISpringTimingParameters(
      dampingRatio: 0.8,
      initialVelocity: CGVector(dx: 0, dy: initialSpringVelocity)
    )
    let finishAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timingParameters)
    
    finishAnimator.addAnimations {
      presentedViewController.view.frame = dismissedFrame
      if let modalPresentationController = presentedViewController.presentationController as? InsetPresentationController {
        modalPresentationController.dimming.alpha = 0.0
      }
    }
    
    finishAnimator.addCompletion { _ in
      transitionContext.finishInteractiveTransition()
      transitionContext.completeTransition(true)
      self.interactionInProgress = false
      self.removeGestureRecognizers(in: presentedViewController.view)
    }
    
    finishAnimator.startAnimation()
  }
  
  private func disableOtherTouches() {
    viewController.view.subviews.forEach {
      $0.isUserInteractionEnabled = false
    }
  }
  
  private func enableOtherTouches() {
    viewController.view.subviews.forEach {
      $0.isUserInteractionEnabled = true
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension InsetInteractionController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    true
  }
}

// MARK: - Factory

extension InsetInteractionController {
  private func makeSpringVelocity(distanceToTravel: CGFloat, gestureVelocity: CGFloat) -> CGFloat {
    distanceToTravel == 0 ? 0 : gestureVelocity / distanceToTravel
  }
}
