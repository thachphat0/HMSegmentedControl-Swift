//
//  ViewController.swift
//  HMSegmentedControl
//
//  Created by Hesham Abd-Elmegid on 8/24/16.
//  Copyright © 2016 Tinybits. All rights reserved.
//

import UIKit
import HMSegmentedControl_Swift

class ViewController: UIViewController {
    let segmentedControl = HMSegmentedControl(items: ["One", "Two", "Three", "fouraaaaa", "five"])
    
    override func viewDidLoad() {
        view.addSubview(segmentedControl)
        
        segmentedControl.backgroundColor = #colorLiteral(red: 0.7683569193, green: 0.9300123453, blue: 0.9995251894, alpha: 1)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectionIndicatorPosition = .bottom
        segmentedControl.selectionIndicatorColor = #colorLiteral(red: 0.1142767668, green: 0.3181744218, blue: 0.4912756383, alpha: 1)
//        segmentedControl.allowSelectLargerIndexThanCurrent = false
        segmentedControl.oldIndexImage = #imageLiteral(resourceName: "ic_tick")
        segmentedControl.selectionIndicatorWidthStyle = .dynamic
        
        segmentedControl.titleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            NSFontAttributeName : UIFont.systemFont(ofSize: 17)
        ]
        
        segmentedControl.selectedTitleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 0.05439098924, green: 0.1344551742, blue: 0.1884709597, alpha: 1),
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17)
        ]
        
        segmentedControl.indexChangedHandler = { index in
            print(index)
            //            print(self.segmentedControl.selectedSegmentIndex)
            //            self.segmentedControl.selectedSegmentIndex = 1
        }
        
        NSLayoutConstraint.activate(
            [segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor),
             segmentedControl.heightAnchor.constraint(equalToConstant: 50),
             segmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor),
             segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 40)]
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentedControl.setSelectedSegmentIndex(2, animated: false)
    }
    
    @IBAction func nextButtonTapped() {
        segmentedControl.setSelectedSegmentIndex(segmentedControl.selectedSegmentIndex + 1, animated: true)
    }
    
}

