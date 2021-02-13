import UIKit

class InsetPresentationController: UIPresentationController {
    var insets = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
    var cornerRadius: CGFloat = 0

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
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        containerView.insertSubview(dimming, at: 0)
        containerView.addGestureRecognizer(tapGesture)

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
            containerView?.removeGestureRecognizer(tapGesture)
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
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        let safeAreaFrame = containerView.bounds

        let targetSize = CGSize(
            width: safeAreaFrame.width,
            height: UIScreen.main.bounds.height - insets.top
        )

        var frame = safeAreaFrame
        frame.origin.x += 0
        frame.origin.y += insets.top
        frame.size.width = targetSize.width
        frame.size.height = targetSize.height

        return frame
    }
}
