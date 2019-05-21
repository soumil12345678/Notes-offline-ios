//
//  Theme.swift
//  Notes
//
//  Created by Soumil on 07/05/19.
//  Copyright © 2019 LPTP233. All rights reserved.
//

import UIKit

public enum theme: String {
    case light
    case dark
    
    var textColor: UIColor {
        switch self {
        case .light:
            return .black
        case .dark:
            return .orange
        }
    }
    var superViewColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return .black
        }
    }
    
    var subViewColor: UIColor {
        switch self {
        case .light:
            return .clear
        case .dark:
            return .clear
        }
    }
    
    var subViewBorderColor: CGColor {
        switch self {
        case .light:
            return UIColor.blue.cgColor
        case .dark:
            return UIColor.blue.cgColor
        }
    }
    
    var seperatorColor: CGColor {
        switch self {
        case .light:
            return UIColor.blue.cgColor
        case .dark:
            return UIColor.white.cgColor
        }
    }
}

public var currentTheme: theme = .light

public extension UITextField {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
        self.textColor = currentTheme.textColor
        self.layer.borderColor = currentTheme.subViewBorderColor
        self.attributedPlaceholder = NSAttributedString(string: "Enter file name", attributes: [NSAttributedString.Key.foregroundColor: currentTheme.textColor])
    }
}

public extension UITextView {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
        self.textColor = currentTheme.textColor
        self.layer.borderColor = currentTheme.subViewBorderColor
    }
}

public extension UITableViewCell {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
        self.textLabel?.textColor = currentTheme.textColor
    }
}

public extension UITableView {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
    }
}

public extension UICollectionViewCell {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
    }
}

public extension UICollectionView {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
    }
}

public extension UILabel {
    func applyTheme() {
        self.backgroundColor = currentTheme.subViewColor
        self.textColor = currentTheme.textColor
    }
}


