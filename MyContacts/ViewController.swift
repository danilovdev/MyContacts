//
//  ViewController.swift
//  MyContacts
//
//  Created by Alexey Danilov on 20/11/2017.
//  Copyright © 2017 DanilovDev. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UITableViewController {
    
    var showIndexPaths = false
    
    var showIndexPathBarButtonItem: UIBarButtonItem!
    
    let cellId = "cellId"
    
     var twoDimensionalArray = [ExpandableNames]()
    
//    var twoDimensionalArray = [
//        ExpandableNames(isExpanded: true,
//                        contacts: ["Aleksei", "Andrey", "Aleksander", "Anton", "Anatoly"].map { FavoritableContact( name: $0, isFavorite: false) }),
//        ExpandableNames(isExpanded: true,
//                        contacts: ["Carl", "Charley", "Cameron", "Chris"].map { FavoritableContact(name: $0, isFavorite: false) }),
//        ExpandableNames(isExpanded: true,
//                        contacts: ["Denis", "David", "Donald"].map { FavoritableContact(name: $0, isFavorite: false) })
//    ]
    
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
    
    private func fetchContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to request access: ", error)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    
                    var favoritableContacts = [FavoritableContact]()
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print(contact.givenName)
                        print(contact.familyName)
                        print(contact.phoneNumbers.first?.value.stringValue ?? "")
                        
                        favoritableContacts.append(FavoritableContact(isFavorite: false, contact: contact))
                        
                        let names = ExpandableNames(isExpanded: true, contacts: favoritableContacts)
                        self.twoDimensionalArray = [names]
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                } catch let error {
                    print("Failed to enumerate contacts: ", error)
                }
            } else {
                print("Access denied")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchContacts()
        
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! ContactCell
//
        let cell = ContactCell(style: .subtitle, reuseIdentifier: "ContactCell")
        cell.favoriteDelegate = self
        let favoritableContact = self.twoDimensionalArray[indexPath.section].contacts[indexPath.row]
        let fullName = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
        cell.accessoryView?.tintColor = favoritableContact.isFavorite ? .red: .lightGray
        cell.textLabel?.text = fullName
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        if self.showIndexPaths {
            cell.textLabel?.text = "\(fullName) Section:\(indexPath.section) Row:\(indexPath.row)"
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

