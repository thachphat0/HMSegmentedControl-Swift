//
//  HMSegmentedControl+String.swift
//  Pods
//
//  Created by Phat Chiem on 9/16/17.
//
//

import Foundation

extension String {
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
