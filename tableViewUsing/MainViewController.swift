//
//  MainViewController.swift
//  tableViewUsing
//
//  Created by Stephen on 2021/6/3.
//

import UIKit

class MainViewController: UIViewController {
    
    //隨機圖片API
    let urlStr = "https://picsum.photos/200/"
    //定義現在時間
    var currectTime = Date()
    //定義陣列，儲存時間及圖片DATA
    var loadDataArrays = [Data]()
    var timeArrays = [Date]()
    
    //計時
    var second = 0
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Label顯示為０
        secondLabel.text = "0"
        //驗證與上次上網抓圖片是否超過５秒
        timePassing()
    }
    
    //離開畫面則停止Label計時
    override func viewDidDisappear(_ animated: Bool) {
        if self.timer != nil {
            self.timer?.invalidate()
        }
    }
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBAction func reloadButton(_ sender: Any) {
        //停止計時
        self.timer?.invalidate()
        //計時器歸零
        second = 0
        secondLabel.text = String(second)
        //驗證與上次上網抓圖片是否超過５秒
        timePassing()
        //開始計時
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.plusSecond()
        })
    }
}


extension MainViewController {
    func download() {
        //讀取三次網址，分配在不同的View
        if let url = URL(string: urlStr) {
            self.loadDataArrays.removeAll()
            for i in 0...2 {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            switch i {
                            case 0 :
                                print("1")
                                // 圖片顯示
                                self.imageView1.image = UIImage(data: data)
                                self.loadDataArrays.append(data)
                            case 1 :
                                print("2")
                                self.imageView2.image = UIImage(data: data)
                                self.loadDataArrays.append(data)
                            default :
                                print("3")
                                self.imageView3.image = UIImage(data: data)
                                self.loadDataArrays.append(data)
                            }
                            
                            //將圖片Data及時間存到手機
                            let time = Date()
                            self.currectTime = time
                            
                            let useDefault = UserDefaults.standard
                            useDefault.set(self.loadDataArrays, forKey: "imageData")
                            useDefault.set(self.currectTime, forKey: "loadTime")
                        }
                    }
                }.resume()
            }
        }
    }
    //秒數隨時間增加
    func plusSecond() {
        second += 1
        secondLabel.text = String(second)
    }
    //驗證上次讀取時間是否超過５秒
    func timePassing() {
        //讀取儲存的Date資料，若沒有資料則直接跳else
        if let nowTime = UserDefaults.standard.value(forKey: "loadTime") as? Date {
            //讀取型別是Any，故要先轉型
            let sinceNow = -Int(nowTime.timeIntervalSinceNow) //計算出來是負數
            
            if sinceNow > 5 {
                //超過５秒才上網抓圖
                download()
                
            } else {
                //沒超過就讀舊圖
                imageView1.image = UIImage(data: UserDefaults.standard.array(forKey: "imageData")?[0] as! Data)
                imageView2.image = UIImage(data: UserDefaults.standard.array(forKey: "imageData")?[1] as! Data)
                imageView3.image = UIImage(data: UserDefaults.standard.array(forKey: "imageData")?[2] as! Data)
            }
        } else {
            //若手機裡沒資料則直接啟動上網抓圖片
            download()
        }
    }
}
