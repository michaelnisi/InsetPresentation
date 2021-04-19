import UIKit

class InsetPresentationController: UIPresentationController {
  var insets: UIEdgeInsets = .zero
  var cornerRadius: CGFloat = .zero
  
  lazy var dimming: UIView = {
    let dimming = UIView()
    dimming.translatesAutoresizingMaskIntoConstraints = false
    dimming.backgroundColor = UIColor.black.withAlphaComponent(0.33)
    dimming.alpha = 0
    
    return dimming
  }()
  
  lazy var tapGesture: UITapGestureRecognizer = {
    UITapGestureRecognizer(target: self, action: #selector(onContainerViewTap))
  }()
  
  @objc private func onContainerViewTap() {
    presentedViewController.dismiss(animated: true)
  }
}

extension InsetPresentationController {
    func addDimmingTapGesture() {
        dimming.addGestureRecognizer(tapGesture)
    }
}

extension InsetPresentationController {
  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else {
      return
    }
    
    containerView.insertSubview(dimming, at: 0)
    
    NSLayoutConstraint.activate([
      dimming.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      dimming.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      dimming.topAnchor.constraint(equalTo: containerView.topAnchor),
      dimming.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
    
    guard let coordinator = presentedViewController.transitionCoordinator else {
      return dimming.alpha = 1
    }
    
    coordinator.animate { _ in
      self.dimming.alpha = 1
    }
  }
  
  override func dismissalTransitionWillBegin() {
    defer {
      dimming.removeGestureRecognizer(tapGesture)
    }
    
    guard let coordinator = presentedViewController.transitionCoordinator else {
      return dimming.alpha = 0
    }
    
    if !coordinator.isInteractive {
      coordinator.animate { _ in
        self.dimming.alpha = 0
      }
    }
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
    presentedView?.layer.cornerRadius = cornerRadius
    presentedView?.layer.masksToBounds = true
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = containerView else {
      return .zero
    }
    
    let safeAreaFrame = containerView.bounds
    
    let targetSize = CGSize(
      width: safeAreaFrame.width - insets.left - insets.right,
      height: UIScreen.main.bounds.height - insets.top - insets.bottom
    )
    
    var frame = safeAreaFrame
    frame.origin.x += insets.left
    frame.origin.y += insets.top
    frame.size.width = targetSize.width
    frame.size.height = targetSize.height + 20
    
    return frame
  }
}
