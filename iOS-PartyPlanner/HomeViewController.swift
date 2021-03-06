//
//  HomeViewController.swift
//  iOS-PartyPlanner
//
//  Created by Yan, Tristan on 4/25/17.
//  Copyright © 2017 PartyDevs. All rights reserved.
//

import UIKit
import MBProgressHUD
import Lottie


class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,  CellSubclassDelegate{
  
  @IBAction func onSignout(_ sender: Any) {
    User.currentUser?.signout()
  }
  
  @IBOutlet var homeSegmentedControl: UISegmentedControl!
  @IBOutlet var homeTableView: UITableView!
  var refreshControl:UIRefreshControl!
  var pastEventList = [Event]()
  var pastEventIds: [String] = []
  var upcomingEventList = [Event]()
  var upcomingEventIds: [String] = []
  var taskList = [Task]() //Task list of the user for each event
  var tasksList = [[Task]]() // Whole events tasks
  var sectionEvents = ["Upcoming", "Past"]
  var sectionTasks = [String]()
  var sign = 0 // 0.Display Events 1.Display Tasks
  var selectedEvent:Event?
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(self.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
    homeTableView.insertSubview(refreshControl, at: 0)
    fetchEvents()
  }
  
  func refreshControlAction(_ refreshControl: UIRefreshControl) {
    refreshControl.endRefreshing()
  }
  
