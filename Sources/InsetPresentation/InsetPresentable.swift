import UIKit

public protocol InsetPresentable: UIViewController {
  var transitionController: UIViewControllerTransitioningDelegate? { get set }
  func updatePresentationLayout(animated: Bool)
}

public extension InsetPresentable {
  func updatePresentationLayout(animated: Bool = false) {
    if animated {
      UIView.animate(
        withDuration: 0.3,
        delay: 0.0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 0.0,
        options: .allowUserInteraction,
        animations: { [weak self] in
          self?.presentationController?.containerView?.layoutIfNeeded()
        },
        completion: nil
      )
    } else {
      presentationController?.containerView?.layoutIfNeeded()
    }
  }
}

protocol InteractionControlling: UIViewControllerInteractiveTransitioning {
  var interactionInProgress: Bool { get }
}

public extension UIViewController {
  enum InteractiveDismissalType {
    case none
    case standard
  }
  
  func present(
    _ viewController: InsetPresentable,
    interactiveDismissalType: InteractiveDismissalType,
    completion: (() -> Void)? = nil
  ) {
    let interactionController: InteractionControlling?
    switch interactiveDismissalType {
    case .none:
      interactionController = nil
    case .standard:
      interactionController = InsetInteractionController(viewController: viewController)
    }
    
    let transitionManager = InsetTransitionController(interactionController: interactionController)
    viewController.transitionController = transitionManager
    viewController.transitioningDelegate = transitionManager
    viewController.modalPresentationStyle = .custom
    
    present(viewController, animated: true, completion: completion)
  }
}
