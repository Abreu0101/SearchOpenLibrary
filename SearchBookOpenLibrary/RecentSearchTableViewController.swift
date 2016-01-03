//
//  RecentSearchTableViewController.swift
//  SearchBookOpenLibrary
//
//  Created by Roberto Abreu on 3/1/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {

    var listOfRecentSearch: [[String:String]] = []
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecentSearch.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellRecentSearch", forIndexPath: indexPath)
        
        let dictRecent = listOfRecentSearch[indexPath.row] 
        cell.textLabel?.text = dictRecent["title"]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! ViewController
        controller.searchDelegate = self
        
        if segue.identifier == "segue_cell_search"{
            if let indexPath = self.tableView.indexPathForSelectedRow{
                controller.bookDetail = self.listOfRecentSearch[indexPath.row]
            }
        }
    }
    
}

extension RecentSearchTableViewController : SearchDelegate{
    
    func bookSearched(book: [String : String]) {
        self.listOfRecentSearch.append(book)
        self.tableView.reloadData()
    }
    
}
