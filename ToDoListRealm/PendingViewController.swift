//
//  PendingViewController.swift
//  ToDoListRealm
//
//  Created by Ajay Ghodadra on 13/09/16.
//  Copyright © 2016 Ajay Ghodadra. All rights reserved.
//

import UIKit
import KVNProgress
import RealmSwift

class PendingViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    var arrLists: NSArray!
    var pendingTasks : Results<Task>!
    var currentCreateAction:UIAlertAction!
    var selectedIndex:NSIndexPath?
    
    @IBOutlet weak var tblTasks: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.readTasksAndUpateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Actions -
    
    @IBAction func didClickOnCancelTask(sender: UIButton) {
        self.selectedIndex = nil
        self.readTasksAndUpateUI()
    }
    
    @IBAction func didClickOnNewTask(sender: AnyObject) {
        self.displayAlertToAddTask()
    }
    
    // MARK: - UITableViewDataSource/Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.pendingTasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
        let task: Task! = self.pendingTasks[indexPath.row]
        
        cell.btnCancel.tag = indexPath.row
        cell.btnCancel.addTarget(self, action:#selector(PendingViewController.didClickOnCancelTask(_:)), forControlEvents: .TouchUpInside)
        cell.lblName.text = task.name
        
        if self.selectedIndex == indexPath {
            cell.btnCancel.hidden = false
        }else{
            cell.btnCancel.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if(indexPath != self.selectedIndex){
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
                
                //Deletion will go here
                let taskToBeDeleted: Task! = self.pendingTasks[indexPath.row]
                try! uiRealm.write{
                    uiRealm.delete(taskToBeDeleted)
                    self.readTasksAndUpateUI()
                }
            }
            
            return [deleteAction]
        }else{
            return []
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedIndex = indexPath
        self.readTasksAndUpateUI()
        
        //Now start the timer
        _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(PendingViewController.updateState), userInfo: nil, repeats: false)
        
    }
    
    //MARK:- Helper Methods
    
    func getLists() {
        if(appDelegate.internetConnection == true){
            KVNProgress.showWithStatus("Loading")
            let swiftRequest = SwiftRequest()
            swiftRequest.get(baseUrl, callback: { (err, response, body) -> () in
                if err != nil {
                    return
                }
                
                let data = NSString(data: body as! NSData, encoding: NSUTF8StringEncoding) as! String
                self.arrLists = self.convertStringToDictionary(data)!["data"] as! NSArray
                
                dispatch_async(dispatch_get_main_queue()) {
                    for obj in self.arrLists{
                        let newTask = Task()
                        newTask.name = obj["name"] as! String
                        newTask.state = obj["state"] as! Bool
                        try! uiRealm.write{
                            uiRealm.add(newTask)
                        }
                    }
                    self.readTasksAndUpateUI()
                }
                KVNProgress.dismiss()
            })
        }else{
            self.readTasksAndUpateUI()
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func updateState() {
        if self.selectedIndex != nil {
            let taskToBeUpdated: Task! = self.pendingTasks[self.selectedIndex!.row]
            try! uiRealm.write{
                taskToBeUpdated.state = true
                self.readTasksAndUpateUI()
                self.selectedIndex = nil
            }
        }
    }
    
    func readTasksAndUpateUI(){
        let lists = uiRealm.objects(Task)
        self.pendingTasks = lists.filter("state = false")
        self.tblTasks.reloadData()
        if(lists.count == 0){
            self.getLists()
        }
    }

    func displayAlertToAddTask(){
        
        let title = "New Task"
        let doneTitle = "Create"
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.Alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let taskName = alertController.textFields?.first?.text
            
            let newTask = Task()
            newTask.name = taskName!
            newTask.state = false
            
            try! uiRealm.write{
                uiRealm.add(newTask)
                self.readTasksAndUpateUI()
            }
        }
        
        alertController.addAction(createAction)
        createAction.enabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(PendingViewController.taskNameFieldDidChange(_:)) , forControlEvents: UIControlEvents.EditingChanged)
            
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    func taskNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0
    }

}

