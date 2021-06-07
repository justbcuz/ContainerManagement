//
//  ContainerViewController.swift
//
//  Created by Justin Léger on 2/4/18.
//

// Originally inspired from: https://github.com/mluton/EmbeddedSwapping

import UIKit

// Update Container View Controller global variable
// to disable view controller swap animation.
var CVC_ANIMATE_VIEW_CONTROLLER_SWAP: Bool = true

class ContainerViewController: UIViewController {
     
    weak public var delegate: ContainerViewControllerDelegate?
    
    var defaultSegueIdentifier: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let defaultSegueIdentifier = defaultSegueIdentifier {
            performSegue(withIdentifier: defaultSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        willSegueHandler?(segue)
        delegate?.containerView(self, willSegue: segue)
        
        swap(toViewController: segue.destination)
    }
    
    private var willSegueHandler: ((UIStoryboardSegue) -> ())?
    
    func performSegue(withIdentifier identifier: String, sender: Any?, willSegueHandler: ((UIStoryboardSegue) -> ())?) {
        self.willSegueHandler = willSegueHandler
        performSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    
        guard let shouldPerformSegue = delegate?.containerView(self, shouldPerformSegueWithIdentifier: identifier, sender: sender) else {
            return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        }
        
        return shouldPerformSegue
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        let canPerformSegue = self.canPerformSegue(withIdentifier: identifier)
        let shouldPerformSegue = self.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        
        if !canPerformSegue {
            print("***** ERROR :: Segue with Identifier '\(identifier)' does not exist!")
        } else if !shouldPerformSegue {
            print("***** NOTE :: Segue with Identifier '\(identifier)' being block by shouldPerformSegue")
        } else {
            super.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    func swap(toViewController destination: UIViewController) {
        
        destination.parentContainerViewController = self
        
        destination.view.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        
        if !children.isEmpty {
            swapFromViewController(fromViewController: children[0], toViewController: destination, offset: 0.0)
        } else {
            swapFromViewController(fromViewController: nil, toViewController: destination, offset: 0.0)
        }
    }
    
    private func swapFromViewController(fromViewController: UIViewController?, toViewController: UIViewController, offset: CGFloat) -> Void {
        
        delegate?.containerView(self, willSwapFromViewController: fromViewController, toViewController: toViewController)
        
        if let fromViewController = fromViewController {
            
            // FIXME: There seems to be times this breaks when called multiple times during animation sequence.
            
            if CVC_ANIMATE_VIEW_CONTROLLER_SWAP {

                // This section seems to fail when animation is interrupted. Maybe?
                
                fromViewController.willMove(toParent: nil)
                addChild(toViewController)

                transition(from: fromViewController, to: toViewController, duration: 1.0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                    // Nothing to do but read that the animation block was necessary
                    // See Bullet 3. https://stackoverflow.com/a/48369709
                }) { (finished) in
                    fromViewController.removeFromParent()
                    fromViewController.view.removeFromSuperview()
                    toViewController.didMove(toParent: self)
                    
                    self.delegate?.containerView(self, didSwapFromViewController: fromViewController, toViewController: toViewController)
                }
                
            } else {
                
                // This Section seem to make it work, but no animation transition.
                
                fromViewController.willMove(toParent: nil)
                fromViewController.view.removeFromSuperview()
                fromViewController.removeFromParent()

                addChild(toViewController)
                view.addSubview(toViewController.view)
                toViewController.didMove(toParent: self)
                
                delegate?.containerView(self, didSwapFromViewController: fromViewController, toViewController: toViewController)
            }
            
        } else {
            addChild(toViewController)
            view.addSubview(toViewController.view)
            toViewController.didMove(toParent: self)
            
            delegate?.containerView(self, didSwapFromViewController: fromViewController, toViewController: toViewController)
        }
    }
    
}

protocol ContainerViewControllerDelegate: class {
    
    func containerView(_ containerView: ContainerViewController, willSegue segue: UIStoryboardSegue) -> Swift.Void // Optional
    func containerView(_ containerView: ContainerViewController, shouldPerformSegueWithIdentifier identifier: String, sender: Any?) -> Bool // Optional
    
    func containerView(_ containerView: ContainerViewController, willSwapFromViewController fromViewController: UIViewController?, toViewController: UIViewController?) -> Swift.Void // Optional
    func containerView(_ containerView: ContainerViewController, didSwapFromViewController fromViewController: UIViewController?, toViewController: UIViewController?) -> Swift.Void // Optional
    
}

extension ContainerViewControllerDelegate {
    
    // Make Optional
    // Stub functions so this can be optional in the class designated as delegates
    
    func containerView(_ containerView: ContainerViewController, willSegue segue: UIStoryboardSegue) -> Swift.Void {}
    func containerView(_ containerView: ContainerViewController, shouldPerformSegueWithIdentifier identifier: String, sender: Any?) -> Bool { return true }
    
    func containerView(_ containerView: ContainerViewController, willSwapFromViewController fromViewController: UIViewController?, toViewController: UIViewController?) -> Swift.Void {}
    func containerView(_ containerView: ContainerViewController, didSwapFromViewController fromViewController: UIViewController?, toViewController: UIViewController?) -> Swift.Void {}
}

extension UIViewController {
    
    /**
     Checks whether controller can perform specific segue or not.
     - parameter identifier: Identifier of UIStoryboardSegue.
     */
    func canPerformSegue(withIdentifier identifier: String) -> Bool {
        //first fetch segue templates set in storyboard.
        guard let identifiers = value(forKey: "storyboardSegueTemplates") as? [NSObject] else {
            //if cannot fetch, return false
            return false
        }
        //check every object in segue templates, if it has a value for key _identifier equals your identifier.
        let canPerform = identifiers.contains { (object) -> Bool in
            if let id = object.value(forKey: "_identifier") as? String {
                if id == identifier{
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        return canPerform
    }
}

extension UIViewController {
    
    private struct AssociatedObjectKeys {
        static var ParentContainerViewController = "nsh_ParentContainerViewControllerAssociatedObjectKey"
    }
    
    public weak var parentContainerViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.ParentContainerViewController) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.ParentContainerViewController, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
