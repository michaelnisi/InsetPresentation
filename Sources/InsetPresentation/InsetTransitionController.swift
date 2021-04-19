import UIKit

class InsetTransitionController: NSObject {
  private var interactionController: InteractionControlling?
  private let insets: UIEdgeInsets
  private let cornerRadius: CGFloat
  
  init(
    interactionController: InteractionControlling?,
    insets: UIEdgeInsets = .zero,
    cornerRadius: CGFloat = .zero
  ) {
    self.interactionController = interactionController
    self.insets = insets
    self.cornerRadius = cornerRadius
  }
}

extension InsetTransitionController: UIViewControllerTransitioningDelegate {
  
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    let controller = InsetPresentationController(presentedViewController: presented, presenting: presenting)
    controller.insets = insets
    controller.cornerRadius = cornerRadius

    if interactionController != nil {
        controller.addDimmingTapGesture()
    }
    
    return controller
  }
  
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    InsetTransitionAnimator(presenting: true)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    InsetTransitionAnimator(presenting: false)
  }
  
  func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    guard let interactionController = interactionController, interactionController.interactionInProgress else {
      return nil
    }
    return interactionController
  }
}
