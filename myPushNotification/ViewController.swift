//
//  ViewController.swift
//  myPushNotification
//
//  Created by Anand Mukut Tirkey on 18/02/17.
//  Copyright © 2017 Anand Mukut Tirkey. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
   
    var listItems = [NSManagedObject]()
    //var notifications : [notifiacation] = []//of no use
    var newCount = 0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var flag = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchOldData()
        fetchData()
        //showAlert()
        while !flag{
            
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return listItems.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = listItems[indexPath.row]
        cell.textLabel?.text = ((item.valueForKey("label") as? String)! + String(item.valueForKey("code") as! Int))
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        fetchOldData()
        showAlert()
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let context = appDelegate.managedObjectContext
        context.deleteObject(listItems[indexPath.row])
        do{
            try context.save()
        }catch{
            print("error while saving after deleting")
        }
        listItems.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
        print("printing listItems")
        print(listItems)
    }
    func fetchData(){
        let url = NSURL(string: "https://dl.dropboxusercontent.com/s/nwc5pcf9106l5zm/subway.json?dl=0")
        let urlRequest = NSMutableURLRequest(URL: url!)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){
            (data, response, error) -> Void in
            if error != nil {
                print("error")
            }else{
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if (statusCode == 200) {
                    print("file downloaded successfully")
                    do{
                        let jsonData  = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        //print(jsonData)
                        if let allNotification = jsonData["notification"] as? NSArray {
                            for noti in (allNotification as NSArray){
                                let code = Int(noti["code"] as! String)
                                let label = noti["label"] as! String
                                let detail = noti["detail"] as! String
                                print(self.listItems.count)
                                if self.listItems.count-1 >= 0{
                                    //print(self.listItems[self.listItems.count-1].valueForKey("code"))
                                    if ((self.listItems[self.listItems.count-1].valueForKey("code") )as! Int) < code{
                                        //TODO: insert new item in DB and count how many they are
                                        self.newCount += 1
                                        let context = self.appDelegate.managedObjectContext
                                        let entity = NSEntityDescription.entityForName("Notification", inManagedObjectContext: context)
                                        let newNotification = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                                        newNotification.setValue(label, forKey: "label")
                                        newNotification.setValue(code, forKey: "code")
                                        newNotification.setValue(detail, forKey: "detail")
                                        do{
                                            try newNotification.managedObjectContext?.save()
                                            let fetchRequest =  NSFetchRequest(entityName: "Notification")
                                            do{
                                                let results = try context.executeFetchRequest(fetchRequest)
                                                self.listItems = results as! [NSManagedObject]
                                            }catch{
                                                print("fetching error for old data")
                                            }
                                        }catch{
                                            print("error in saving updated data")
                                        }
                                    }
                                }else{
                                    self.newCount += 1
                                    let context = self.appDelegate.managedObjectContext
                                    let entity = NSEntityDescription.entityForName("Notification", inManagedObjectContext: context)
                                    let newNotification = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                                    newNotification.setValue(label, forKey: "label")
                                    newNotification.setValue(code, forKey: "code")
                                    newNotification.setValue(detail, forKey: "detail")
                                    do{
                                        try newNotification.managedObjectContext?.save()
                                        let fetchRequest =  NSFetchRequest(entityName: "Notification")
                                        do{
                                            let results = try context.executeFetchRequest(fetchRequest)
                                            self.listItems = results as! [NSManagedObject]
                                        }catch{
                                            print("fetching error for old data")
                                        }
                                    }catch{
                                        print("error in saving initial data")
                                    }
                                }
                            }
                            self.printf()
                            self.flag = true
                        }else{
                            print("unknown error")
                        }
                    }catch{
                        print("Error with Json: \(error)")
                        self.flag = true
                    }
                }else{
                    print("download failed")
                    self.flag = true
                }
            }
        }
        self.flag = true
        task.resume()
        tableView.reloadData()
        showAlert()
    }
    func printf() {
        print("inside print")
        print("printing list items")
        print(listItems)
        print("printing newCOunt")
        print(newCount)
        showAlert()
    }
    func fetchOldData() {
        let context = appDelegate.managedObjectContext
        let fetchRequest =  NSFetchRequest(entityName: "Notification")
        do{
            let results = try context.executeFetchRequest(fetchRequest)
            listItems = results as! [NSManagedObject]
        }catch{
            print("fetching error for old data")
        }
    }
    func showAlert(){
        //TODO: create locale notification and show it
        if newCount > 0 {
            let date = NSDate()
            let dateComponent = NSDateComponents()
            dateComponent.second = 2
            let calendar = NSCalendar.currentCalendar()
            let notification:UILocalNotification = UILocalNotification()
            notification.alertBody = "you have \(newCount) new news"
            notification.fireDate = calendar.dateByAddingComponents(dateComponent, toDate: date, options: .MatchFirst)
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            UIApplication.sharedApplication().applicationIconBadgeNumber = newCount
            fetchOldData()
            newCount = 0
        }else{
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            print("no new item")
        }
        
    }
}

