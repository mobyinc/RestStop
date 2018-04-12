//
//  ViewController.swift
//  RestStop
//
//  Created by mobyjames on 04/02/2018.
//  Copyright (c) 2018 mobyjames. All rights reserved.
//

import UIKit
import RxSwift
import RestStop

class ViewController: UITableViewController {
    var bag: DisposeBag = DisposeBag()
    var result: Result<Taxon>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Store.shared.resource(name: "taxa", type: Taxon.self).getList()
            .observeOn(MainScheduler.instance)
            .subscribe { event in
            switch event {
            case .success(let result):
                self.result = result
                self.tableView.reloadData()
            case .error(_):
                print("error")
            }
        }.disposed(by: bag)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let taxon = self.result?.items[indexPath.row] ?? nil
        
        if let taxon = taxon {
            cell.textLabel?.text = taxon.name
        }
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaxonDetail", let destination = segue.destination as? TaxonDetailViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let taxon = self.result!.items[indexPath.row]
                destination.taxonId = taxon.id
            }
        }
    }
}