  @IBAction func indexChanged(_ sender: Any) {
    switch homeSegmentedControl.selectedSegmentIndex
    {
    case 0:
      sign = 0
      homeTableView.rowHeight = 250
      self.homeTableView.reloadData()
    case 1:
      sign = 1
      homeTableView.rowHeight = 50
      self.homeTableView.reloadData()
    default:
      break
    }
  }
  
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if sign == 0 {
      return self.sectionEvents [section]
    }
    else{
      return self.sectionTasks [section]
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if sign == 0 {
      return self.sectionEvents.count
    }
    else{
      return self.sectionTasks.count
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if sign == 0 {
      if section == 0 {
        return upcomingEventList.count
      }
      else {
        return pastEventList.count
      }
    }
    else{
        if tasksList.count > 0 {
            return tasksList[section].count
        }
        else{
            return 0
        }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if sign == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "HomeEventTableViewCell") as! HomeEventTableViewCell
      cell.delegate = self

      let currSection = sectionEvents[indexPath.section]
      switch currSection {
        
      case "Upcoming" :
        cell.event = upcomingEventList[indexPath.item]
        break;
        
      case "Past":
        cell.event = pastEventList[indexPath.item]
       // cell.rsvpButton.isHidden = true
        break;
        
      default:
        break;
      }
      return cell
      
    }
    else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTaskTableViewCell") as! HomeTaskTableViewCell
      var tasks = tasksList[indexPath.section]
      cell.task = tasks[indexPath.item]
      return cell
    }
  }
  

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      homeTableView.deselectRow(at:indexPath, animated: true)
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("Call perform segue \(String(describing: segue.identifier))")
    
    if segue.identifier == "showEvent" {
      if sign == 0{
        let indexPath = homeTableView.indexPathForSelectedRow
        
        let section = indexPath?.section
        let event : Event
        if section == 0 {
          event = upcomingEventList[(indexPath?.row)!]
        }
        else{
          event = pastEventList[(indexPath?.row)!]
        }
        let eventViewController = segue.destination as! EventViewController
        eventViewController.event = event
      }
    }
    else if segue.identifier == "mapSegue"  {
      let mapViewController = segue.destination as! EventsMapViewController
      mapViewController.events = upcomingEventList
    }
    else if segue.identifier == "HomeToEventCreationSegue" {
//      let animationView = LOTAnimationView(name: "pencil_write")
//      animationView?.frame = view.bounds
//      animationView?.contentMode = .scaleAspectFit
//      animationView?.animationSpeed = 4
//      self.view.addSubview(animationView!)
//      
//      animationView?.play(completion: { finished in
//      })
    }
    else if segue.identifier == "HomeToRsvpSegue" {
      print("Going to rsvp")
      if RSVP.currentInstance == nil {
        RSVP.currentInstance = RSVP()
      }
      if selectedEvent != nil {
        print("Event has been selected")
        RSVP.currentInstance?.id = (selectedEvent?.id)! + (User.currentUser?.email?.replacingOccurrences(of: ".", with: ""))!
        RSVP.currentInstance?.eventId = (selectedEvent?.id)!
        RSVP.currentInstance?.guestEmail = (User.currentUser?.email!)!
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func fetchEvents(){
    
    /*-----Get past events ----*/
    
    EventApi.sharedInstance.getPastEventsHostedByUserEmail(userEmail: (User._currentUser?.email)!, success: { (events: [Event]) in
      if events.count > 0 {
        for i in 0..<events.count {
          if !self.pastEventIds.contains(events[i].id){
            self.pastEventIds.append(events[i].id)
            self.pastEventList.append(events[i])
            events[i].fecthRelateData()
          }
        }
        self.homeTableView.reloadData()
      }
    }, failure: nil )
    
  
    EventApi.sharedInstance.getPastEventsForUserEmail(userEmail: (User._currentUser?.email)!, success: { (events: [Event]) in
      if events.count > 0 {
        for i in 0..<events.count {
          if !self.pastEventIds.contains(events[i].id){
            self.pastEventIds.append(events[i].id)
            self.pastEventList.append(events[i])
            events[i].fecthRelateData()
          }
        }
      }
      self.homeTableView.reloadData()
    }, failure: nil )
    
    
    /*-----Get upcoming events ----*/
    
    EventApi.sharedInstance.getUpcomingEventsHostedByUserEmail(userEmail: (User._currentUser?.email)!, success: { (events: [Event]) in
      if events.count > 0 {
        for i in 0..<events.count {
          if !self.upcomingEventIds.contains(events[i].id){
            self.upcomingEventIds.append(events[i].id)
            self.upcomingEventList.append(events[i])
            events[i].fecthRelateData()
          }
        }
        self.homeTableView.reloadData()
      }
    }, failure: nil )
    
   
    EventApi.sharedInstance.getUpcomingEventsForUserEmail(userEmail: (User._currentUser?.email)!, success: { (events: [Event]) in
      if events.count > 0 {
        for i in 0..<events.count {
          if !self.upcomingEventIds.contains(events[i].id){
            self.upcomingEventIds.append(events[i].id)
            self.upcomingEventList.append(events[i])
            events[i].fecthRelateData()
          }
        }
        
      }
      self.homeTableView.reloadData()
      self.fetchAssignedTasks()
      
    }, failure: nil )
  }
  
  
  func fetchAssignedTasks(){
    for event in upcomingEventList {
      TaskApi.sharedInstance.getTasksByEventId(eventId: event.id, success: {(tasks: [Task])
        in
        for task in tasks {
          if task.volunteerEmails != nil && (task.volunteerEmails?.values.contains((User.currentUser?.email)!))! {
            task.eventName = event.name
            self.taskList.append(task)
            print(task.name)
            self.homeTableView.reloadData()
            if !self.sectionTasks.contains(event.name!){
              self.sectionTasks.append(event.name!)
            }
          }
        }
        if self.taskList.count > 0 {
            self.tasksList.append(self.taskList)
            self.homeTableView.reloadData()
            self.taskList = [Task]()
        }
        
      }, failure:{})
      
    }
  }
  
  func buttonTapped(cell: HomeEventTableViewCell) {
    guard let indexPath = homeTableView.indexPath(for: cell) else {
      return
    }
    print("Button tapped on row \(indexPath.row) section \(indexPath.section)")
    
    let currSection = sectionEvents[indexPath.section]
    switch currSection {
      
    case "Upcoming" :
      selectedEvent = upcomingEventList[indexPath.item]
    case "Past":
      selectedEvent = pastEventList[indexPath.item]
    default: break
    }

    performSegue(withIdentifier: "HomeToRsvpSegue", sender: cell)
  }
  
}
