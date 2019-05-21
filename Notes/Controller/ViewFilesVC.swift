//
//  ViewFilesVC.swift
//  Notes
//
//  Created by Soumil on 24/04/19.
//  Copyright © 2019 LPTP233. All rights reserved.
//

import UIKit

class ViewFilesVC: UIViewController {
    @IBOutlet weak private var AddNewButton: UIButton!
    @IBOutlet weak  private var filesTable: UITableView!
    @IBOutlet weak private var themeChangeButton: UIBarButtonItem!
    @IBOutlet weak private var filesCollection: UICollectionView!
    private let addNewFileViewController = AddNewFileViewController()
    private var isDeleteButtonVisible = false
    private var isshaking = false
    private var cancelButton = UIBarButtonItem()
    private var didAnimate = false
    private var didCellAnimate = true
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUpSavedTheme()
        filesTable.applyTheme()
        filesCollection.applyTheme()
        customizeAddNewButton()
        filesTable.tableFooterView = UIView() // For Elemination extra seperators
        view.backgroundColor = currentTheme.superViewColor
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !didAnimate {
            performAnimation()
            didAnimate = true
        }
        DataOperations.shared.fetchData()
        filesTable.reloadData()
        filesCollection.reloadData()
    }
    
    //    MARK:- Theme Changed Button Action
    @IBAction func themeChangeButtonAction(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.object(forKey: "Theme") as? String == "Light" {
            UserDefaults.standard.set("Dark", forKey: "Theme")
            sender.title = "Dark"
            currentTheme = .dark
            view.backgroundColor = currentTheme.superViewColor
            filesTable.reloadData()
        }else {
            UserDefaults.standard.set("Light", forKey: "Theme")
            sender.title = "Light"
            currentTheme = .light
            view.backgroundColor = currentTheme.superViewColor
            filesTable.reloadData()
        }
        filesCollection.reloadData()
    }
    
    //    MARK:- Files View Changed Button Action
    @IBAction func ChangeFilesViewAction(_ sender: UIBarButtonItem) {
        if filesTable.isHidden == false {
            filesTable.isHidden = true
            filesCollection.isHidden = false
            filesCollection.reloadData()
            customizeCollectionViewLayout()
            UserDefaults.standard.set("CollectionView", forKey: "CurrentView")
        }else {
            filesTable.isHidden = false
            filesCollection.isHidden = true
            filesTable.reloadData()
            UserDefaults.standard.set("TableView", forKey: "CurrentView")
        }
    }
    
    //    MARK:- Settingup theme from UserDefaults
    func settingUpSavedTheme() {
        if UserDefaults.standard.object(forKey: "Theme") as? String == "Dark" {
            currentTheme = .dark
        }else {
            UserDefaults.standard.set("Light", forKey: "Theme")
            currentTheme = .light
        }
        if UserDefaults.standard.object(forKey: "CurrentView") as? String == "CollectionView" {
            filesTable.isHidden = true
            filesCollection.isHidden = false
            customizeCollectionViewLayout()
        }else {
            filesTable.isHidden = false
            filesCollection.isHidden = true
        }
        themeChangeButton.title = UserDefaults.standard.object(forKey: "Theme") as? String
    }
    
    //    MARK:- Customizing AddNewButton
    func customizeAddNewButton() {
        AddNewButton.layer.masksToBounds = true
        AddNewButton.layer.cornerRadius = AddNewButton.frame.width/2
    }
    
    //    MARK:- Perform AddFileButton Animation
    func performAnimation() {
        AddNewButton.zoom(x: 0.6, y: 0.6)
    }
}

extension ViewFilesVC: UITableViewDelegate, UITableViewDataSource {
    
    //    MARK:- Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataModel.shared.name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.applyTheme()
        cell.textLabel?.text = DataModel.shared.name[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let AddFileVC : AddNewFileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFileVC") as! AddNewFileViewController
        AddFileVC.indexNo = indexPath.row
        AddFileVC.flagUpdate = 1
        navigationController?.pushViewController(AddFileVC, animated: true)
    }
    
