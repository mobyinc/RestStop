//
//  TaxonDetailViewController.swift
//  RestStop_Example
//
//  Created by James Jacoby on 4/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RestStop
import RxSwift

class TaxonDetailViewController: UIViewController {
    var taxonId: Int!
    var bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Store.shared.resource(name: "taxa", type: Taxon.self).getOne(id: String(taxonId)).subscribe(onSuccess: { taxon in
            print("Completed with no error")
        }, onError: { error in
            print("Completed with an error: \(error.localizedDescription)")
        }).disposed(by: bag)
    }
}
