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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Store.shared.resource(name: "taxa", type: Taxon.self).getOne(id: String(taxonId))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { taxon in
            if let taxon = taxon {
                self.nameLabel.text = taxon.name
                self.countLabel.text = "\(taxon.observations_count) observations"
                self.image.downloadedFrom(link: taxon.default_photo.square_url)
            }
        }, onError: { error in
            print("Completed with an error: \(error.localizedDescription)")
        }).disposed(by: bag)
    }
}
