//
//  ListViewController.swift
//  PitchingManagement
//
//  Created by 桑原望 on 2020/02/28.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource//, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var monthLabel: UILabel!
    
   // var myPitches: Results<Pitches>!
    let dateFormatter = DateFormatter()
    
    let userDefaults = UserDefaults.standard
    
    let months = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
    let daysOfMonth = ["月","火","水","木","金","土","日"]
    
    var daysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var currentMonth = String()
    
    let layout = UICollectionViewFlowLayout()
    
    var numberOfEmptyBox = Int()
    
    var nextNumberOfEmptyBox = Int()
    
    var previousNumberOfEmptyBox = 0
    
    var direction = 0
    
    var positionIndex = 0
    
    //閏年
    var leapYearCounter = 0
    
    let leapYear = ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
    
    var dayCounter = 0
    //データが追加された時にcollectionViewを更新する処理
    var notificationToken: NotificationToken? = nil
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //デフォルトのRealmを検索
        //let realm = try! Realm()
        //Pitchesオブジェクトを検索
        // let pitches = realm.objects(Pitches.self)
        
        //return pitches.count
        
        switch direction {
            //TopMenuのカレンダー表示
        case 0:
        return daysInMonth[month] + numberOfEmptyBox
            //次月ボタンを押した時のカレンダー表示
        case 1...:
            return daysInMonth[month] + nextNumberOfEmptyBox
            //前月ボタンを押した時のカレンダー表示
        case -1 :
            return daysInMonth[month] + previousNumberOfEmptyBox
        default:
            fatalError()
        }
    }
    func GetStartDateDayPosition() {
        switch direction {
            
        case 0:
            numberOfEmptyBox = weekday
            dayCounter = day
            while dayCounter > 0 {
                //週の行数の調整
                numberOfEmptyBox = numberOfEmptyBox - 1
                dayCounter = dayCounter - 1
                //当月が日曜から始まる場合、7日間空ける。そしてL78 - L79で空いた分を戻す
                //このコードが無いと、カレンダーが4行表示になる
                if numberOfEmptyBox == 0 {
                    numberOfEmptyBox = 7
                }
            }
            if numberOfEmptyBox == 7 {
                numberOfEmptyBox = 0
            }
            positionIndex = numberOfEmptyBox
            
            //翌月の月初、空きスペースの表示
        case 1...:
            nextNumberOfEmptyBox = (positionIndex + daysInMonth[month]) % 7
            positionIndex = nextNumberOfEmptyBox
            
        case -1:
            //前月の空きスペースの表示
            previousNumberOfEmptyBox = (7 - (daysInMonth[month] - positionIndex) % 7)
            if previousNumberOfEmptyBox == 7 {
                previousNumberOfEmptyBox = 0
            }
            positionIndex = previousNumberOfEmptyBox
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RecordCollectionViewCell
        
        cell.dateLabel.textColor = UIColor.black
        cell.backgroundColor = UIColor.clear
        
//        let realm = try! Realm()
//        let pitches = realm.objects(Pitches.self)
//        let pitchesData = pitches[indexPath.row]
//        cell.pitchesLabel.text = String(pitchesData.pitchesText)
        
        if cell.isHidden {
            cell.isHidden = false
        }
        
        switch direction {
        case 0:
            cell.dateLabel.text = "\(indexPath.row + 1 - numberOfEmptyBox)"
        case 1:
            //nextNumberOfEmptyBoxが無いと、月初のスペースが表示されない
            cell.dateLabel.text = "\(indexPath.row + 1 - nextNumberOfEmptyBox)"
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - previousNumberOfEmptyBox)"
        default:
            fatalError()
        }
        //↓のコードが無いと、空白部分は「0,-1,-2...」と表示されるので、非表示にする
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        switch indexPath.row {
            //土曜の場合は青色
        case 6,13,20,27,34:
            if Int(cell.dateLabel.text!)! > 0 {
                cell.dateLabel.textColor = UIColor.blue
            }
        case 0,7,14,21,28,35:
            if Int(cell.dateLabel.text!)! > 0 {
                cell.dateLabel.textColor = UIColor.red
            }
        default:
            break
        }
        //現在日の背景を緑色にする
        if currentMonth == months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && indexPath.row + 1 == day {
            cell.backgroundColor = UIColor.green
            let realm = try! Realm()
            let pitches: Int = realm.objects(Pitches.self)
            //.sum(ofProperty: "pitchesText")
        
            cell.pitchesLabel.text = String(pitches)
            //self.userDefaults.set(cell.pitchesLabel.text!, forKey: "myPitches")
            //self.userDefaults.synchronize()
           
          //  cell.pitchesLabel.text = Pitches[indexPath.row].pitchesLabel
        }
        // let myPitchesData = userDefaults.string(forKey: "myPitches")
      //  cell.pitchesLabel.text = myPitchesData
        return cell
    }
    //Cell内のLabelに投球数を反映させる
