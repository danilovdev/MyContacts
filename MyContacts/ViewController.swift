//
//  ViewController.swift
//  MyContacts
//
//  Created by Alexey Danilov on 20/11/2017.
//  Copyright © 2017 DanilovDev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var showIndexPaths = false
    
    var showIndexPathBarButtonItem: UIBarButtonItem!
    
    let cellId = "cellId"
    
    var twoDimensionalArray = [
        ExapndableNames(isExpanded: true,
                        contacts: ["Aleksei", "Andrey", "Aleksander", "Anton", "Anatoly"].map { Contact( name: $0, isFavorite: false) }),
        ExapndableNames(isExpanded: true,
                        contacts: ["Carl", "Charley", "Cameron", "Chris"].map { Contact(name: $0, isFavorite: false) }),
        ExapndableNames(isExpanded: true,
                        contacts: ["Denis", "David", "Donald"].map { Contact(name: $0, isFavorite: false) })
    ]
    
    @objc func handleShowIndexPath() {
        
        var indexPathsToReload = [IndexPath]()
        for section in self.twoDimensionalArray.indices {
            if self.twoDimensionalArray[section].isExpanded {
                for row in self.twoDimensionalArray[section].contacts.indices {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToReload.append(indexPath)
                }
            }
        }
        
        self.showIndexPaths = !self.showIndexPaths
        let showIndexPathBarButtonItemTitle = self.showIndexPaths ? "Hide IndexPath" : "Show IndexPath"
        self.showIndexPathBarButtonItem.title = showIndexPathBarButtonItemTitle
        let animationStyle = self.showIndexPaths ? UITableViewRowAnimation.right : .left
        
        self.tableView.reloadRows(at: indexPathsToReload, with: animationStyle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let showIndexPathBarButtonItemTitle = self.showIndexPaths ? "Hide IndexPath" : "Show IndexPath"
        self.showIndexPathBarButtonItem = UIBarButtonItem(title: showIndexPathBarButtonItemTitle, style: .plain, target: self, action: #selector(handleShowIndexPath))
        self.navigationItem.rightBarButtonItem = self.showIndexPathBarButtonItem
        
        self.navigationItem.title = "Contacts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.register(ContactCell.self, forCellReuseIdentifier: self.cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.twoDimensionalArray[section].isExpanded) {
            return self.twoDimensionalArray[section].contacts.count
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.twoDimensionalArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ContactCell
        cell.favoriteDelegate = self
        let contact = self.twoDimensionalArray[indexPath.section].contacts[indexPath.row]
        let name = contact.name
        cell.accessoryView?.tintColor = contact.isFavorite ? .red: .lightGray
        cell.textLabel?.text = name
        if self.showIndexPaths {
            cell.textLabel?.text = "\(name) Section:\(indexPath.section) Row:\(indexPath.row)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.backgroundColor = .yellow
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.tag = section
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        return button
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    @objc func handleExpandClose(sender: UIButton) {
        let section = sender.tag
        
        var indexPaths = [IndexPath]()
        for row in self.twoDimensionalArray[section].contacts.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = self.twoDimensionalArray[section].isExpanded
        self.twoDimensionalArray[section].isExpanded = !isExpanded
        
        sender.setTitle(isExpanded ? "Open" : "Close", for: .normal)
        
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }

}

extension ViewController: FavoriteDelegate {
    
    func favoriteTapped(cell: ContactCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        let contact = self.twoDimensionalArray[indexPath.section].contacts[indexPath.row]
        let isFavorite = contact.isFavorite
        self.twoDimensionalArray[indexPath.section].contacts[indexPath.row].isFavorite = !isFavorite
        
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

