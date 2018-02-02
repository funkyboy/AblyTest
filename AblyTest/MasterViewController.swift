//
//  MasterViewController.swift
//  AblyTest
//
//  Created by Cesare Rocchi on 02/02/2018.
//  Copyright © 2018 Ably. All rights reserved.
//

import UIKit
import Ably

let API_KEY="YOU_API_KEY"

class MasterViewController: UITableViewController {

  let ably = ARTRealtime(key: API_KEY)
  var channelList = [String]()
  var messages = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    navigationItem.rightBarButtonItem = refreshButton
    makeChannelList()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    subscribeToAllChannels()
    startPublishing()
  }
  
  func makeChannelList() {
    for i in 1...10 {
      channelList.append("channel\(i)")
    }
  }
  
  func subscribeToAllChannels() {
    for channelName in channelList {
      let channel = ably.channels.get(channelName)
      channel.subscribe(channelName) { message in
        if let data = message.data as? String {
          self.messages.append(data)
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func unsubscribeFromAllChannels() {
    for channelName in channelList {
      ably.channels.get(channelName).unsubscribe()
    }
  }
  
  @objc func refresh () {
    unsubscribeFromAllChannels()
    messages.removeAll(keepingCapacity: false)
    self.tableView.reloadData()
    // To allow some messages to be published while not subscribed
    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (t) in
      self.subscribeToAllChannels()
    }
  }
  
  func startPublishing() {
    Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
  }
  
  @objc func tick() {
    let index = Int(arc4random_uniform(UInt32(channelList.count)))
    let channelName = channelList[index]
    let channel = ably.channels.get(channelName)
    channel.publish(channelName, data: "message\(Date())")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let object = messages[indexPath.row]
    cell.textLabel!.text = object
    return cell
  }

}

