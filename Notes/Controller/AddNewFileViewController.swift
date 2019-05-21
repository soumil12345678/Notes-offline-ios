//
//  AddNewFileViewController.swift
//  Notes
//
//  Created by Soumil on 25/04/19.
//  Copyright © 2019 LPTP233. All rights reserved.
//

import UIKit

class AddNewFileViewController: UIViewController {
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var contentTextView: UITextView!
    
    @IBOutlet weak var containerViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak private var contentTextViewBottomConst: NSLayoutConstraint!
    var saveButton: UIBarButtonItem!
    var textViewInteraction = 0
    var flagUpdate = 0
    var indexNo:Int?
    var isKeyboardVisible = 0
    var isSaved = 0
    var keyboardHeight: CGFloat = 0
    var optionsViewShow = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = currentTheme.superViewColor
        optionsView.backgroundColor = .yellow
        customizeTextView()
        customizeTextField()
        customizeNavBarButton()
        keyboardHandelar()
        settingTexts()
        optionButtonAction()
        nameTextField.zoom(x: 0.9 , y: 0.9)
        contentTextView.zoom(x: 0.9, y: 0.9)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if indexNo != nil {
            nameTextField.text = ""
            contentTextView.text = ""
        }
        UserDefaults.standard.set(nameTextField.text, forKey: "name")
        UserDefaults.standard.set(contentTextView.text, forKey: "content")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.contentTextViewBottomConst.constant = 10
            self.view.layoutIfNeeded()
        })
        return false
    }
    
    
    /* Description: Save Button Action
     - Parameter keys: sender
     - Returns: No Parameter
     */
    @objc func saveButtonAction(_ sender: UIBarButtonItem) {
        var name = nameTextField.text!
        if flagUpdate == 0 {
            if !checkforEmptyString(string:name) && !checkforEmptyString(string:contentTextView.text!) {
                if (name.first == " ") {
                    name.removeFirst()
                }
                if  DataOperations.shared.saveData(contentData: contentTextView.text!, nameData: name) {
                    alertPopUp(title: "Success", message: "File Saved", isSuccess: true)
                }else {
                    alertPopUp(title: "Failed", message: "Failed to save data. Try Again", isSuccess: false)
                }
            }
            else {
                alertPopUp(title: "Failed", message: "Please Enter a valid Name and Content of the File", isSuccess: false)
            }
        }
        else if (flagUpdate == 1) {
            if !checkforEmptyString(string:nameTextField.text!) && !checkforEmptyString(string:contentTextView.text!) && (contentTextView.text != "Enter the content here") {
                if (name.first == " ") {
                    name.removeFirst()
                }
                if  DataOperations.shared.updateData(name: name, content: contentTextView.text!, index: indexNo!) {
                    alertPopUp(title: "Success", message: "File Updated", isSuccess: true)
                }else {
                    alertPopUp(title: "Failed", message: "Failed to update data. Try Again", isSuccess: false)
                }
            }
            else {
                alertPopUp(title: "Failed", message: "Please Enter Name and Content of the File", isSuccess: false)
            }
        }
        saveButton.isEnabled = false
    }
    
    /* Description: Alert Pop Up Handler
     - Parameter keys: title, message, isSuccess
     - Returns: No Parameter
     */
    func alertPopUp(title: String, message: String, isSuccess: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if isSuccess {
            contentTextView.resignFirstResponder()
            nameTextField.resignFirstResponder()
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                self.contentTextView.text = ""
                self.nameTextField.text = ""
                self.navigationController?.popToRootViewController(animated: true)
            }))
        }else {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    /* Description: Enable Keyboard Action and getting keyboardHeight
     - Parameter keys: notification
     - Returns: No Parameter
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    /* Description: Dismiss Keyboard Action
     - Parameter keys: notification
     - Returns: No Parameter
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardVisible == 1 {
            if isKeyboardVisible == 1 {
                isKeyboardVisible = 0
                UIView.animate(withDuration: 0.5, animations: {
                    self.contentTextViewBottomConst.constant = 10
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    /* Description: Checking for white space in the string
     - Parameter keys: string
     - Returns: No Parameter
     */
    func checkforEmptyString(string: String) -> Bool{
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
//    MARK:- Customizing UI Elements
    func customizeTextView() {
        contentTextView.applyTheme()
        contentTextView.delegate = self
    }
    
    func customizeTextField() {
        nameTextField.delegate = self
        nameTextField.layer.borderWidth = 3
        contentTextView.layer.borderWidth = 3
        nameTextField.applyTheme()
    }
    
    func settingTexts() {
        if let index = indexNo {
            nameTextField.text = DataModel.shared.name[index]
            contentTextView.text = DataModel.shared.content[index]
        }
        else if let name = UserDefaults.standard.object(forKey: "name") as? String, name != "", let content = UserDefaults.standard.object(forKey: "content") as? String, content != "" {
            nameTextField.text = name
            contentTextView.text = content
        }else {
            contentTextView.text = "Enter the content here"
        }
    }
    
    func customizeNavBarButton() {
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonAction(_:)))
        let optionButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionButtonAction))
        self.navigationItem.rightBarButtonItems = [saveButton, optionButton]
        saveButton.isEnabled = false
    }
    
    @objc func optionButtonAction() {
        if !optionsViewShow {
            optionsView.isHidden = false
            optionsViewShow = true
        containerViewTopConst.constant = optionsView.frame.height
            view.layoutIfNeeded()
        }else {
            optionsViewShow = false
            optionsView.isHidden = true
            containerViewTopConst.constant = 0
            view.layoutIfNeeded()
        }
    }
    func keyboardHandelar() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension AddNewFileViewController: UITextFieldDelegate {
    //    MARK:- TextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
        if isKeyboardVisible == 0 {
            isKeyboardVisible = 1
            UIView.animate(withDuration: 0.5, animations: {
                self.contentTextViewBottomConst.constant =  self.view.frame.height/2.58 + 20
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension AddNewFileViewController: UITextViewDelegate {
    //    MARK:- TextView Delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == "Enter the content here" {
            contentTextView.text = ""
        }
        isKeyboardVisible = 1
        saveButton.isEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            self.contentTextViewBottomConst.constant = self.keyboardHeight + 10
            self.view.layoutIfNeeded()
        })
    }
}
