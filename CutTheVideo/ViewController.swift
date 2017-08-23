//
//  ViewController.swift
//  CutTheVideo
//
//  Created by huyangyang on 2017/8/14.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

import UIKit
import RTRootNavigationController
class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func ClickCutBtn(_ sender: UIButton) {
    let moviePath = Bundle.main.path(forResource: "test02", ofType: "mov")
    let videoUrl = URL.init(fileURLWithPath: moviePath!)
    
    let cor = CutTheVideoViewController2()
    cor.corType = .ForDefault
    cor.videoUrlAry = [videoUrl]
    self.rt_navigationController.pushViewController(cor, animated: true) { (comple) in
      
    }
    
  }
  @IBAction func ClickCutMoreVideoBtn(_ sender: UIButton) {
    
    let moviePath1 = Bundle.main.path(forResource: "test03", ofType: "mp4")
    let videoUrl1 = URL.init(fileURLWithPath: moviePath1!)
    
    let moviePath2 = Bundle.main.path(forResource: "test02", ofType: "mov")
    let videoUrl2 = URL.init(fileURLWithPath: moviePath2!)
    
    let moviePath3 = Bundle.main.path(forResource: "test01", ofType: "mp4")
    let videoUrl3 = URL.init(fileURLWithPath: moviePath3!)
    
    let cor = CutTheVideoViewController2()
    cor.corType = .ForManyPeriodOfVideo
    cor.videoUrlAry = [videoUrl1, videoUrl2, videoUrl3]
    self.rt_navigationController.pushViewController(cor, animated: true) { (comple) in
      
    }
    
  }
  
}

