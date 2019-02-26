//
//  BlogViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/25/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit

class BlogViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var gallery: UICollectionView!
    
    var arrOfImages = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // How many items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfImages.count
    }

    // How it should look
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCellClass", for: indexPath) as! CustomCellClass
        cell.imageViews.image = UIImage(named:arrOfImages[indexPath.row])
        
        return cell
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
