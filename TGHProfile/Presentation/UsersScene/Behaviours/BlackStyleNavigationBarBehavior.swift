//
//  BlackStyleNavigationBarBehavior.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import UIKit

struct BlackStyleNavigationBarBehavior: ViewControllerLifecycleBehavior {

    func viewDidLoad(viewController: UIViewController) {

        viewController.navigationController?.navigationBar.barStyle = .black
    }
}
