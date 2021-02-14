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
    case vertical
  }
  
  func present(
    _ viewController: InsetPresentable,
    interactiveDismissalType: InteractiveDismissalType,
    insets: UIEdgeInsets = .zero,
    cornerRadius: CGFloat = .zero,
    completion: (() -> Void)? = nil
  ) {
    let interactionController: InteractionControlling?
    switch interactiveDismissalType {
    case .none:
      interactionController = nil
    case .vertical:
      interactionController = InsetInteractionController(viewController: viewController)
    }
    
    let transitionManager = InsetTransitionController(
      interactionController: interactionController,
      insets: insets,
      cornerRadius: cornerRadius
    )
    viewController.transitionController = transitionManager
    viewController.transitioningDelegate = transitionManager
    viewController.modalPresentationStyle = .custom
    
    present(viewController, animated: true, completion: completion)
  }
}
