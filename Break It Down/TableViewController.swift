//
//  TableViewController.swift
//  Break It Down
//
//  Created by Rob Norback on 8/28/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate {
    
    var numberOfRows:Int = 6
    var tableTitle:String = "To Do"
    var toDoItems = [ToDoItem]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        
        if toDoItems.count == 0 {
            setupToDoItems()
        }
        
    }
    
    func setupToDoItems() {
        let items = ["feed the cat","buy eggs","watch WWDC videos","rule the web","buy a new iPhone","darn holes in socks","write this tutorial","master Swift","learn to draw","get more exercise","catch up with Mom","get a hair cut"]
        for item in items {
            toDoItems.append(ToDoItem(text: item))
        }
    }
    
    func setupTable() {
        // Setup the delegate
        tableView.delegate = self;
        tableView.dataSource = self;
        
        // Use this when you don't have a prototype cell
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        tableView.backgroundColor = UIColor.blackColor()
        
        // Set the title of the nav bar
        title = self.tableTitle
        
        // This will remove extra separators from tableview
        //tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Add tap geture to the empty table space
        let tap = UITapGestureRecognizer(target: self, action: Selector("insertRow:"))
        tableView.addGestureRecognizer(tap);
    }
    
    func insertRow(tap:UITapGestureRecognizer) {
        let location = tap.locationInView(tableView)
        var path:NSIndexPath? = tableView.indexPathForRowAtPoint(location)
        if let path = path {
            tableView(tableView, didSelectRowAtIndexPath: path)
        }else {
            print("path is nil")
        }
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        return toDoItems.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        
        let item = toDoItems[indexPath.row]
        //cell.textLabel?.text = item.text
        //cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.delegate = self
        cell.toDoItem = item
        
        return cell
    }
    
    // MARK: - Table view cell delegate
    func toDoItemsDeleted(toDoItem: ToDoItem) {
        let index = find(toDoItems, toDoItem)
        
        if let index = index {
            toDoItems.removeAtIndex(index)
            
            tableView.beginUpdates()
            let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
            tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Left)
            tableView.endUpdates()
        } else {
            return
        }
        
    }
    
    
    // MARK: - Table view delegate
    
    // Creates color gradient effect from red to yellow
    func colorForIndex(index:Int) -> UIColor {
        let itemCount = toDoItems.count - 1;
        let val = (CGFloat(index)/CGFloat(itemCount)) * 0.9
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let tvc = TableViewController()
//        self.presentViewController(tvc, animated: true) { () -> Void in}
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    /*
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.numberOfRows--
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! TableViewController
        vc.numberOfRows = self.numberOfRows - 1
    }


}
