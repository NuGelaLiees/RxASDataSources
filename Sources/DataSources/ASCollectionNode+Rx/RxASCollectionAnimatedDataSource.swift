//
//  RxASCollectionAnimatedDataSource.swift
//  RxTextureDataSources
//
//  Created by Dang Thai Son on 7/27/17.
//  Copyright © 2017 RxSwiftCommunity. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxDataSources

open class RxASCollectionAnimatedDataSource<S: AnimatableSectionModelType>: ASCollectionSectionedDataSource<S>, RxASCollectionDataSourceType {

    public typealias Element = [S]
    public var animationConfiguration = AnimationConfiguration()

    var dataSet = false

    public override init() {
        super.init()
    }

    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: RxSwift.Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                DispatchQueue.main.async {
                    dataSource.setSections(newSections)
                    collectionNode.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)

                        for difference in differences {
                            dataSource.setSections(difference.finalSections)
                            collectionNode.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                        }
                    } catch {
                        rxDebugFatalError("\(error)")
                        DispatchQueue.main.async {
                            self.setSections(newSections)
                            collectionNode.reloadData()
                        }
                    }
                }
            }
            }.on(observedEvent)
    }
}
