//
//  CustomScissorsView.swift
//  CutTheVideo
//
//  Created by huyangyang on 2017/8/15.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

import UIKit
import SnapKit
class CustomScissorsView: UIView {


  let screenWidth = UIScreen.main.bounds.width
  let screenHeight = UIScreen.main.bounds.height
  
  let btnBgView = UIView()
  let scissorsBtn = UIButton()
  let lineView = UIView()
  let roundView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
    setupSubviews()
  }
  
  convenience init() {
    self.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupSubviews()
  }
  // height 2
  private func setupSubviews() {
    
//    self.isUserInteractionEnabled = false
// 0 171 255
    btnBgView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    btnBgView.layer.cornerRadius = 34/2
    self.addSubview(btnBgView)
    btnBgView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(self).offset(-5)
      make.width.height.equalTo(34)
      make.centerX.equalTo(self)
    }
    
    scissorsBtn.setImage(UIImage.init(named: "ic_videocut"), for: .normal)
    scissorsBtn.backgroundColor = UIColor.clear
    self.addSubview(scissorsBtn)
    scissorsBtn.snp.makeConstraints { (make) -> Void in
      make.center.equalTo(btnBgView)
      make.width.height.equalTo(24)
    }
    
    lineView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    self.addSubview(lineView)
    lineView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(btnBgView.snp.top)
      make.width.equalTo(1.5)
      make.height.equalTo(75.5)
      make.centerX.equalTo(self)
    }
    
    roundView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    roundView.layer.cornerRadius = 3.25
    self.addSubview(roundView)
    roundView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(lineView.snp.top)
      make.centerX.equalTo(self)
      make.width.height.equalTo(6.5)
    }
    
    
  }
  
  


}
