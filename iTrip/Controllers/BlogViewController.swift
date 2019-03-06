//
//  BlogViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/25/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import Photos


class BlogViewController: UIViewController,UICollectionViewDataSource, UITextViewDelegate, UICollectionViewDelegate {

    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var arrOfImages = ["1", "2", "3"]
    var currentArr = [String]()
    var  longPressedEnabled = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.clearButton.isEnabled = false
        
        //adding longpress gesture over UICollectionView
       let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
        gallery.addGestureRecognizer(longPressGesture)
        
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
            if currentArr.isEmpty{
            UserDefaults.standard.set(self.arrOfImages, forKey: "imageCells")
            }else{
                UserDefaults.standard.set(self.currentArr, forKey: "imageCells")
            }
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
        UserDefaults.standard.set(self.arrOfImages, forKey: "imageCells")
    }
    
//    @IBAction func doneButtonClick(_ sender: UIButton) {
//        //disable the shake and hide done button
//        doneButton.isHidden = true
//        longPressedEnabled = false
//
//        self.gallery.reloadData()
//    }
    

    
    // How many items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentArr.isEmpty {
            self.currentArr = self.arrOfImages
        } else {
            
             self.currentArr = UserDefaults.standard.object(forKey: "imageCells") as! [String]
        }
        

        return self.currentArr.count
    }

    // How it should look
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCellClass", for: indexPath) as! CustomCellClass
        cell.imageViews.image = UIImage(named:self.currentArr[indexPath.row])
        cell.removeBtn.addTarget(self, action: #selector(removeBtnClick(_:)), for: .touchUpInside)
        
        if longPressedEnabled   {
            cell.startAnimate()
        }else{
            cell.stopAnimate()
        }
        return cell
    }
    
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
        if self.currentArr.isEmpty{
            UserDefaults.standard.set(self.arrOfImages, forKey: "imageCells")
        }
        UserDefaults.standard.set(self.currentArr, forKey: "imageCells")
       
        
        
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
