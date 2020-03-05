//
//  SumViewController.swift
//  PitchingManagement
//
//  Created by 桑原望 on 2020/02/28.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit
import RealmSwift

class SumViewController: UIViewController {
    
 let realm = try! Realm()
   
     var notificationToken: NotificationToken? = nil
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var sumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         //全データを取得して累計投球数を求めたい
        notificationToken = realm.observe { Notification, realm in
           
//            if pitches.count == 1 {
//                self.sumLabel.text = "1"
//            }
            let sum : Int = realm.objects(Pitches.self).sum(ofProperty: "pitchesText")
           // let sum: Int = pitches.sum(ofProperty: "pitchesText")

            self.sumLabel.text = String(sum) + "球"
            self.userDefaults.set(self.sumLabel.text, forKey: "result")
            self.userDefaults.synchronize()
        }
        let resultSum = userDefaults.string(forKey: "result")
        sumLabel.text = resultSum
    }
  
}
