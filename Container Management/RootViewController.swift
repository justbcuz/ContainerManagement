//
//  RootViewController.swift
//  Container Management
//
//  Created by Justin Leger on 6/6/21.
//

import UIKit

enum RootSegueIdentifiers: String {
    case launchScreen           = "ReuseLaunchScreenSegue"
    case navigationTableView    = "NavigationTableViewSegue"
    case red                    = "RedSegue"
    case green                  = "GreenSegue"
    case blue                   = "BlueSegue"
}

class RootViewController: UIViewController {
    
    var containerViewController : ContainerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        CVC_ANIMATE_ALL_TRANSITIONS = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.containerViewController?.performSegue(withIdentifier: RootSegueIdentifiers.navigationTableView.rawValue, sender: nil)
        }
        
        // Force the Error
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.001) {
            self.containerViewController?.performSegue(withIdentifier: RootSegueIdentifiers.red.rawValue, sender: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.002) {
            self.containerViewController?.performSegue(withIdentifier: RootSegueIdentifiers.green.rawValue, sender: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.003) {
            self.containerViewController?.performSegue(withIdentifier: RootSegueIdentifiers.blue.rawValue, sender: nil)
        }
    }
    
    // This sets up the initial ContainerViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let containerViewController as ContainerViewController:
            
            self.containerViewController = containerViewController
            self.containerViewController?.delegate = self
            
            self.containerViewController?.performSegue(withIdentifier: RootSegueIdentifiers.launchScreen.rawValue, sender: nil)
            
        default:
            break
        }
    }
}

extension RootViewController: ContainerViewControllerDelegate {

    func containerView(_ containerView: ContainerViewController, willSegue segue: UIStoryboardSegue) {

        switch segue.destination {
        
        case let navigationTableViewController as NavigationTableViewController:
            break
            
        case let redViewController as RedViewController:
            break
            
        case let greenViewController as GreenViewController:
            break
            
        case let blueViewController as BlueViewController:
            break
                
        default:
            print("***** Unknown segue.destination class type :: \(segue.destination.debugDescription).")
        }
    }
}

class NavigationTableViewController: UINavigationController {
    // Nothing but type capturing for this example.
}

class RedViewController: UIViewController {
    // Nothing but type capturing for this example.
}

class GreenViewController: UIViewController {
    // Nothing but type capturing for this example.
}

class BlueViewController: UIViewController {
    // Nothing but type capturing for this example.
}