//            let realm = try! Realm()
//            let pitches = realm.objects(Pitches.self)
//            let pitchesData = pitches[indexPath.row]
//    
//            cell.pitchesLabel.text = String(pitchesData.pitchesText) + "球"
    //        cell.backgroundColor = .green
    //        return cell
    // }
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
       
        let width = self.view.frame.width / 7
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: width, height: 80)
        collectionView.collectionViewLayout = layout

        //現在の月を取得
        currentMonth = months[month]
        monthLabel.text = "\(year)年 \(currentMonth)"
        if weekday == 0 {
            weekday = 7
        }
        GetStartDateDayPosition()
        //最初に開いた画面が閏年の場合
        if leapYear == true {
            daysInMonth[1] = 29
            leapYearCounter = 4
        } else if year % 4 == 1 {
            daysInMonth[1] = 28
            leapYearCounter = 1
        } else if year % 4 == 2 {
            daysInMonth[1] = 28
            leapYearCounter = 2
        } else if year % 4 == 3 {
            daysInMonth[1] = 28
            leapYearCounter = 3
        }
        
        let realm = try! Realm()
        
        //データが追加された時にcollectionViewを更新する処理
        notificationToken = realm.observe { Notification, realm in
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        
        switch currentMonth {
        case "12月":
            direction = 1
            month = 0
            year += 1
            
            if leapYearCounter < 5 {
                leapYearCounter += 1
            }
            if leapYearCounter == 4 {
                daysInMonth[1] = 29
            }
            if leapYearCounter == 5 {
                leapYearCounter = 1
                daysInMonth[1] = 28
            }
            
            GetStartDateDayPosition()
            currentMonth = months[month]
            
            monthLabel.text = "\(year)年 \(currentMonth)"
            collectionView.reloadData()
            
        default:
            direction = 1
            GetStartDateDayPosition()
            month += 1
            
            currentMonth = months[month]
            
            monthLabel.text = "\(year)年 \(currentMonth)"
            
            collectionView.reloadData()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        switch currentMonth {
        case "1月":
            direction = -1
            month = 11
            year -= 1
            
            if leapYearCounter > 0 {
                leapYearCounter -= 1
            }
              if leapYearCounter == 0 {
                    daysInMonth[1] = 29
                leapYearCounter = 4
              } else {
                daysInMonth[1] = 28
            }
            
            GetStartDateDayPosition()
             currentMonth = months[month]
            
            monthLabel.text = "\(year)年 \(currentMonth)"
            collectionView.reloadData()
            
        default:
            direction = -1
            month -= 1
            GetStartDateDayPosition()
             currentMonth = months[month]
            
           monthLabel.text = "\(year)年 \(currentMonth)"
            collectionView.reloadData()
        }
    }
}
class Pitches: Object {
    @objc dynamic var pitchesText = 0
    @objc dynamic var situationText = ""
    @objc dynamic var sumOfPitches = 0
    @objc dynamic var registeredDay = Date()
}
