//
//  HMSegmentedControl.swift
//  HMSegmentedControl
//
//  Created by Hesham Abd-Elmegid on 8/24/16.
//  Copyright © 2016 Tinybits. All rights reserved.
//

import UIKit

// TODO:
//  * Add IBInspectable stuff
//  * UIAppearance support
//  * Set proper access control for propeties and functions
//  * Add scroll view
//  * Ability to add and remove items after initialization
//  * Add delegate callback to configure each button for a state (method should have index, state and button)
//  * Move selection indicator to its own private class with all of its properties

public class HMSegmentedControl: UIControl {
    public enum SelectionIndicatorPosition {
        case top
        case bottom
    }
    
    public enum SelectionIndicatorWidthStyle {
        case dynamic // Selection indicator is equal to the segment's label width.
        case fixed // Selection indicator is equal to the full width of the segment.
    }
    
    var scrollView = UIScrollView()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        
        return stackView
    }()
    
    lazy var selectionIndicator: UIView = {
        let selectionIndicator = UIView()
        selectionIndicator.backgroundColor = self.selectionIndicatorColor
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        return selectionIndicator
    }()
    
    var selectionIndicatorLeadingConstraint: NSLayoutConstraint?
    var selectionIndicatorWidthConstraint: NSLayoutConstraint?
    public var items: [String]
    
    public var allowSelectLargerIndexThanCurrent = true
    public var oldIndexImage: UIImage?
    public var horizontalOffset: CGFloat = 0
    public var buttonHorizontalInset: CGFloat = 5
    
    /// Height of the selection indicator stripe.
    var selectionIndicatorHeight: CGFloat = 5.0
    
    public var selectionIndicatorWidthStyle: SelectionIndicatorWidthStyle = .fixed
    
    /// Position of the selection indicator stripe.
    public var selectionIndicatorPosition: SelectionIndicatorPosition = .bottom
    
    /// Color of the selection indicator stripe.
    public var selectionIndicatorColor: UIColor = .black {
        didSet {
            self.selectionIndicator.backgroundColor = selectionIndicatorColor
        }
    }
    
    /// Text attributes to apply to labels of the unselected segments
    public var titleTextAttributes: [NSAttributedStringKey: Any]? {
        didSet {
            if let titleTextAttributes = titleTextAttributes {
                set(titleAttributes: titleTextAttributes, forControlState: .normal)
            }
        }
    }
    
    /// Text attributes to apply to labels of the selected segments
    public var selectedTitleTextAttributes: [NSAttributedStringKey: Any]? {
        didSet {
            if let selectedTitleTextAttributes = selectedTitleTextAttributes {
                set(titleAttributes: selectedTitleTextAttributes, forControlState: .selected)
            }
        }
    }
    
    public var indexChangedHandler: ((_ index: Int) -> (Void))?
    public var selectedSegmentIndex: Int = 0 {
        didSet {
            for button in stackView.arrangedSubviews {
                if let button = button as? UIButton {
                    button.isSelected = false
                    
                    if let image = oldIndexImage {
                        if button.tag < selectedSegmentIndex {
                            button.setImage(image, for: .normal)
                        } else {
                            button.setImage(nil, for: .normal)
                        }
                    }
                }
            }
            
            let selectedButton = stackView.arrangedSubviews[selectedSegmentIndex] as! UIButton
            selectedButton.isSelected = true
            
            scrollView.scrollRectToVisible(selectedButton.frame, animated: true)
        }
    }
    
    public init(items: [String]) {
        self.items = items
        
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.items = []
        
        super.init(coder: aDecoder)
    }
    
    override public func updateConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            ])
        
        
        let selectionIndicatorPositionConstraint: NSLayoutConstraint
        
        if selectionIndicatorPosition == .top {
            selectionIndicatorPositionConstraint = selectionIndicator.topAnchor.constraint(equalTo: stackView.topAnchor)
        } else {
            selectionIndicatorPositionConstraint = selectionIndicator.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        }
        
        if selectionIndicatorWidthStyle == .dynamic {
            let button = stackView.arrangedSubviews[selectedSegmentIndex] as? UIButton
            
            if let titleLabel = button?.titleLabel {
                selectionIndicatorLeadingConstraint = selectionIndicator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
                selectionIndicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
            }
        } else {
            selectionIndicatorLeadingConstraint = selectionIndicator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
            selectionIndicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(items.count))
        }
        
        NSLayoutConstraint.activate([
            selectionIndicatorWidthConstraint!,
            selectionIndicator.heightAnchor.constraint(equalToConstant: selectionIndicatorHeight),
            selectionIndicatorPositionConstraint,
            selectionIndicatorLeadingConstraint!
            ])
        
        let font = (titleTextAttributes?[NSAttributedStringKey.font] ?? UIFont.systemFont(ofSize: 15)) as! UIFont
        
        let widths = items.map({ $0.width(withConstraintedHeight: 1, font: font) })
        
        let totalWidth = widths.reduce(0, +) + buttonHorizontalInset * 2 * CGFloat(widths.count)
        if totalWidth <= UIScreen.main.bounds.width - horizontalOffset * 2 {
            for (index, button) in stackView.arrangedSubviews.enumerated() {
                var width = widths[index] + buttonHorizontalInset * 2
                if let image = oldIndexImage {
                    width += image.size.width
                }
                button.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        } else {
            var maxWidth = widths.max() ?? 0
            if let image = oldIndexImage {
                maxWidth += image.size.width
            }
            for button in stackView.arrangedSubviews {
                button.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
            }
        }
        
        super.updateConstraints()
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(selectionIndicator)
        bringSubview(toFront: selectionIndicator)
        
        addButtons(forItems: items)
    }
    
    func addButtons(forItems items: [String]) {
        for (index, item) in items.enumerated() {
            let buttonView = button(forItem: item, atIndex: index)
            stackView.addArrangedSubview(buttonView)
        }
    }
    
    func button(forItem item: String, atIndex index: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(item, for: .normal)
        button.addTarget(self, action: #selector(HMSegmentedControl.tapped(segmentButton:)), for: .touchUpInside)
        
        if let titleTextAttributes = titleTextAttributes {
            let attributedTitle = NSAttributedString(string: item, attributes: titleTextAttributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
        } else {
            button.setTitleColor(.black, for: .normal)
        }
        
        if let selectedTitleTextAttributes = selectedTitleTextAttributes {
            let attributedTitle = NSAttributedString(string: item, attributes: selectedTitleTextAttributes)
            button.setAttributedTitle(attributedTitle, for: .selected)
        }
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5)
        button.tag = index
        return button
    }
    
    @objc func tapped(segmentButton sender: UIButton) {
        let newIndex = sender.tag
        
        if !allowSelectLargerIndexThanCurrent && newIndex > selectedSegmentIndex {
            return
        }
        
        let indexChanged: Bool = newIndex != selectedSegmentIndex
        selectedSegmentIndex = newIndex
        
        if let indexChangedHandler = indexChangedHandler, indexChanged == true {
            indexChangedHandler(selectedSegmentIndex)
        }
        
        setSelectedSegmentIndex(newIndex, animated: true)
    }
    
    func set(titleAttributes attributes: [NSAttributedStringKey: Any], forControlState state: UIControlState) {
        for button in stackView.arrangedSubviews {
            if let button = button as? UIButton, let title = button.title(for: state) {
                let attributedTitle = NSAttributedString(string: title, attributes: attributes)
                button.setAttributedTitle(attributedTitle, for: state)
            }
        }
    }
    
    /**
     Changes the currently selected segment index.
     
     - parameter index: Index of the segment to select.
     - parameter animated: A boolean to specify whether the change should be animated or not
     */
    open func setSelectedSegmentIndex(_ index: Int, animated: Bool) {
        assert(index < items.count, "Attempting to set index to a segment that does not exist.")
        
        selectedSegmentIndex = index
        
        if selectionIndicatorWidthStyle == .dynamic {
            let button = stackView.arrangedSubviews[selectedSegmentIndex] as? UIButton
            
            if let titleLabel = button?.titleLabel {
                removeConstraints([selectionIndicatorWidthConstraint!, selectionIndicatorLeadingConstraint!])
                
                selectionIndicatorLeadingConstraint = selectionIndicator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
                selectionIndicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
                
                NSLayoutConstraint.activate([selectionIndicatorWidthConstraint!, selectionIndicatorLeadingConstraint!])
            }
        } else {
            let segmentWidth = stackView.frame.size.width / CGFloat(items.count)
            selectionIndicatorLeadingConstraint?.constant = segmentWidth * CGFloat(index)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.layoutIfNeeded()
            })
        } else {
            self.layoutIfNeeded()
        }
    }
}