    //    MARK:- Delete Table rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            DataOperations.shared.deleteData(index: indexPath.row)
            tableView.reloadData()
        }
    }
    
    //    MARK:- Animate Table rows
    func tableView(_ tableView: UITableView, willDisplay cell:
        UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.5, delay: Double(indexPath.row) * 0.05, options: .curveEaseInOut, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        }, completion: nil)
    }
}

extension ViewFilesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //    MARK:- Collection View Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataModel.shared.name.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! allFilesCollectionViewCell
        cell.nameLbl.text = DataModel.shared.name[indexPath.row]
        cell.contentsLbl.text = DataModel.shared.content[indexPath.row]
        cell.nameLbl.applyTheme()
        cell.contentsLbl.applyTheme()
        cell.layer.borderWidth = 2
        cell.layer.borderColor = currentTheme.seperatorColor
        deleteButtonCustomization(deleteButton: cell.deleteButton, index: indexPath.row)
        cell.bringSubviewToFront(cell.deleteButton)
        if isshaking == true {
            cell.shake()
        }
        let lpGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell.addGestureRecognizer(lpGestureRecognizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let AddFileVC : AddNewFileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFileVC") as! AddNewFileViewController
        AddFileVC.indexNo = indexPath.row
        AddFileVC.flagUpdate = 1
        navigationController?.pushViewController(AddFileVC, animated: true)
    }
    
    //    MARK:- Animate Collection View Cells
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if didCellAnimate {
            cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
            UIView.animate(withDuration: 0.5, delay: Double(indexPath.row) * 0.01, options: .curveEaseInOut, animations: {
                cell.layer.transform = CATransform3DMakeScale(1,1,1)
            }, completion: nil)
        }
    }
    
    //    MARK:- Only two cells in a row
    func customizeCollectionViewLayout() {
        let itemsize = (UIScreen.main.bounds.width - 32)/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemsize, height: itemsize)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        filesCollection.collectionViewLayout = layout
    }
    
    //    MARK:- Reload Layout to adjust device rotation
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        customizeCollectionViewLayout()
    }
    
    //    MARK:- LongPress Gesture Action
    @objc func didLongPressCell (recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isDeleteButtonVisible = true
            didCellAnimate = false
            themeChangeButton.isEnabled = false
            isshaking = true
            filesCollection.reloadData()
            cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonAction(_:)))
            self.navigationItem.leftBarButtonItem  = cancelButton
        default: break
        }
    }
    
    //    MARK:- Navigation bar Button Cancel Button Action to stop deletion
    @objc func cancelButtonAction(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItems?.remove(at: 0)
        didCellAnimate = true
        themeChangeButton.isEnabled = true
        isDeleteButtonVisible = false
        isshaking = false
        filesCollection.reloadData()
    }
    
    //    MARK:- Delete Button on the cell action to delete the cell
    @objc func deleteButtonAction(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure to delete this file ?", preferredStyle: UIAlertController.Style.alert)
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            DataOperations.shared.deleteData(index: sender.tag)
            self.filesCollection.reloadData()
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(deleteAlert, animated: true, completion: nil)
    }
    
    //    MARK:- Customize Delete Button 
    func deleteButtonCustomization(deleteButton: UIButton, index: Int) {
        let image = UIImage(named: "crossButton.png")
        deleteButton.setImage(image, for: .normal)
        deleteButton.layer.masksToBounds = true
        deleteButton.backgroundColor = .yellow
        deleteButton.layer.cornerRadius = deleteButton.frame.width/2
        deleteButton.tag = index
        deleteButton.addTarget(self, action: #selector(deleteButtonAction(_:)), for: .touchUpInside)
        if isDeleteButtonVisible == true {
            deleteButton.isHidden = false
        }else {
            deleteButton.isHidden = true
        }
    }
}

public extension UIView {
    //    MARK:- To shake the Views
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 1.2
        animation.values = [-5.0, 5.0, -5.0, 5.0, -3.0, 3.0, -1.5, 1.5, 0.0 ]
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shake")
    }
    
    //    MARK:- Add zoom effects the Views
    func zoom(x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.6, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: x, y: y)
        }, completion: { (finish) in
            UIView.animate(withDuration: 0.6, delay: 0.4, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }
}

