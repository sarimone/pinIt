//
//  BlogViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/25/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import Photos


class BlogViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UITextViewDelegate, UICollectionViewDelegate {

    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var uploadeImageButton: UIButton!
   
    
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
    
    private func refreshPinData() {
        guard let p = self.pin else { return }
        self.title = p.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.clearButton.isEnabled = false
        
        //adding longpress gesture over UICollectionView
       let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        gallery.addGestureRecognizer(longPressGesture)
        
        refreshPinData()
        
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BlogViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
        guard ((pin != nil) && (self.index != nil)) else { return }
        let newPin = self.pin!
        newPin.title = self.textView.text
        mapViewDelegate.savePin(index: self.index!, pin: newPin)
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
    
    
    //Text field
    
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let myData = UserDefaults.standard.object(forKey: "myData") as? String ?? ""
        self.textView.text = myData
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if var blogVC = segue.destination as? MapViewController{
//            let newPin = self.pin!
//            newPin.title = self.textView.text
//            mapViewDelegate.savePin(index: index!, pin: newPin)
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
//        imageTake.image = selectedImage
    }
    
}
