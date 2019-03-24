//
//  BlogViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/25/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import Photos


class BlogViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var uploadeImageButton: UIButton!
    @IBOutlet weak var switchPinStatus: UISwitch!
    @IBOutlet weak var textBoxTitle: UITextField!
    
    var imagePicker = UIImagePickerController()
    var arrOfImages = [UIImage]()
    
    var longPressedEnabled = false
    
    public var mapViewDelegate: MapBlogDelegate!
    
    public var pin: Pin? {
        didSet {
            refreshPinData()
        }
    }
    
    public var index: Int?
    
    public func refreshPinData() {
        guard let p = self.pin else { return }
        self.title = p.title
        if self.textView != nil {
            self.textView.text = p.text
        }
        if self.textBoxTitle != nil {
            self.textBoxTitle.text = p.title
        }
        if self.gallery != nil {
            self.arrOfImages = p.images
            gallery.reloadData()
        }
        if self.switchPinStatus != nil{
            switchPinStatus.isOn = p.visited ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.clearButton.isEnabled = false
        
        //adding longpress gesture over UICollectionView
       let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        gallery.addGestureRecognizer(longPressGesture)
        
        refreshPinData()
    }
    
    
    @IBAction func backClick(_ sender: Any?) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveClick(_ sender: Any?) {
        if mapViewDelegate != nil, let index = self.index, let newPin = self.pin {
            newPin.text = self.textView.text
            newPin.title = self.textBoxTitle.text
            newPin.images = self.arrOfImages
            newPin.visited = switchPinStatus.isOn
            mapViewDelegate.savePin(index: index, pin: newPin)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func longTap(_ gesture: UIGestureRecognizer){
        
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = gallery.indexPathForItem(at: gesture.location(in: gallery)) else {
                return
            }
            gallery.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            gallery.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            gallery.endInteractiveMovement()
            doneButton.isHidden = false
            longPressedEnabled = true
           
            self.gallery.reloadData()
            
        default:
            gallery.cancelInteractiveMovement()
        }
    }
    
    @objc func removeBtnClick(_ gesture: Any) {
        
    }
    
    @IBAction func doneBtnClick(_ sender: Any){
        gallery.reloadData()
        longPressedEnabled = false
        
    }
    
    @IBAction func removeButtonClick(_ sender: UIButton)   {
        let hitPoint = sender.convert(CGPoint.zero, to: self.gallery)
        let hitIndex = self.gallery.indexPathForItem(at: hitPoint)
        
        //remove the image and refresh the collection view
        self.arrOfImages.remove(at: (hitIndex?.row)!)
        self.gallery.reloadData()
       
    }
    
 
    // Uploade image button
    
    @IBAction func uploadeImagePressed(_ sender: UIButton) {
        self.openGallery()
    }
    

    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        refreshPinData()
    }
    
    // When button is clicked remove the saved pin and associated blog
    @IBAction func removeBlogOnClick(_ sender: Any) {
       
        if mapViewDelegate != nil, let index = self.index, let newPin = self.pin {
            newPin.title = self.textView.text
            newPin.images = self.arrOfImages
            mapViewDelegate.removePin(index: index)
        
        }
        _ = navigationController?.popViewController(animated: true)
    }
    

    
}

extension BlogViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // How many items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrOfImages.count
        
    }
    
    // How it should look
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCellClass", for: indexPath) as! CustomCellClass
        cell.imageViews.image = self.arrOfImages[indexPath.row]
        cell.removeBtn.addTarget(self, action: #selector(removeBtnClick(_:)), for: .touchUpInside)
        
        if longPressedEnabled   {
            cell.startAnimate()
        }else{
            cell.stopAnimate()
        }
        return cell
    }
}

//Text field
extension BlogViewController: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        clearButton.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UserDefaults.standard.setValue(textView.text, forKey: "myData")
        UserDefaults.standard.synchronize()
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        textView.text = ""
        clearButton.isEnabled = false
    }
}



extension BlogViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        self.arrOfImages.append(selectedImage)
        self.gallery.reloadData()
    }
    
}
