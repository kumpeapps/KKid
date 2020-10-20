//
//  KumpeModulesVC.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import UIKit
import CollectionViewCenteredFlowLayout

protocol KumpeModulesVC {
    var collectionView: UICollectionView! { get set }
    var modules:[K_Module] {get set}
    var iconWidth:Int {get set}
    func setupCollectionView()
    func buildModules()
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}


extension KumpeModulesVC{
    
    
    func setupCollectionView() {
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
    
//    MARK: centerItemsInCollectionView
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    


    //  MARK: Set Number of Items
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return modules.count
        }

//    MARK: set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = iconWidth
        return CGSize(width: screenWidth, height: screenWidth)
    }
}


struct K_Module {
    let title: String
    let segue: String?
    let icon: UIImage
}
