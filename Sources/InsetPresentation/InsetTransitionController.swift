import UIKit

class InsetTransitionController: NSObject {

    private var interactionController: InteractionControlling?

    init(interactionController: InteractionControlling?) {
        self.interactionController = interactionController
    }
}

extension InsetTransitionController: UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        InsetPresentationController(presentedViewController: presented, presenting: presenting)
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
