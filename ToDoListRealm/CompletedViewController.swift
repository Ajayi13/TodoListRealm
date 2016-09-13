//
//  CompletedViewController.swift
//  ToDoListRealm
//
//  Created by Ajay Ghodadra on 13/09/16.
//  Copyright © 2016 Ajay Ghodadra. All rights reserved.
//

import UIKit
import RealmSwift

class CompletedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    var completedTasks : Results<Task>!
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
    
    // MARK: - UITableViewDataSource/Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.completedTasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
        let task: Task! = self.completedTasks[indexPath.row]
        cell.lblName.text = task.name
        cell.btnCancel.hidden = true
        return cell
    }
    
    //MARK:- Helper Methods
    
    func readTasksAndUpateUI(){
        let lists = uiRealm.objects(Task)
        self.completedTasks = lists.filter("state = true")
        self.tblTasks.reloadData()
    }
}
