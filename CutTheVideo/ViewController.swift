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
    self.rt_navigationController.pushViewController(CutTheVideoViewController2(), animated: true) { (comple) in
      
    }
    
  }
  @IBAction func ClickCutMoreVideoBtn(_ sender: UIButton) {
    
    
    let cor = CutTheVideoViewController2()
    cor.corType = .ForManyPeriodOfVideo
    self.rt_navigationController.pushViewController(cor, animated: true) { (comple) in
      
    }
    
  }

}

