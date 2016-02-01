//
//  CustomViewController.swift
//  Gulps
//
//  Created by Ross Gibson on 01/02/2016.
//  Copyright © 2016 Fancy Pixel. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var customPortionText: UITextField!
    @IBOutlet weak var unitOfMesureLabel: UILabel!
    
    var gulpSize: ((value: String) -> ())?
    
    private let userDefaults = NSUserDefaults.groupUserDefaults()
    
    private let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        customPortionText.inputAccessoryView = Globals.numericToolbar(customPortionText,
            selector: Selector("resignFirstResponder"),
            barColor: .mainColor(),
            textColor: .whiteColor())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        customPortionText.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        dismissAddingGulp(false)
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        dismissAddingGulp(true)
    }
    
    // MARK: - Notifications
    
    func keyboardWillHide(notification: NSNotification) {
        dismissAddingGulp(true)
    }
    
    // MARK: - Private
    
    private func updateUI() {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        var suffix = ""
        if let unit = Constants.UnitsOfMeasure(rawValue: userDefaults.integerForKey(Constants.General.UnitOfMeasure.key())) {
            suffix = unit.suffixForUnitOfMeasure()
        }
        
        unitOfMesureLabel.text = suffix
        
        customPortionText.text = numberFormatter.stringFromNumber(userDefaults.doubleForKey(Constants.Gulp.Custom.key()))
    }
    
    private func dismissAddingGulp(save: Bool) {
        self.dismissViewControllerAnimated(save, completion: {
            if save {
                self.gulpSize?(value: Constants.Gulp.Custom.key())
            }
        })
    }
}

extension CustomViewController : UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == customPortionText) {
            storeText(customPortionText, toKey: Constants.Gulp.Custom.key())
        }
    }
    
    func storeText(textField: UITextField, toKey key: String) {
        guard let text = textField.text else {
            return
        }
        
        let number = numberFormatter.numberFromString(text) as? Double
        userDefaults.setDouble(number ?? 0.0, forKey: key)
        userDefaults.synchronize()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Globals.numericTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
