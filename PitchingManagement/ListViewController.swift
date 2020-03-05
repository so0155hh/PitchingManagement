//
//  ListViewController.swift
//  PitchingManagement
//
//  Created by 桑原望 on 2020/02/28.
//  Copyright © 2020 MySwift. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var monthLabel: UILabel!
    
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
        case 0:
            return daysInMonth[month] + numberOfEmptyBox
        case 1...:
            return daysInMonth[month] + nextNumberOfEmptyBox
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
                numberOfEmptyBox = numberOfEmptyBox - 1
                dayCounter = dayCounter - 1
                if numberOfEmptyBox == 0 {
                    numberOfEmptyBox = 7
                }
            }
            if numberOfEmptyBox == 7 {
                numberOfEmptyBox = 0
            }
            positionIndex = numberOfEmptyBox
            
        case 1...:
            nextNumberOfEmptyBox = (positionIndex + daysInMonth[month]) % 7
            positionIndex = nextNumberOfEmptyBox
            
        case -1:
            previousNumberOfEmptyBox = (7 - (daysInMonth[month] - positionIndex) % 7)
            if previousNumberOfEmptyBox == 7 {
                previousNumberOfEmptyBox = 0
            }
            positionIndex = previousNumberOfEmptyBox
        default:
            fatalError()
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize  {
        let width: CGFloat = view.frame.width / 2 - 2
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RecordCollectionViewCell
        
        cell.dateLabel.textColor = UIColor.black
        cell.backgroundColor = UIColor.clear
        
        if cell.isHidden {
            cell.isHidden = false
        }
        
        switch direction {
        case 0:
            cell.dateLabel.text = "\(indexPath.row + 1 - numberOfEmptyBox)"
        case 1:
            cell.dateLabel.text = "\(indexPath.row + 1 - nextNumberOfEmptyBox)"
        case -1:
            cell.dateLabel.text = "\(indexPath.row + 1 - previousNumberOfEmptyBox)"
        default:
            fatalError()
        }
        if Int(cell.dateLabel.text!)! < 1 {
            cell.isHidden = true
        }
        switch indexPath.row {
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
        
        if currentMonth == months[calendar.component(.month, from: date) - 1] && year == calendar.component(.year, from: date) && indexPath.row + 1 == day {
            cell.backgroundColor = UIColor.green
        }
        return cell
    }
    
    //Cell内のLabelに投球数を反映させる
    //        let realm = try! Realm()
    //        let pitches = realm.objects(Pitches.self)
    //        let pitchesData = pitches[indexPath.row]
    //
    //        cell.pitchesLabel.text = String(pitchesData.pitchesText) + "球"
    //        cell.backgroundColor = .green
    //        return cell
    // }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 45, height: 80)
        
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
            leapYearCounter = 23
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
}
