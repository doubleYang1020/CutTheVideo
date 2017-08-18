//
//  CutVideoCollectionViewCell.swift
//  CutTheVideo
//
//  Created by Hiro Chin on 18/8/2017.
//  Copyright © 2017 huyangyang. All rights reserved.
//

import UIKit

class CutVideoPreviewCell: UICollectionViewCell {
  
  let stackView = UIView()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    //    stackView.axis = .horizontal
    //    stackView.distribution = .fillEqually
    
    stackView.frame = CGRect.init(x: 2, y: 2, width: frame.size.width-4, height: 50)
    self.contentView.addSubview(stackView)
    //    stackView.backgroundColor = UIColor.blue
    //    stackView.frame = CGRect.init(x: 0, y: 2, width: frame.size.width, height: 46)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class CutVideosPreviewCell: UICollectionViewCell {
  
  let stackView = UIView()
  let whiteBgView = UIView()
  
  var blurEffectView :UIVisualEffectView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
    
    
    let blurEffect = UIBlurEffect.init(style: .light)
    self.blurEffectView = UIVisualEffectView.init(effect: blurEffect)
    //    blurEffectView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: 60)
    self.contentView.addSubview(blurEffectView)
    blurEffectView.snp.makeConstraints { (make) -> Void in
      make.top.right.bottom.left.equalTo(self.contentView)
    }
    
    //    stackView.axis = .horizontal
    //    stackView.distribution = .fillEqually
    self.whiteBgView.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    //    self.whiteBgView.frame = CGRect.init(x: 3, y: 3, width: frame.size.width - 6, height: 54)
    self.contentView.addSubview(whiteBgView)
    whiteBgView.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(self.contentView).offset(3)
      make.left.equalTo(self.contentView).offset(3)
      make.bottom.equalTo(self.contentView).offset(-3)
      make.right.equalTo(self.contentView).offset(-3)
    }
    
    stackView.frame = CGRect.init(x: 2, y: 2, width: frame.size.width-4, height: 50)
    self.whiteBgView.addSubview(stackView)
    //    stackView.backgroundColor = UIColor.blue
    //    stackView.frame = CGRect.init(x: 0, y: 2, width: frame.size.width, height: 46)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
