//
//  CutTheVideoViewController3.swift
//  CutTheVideo
//
//  Created by huyangyang on 2017/8/15.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

import UIKit
import MediaPlayer
import RAReorderableLayout
fileprivate class CutVideoPreviewCell: UICollectionViewCell {
  
  let stackView = UIView()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.green
    //    stackView.axis = .horizontal
    //    stackView.distribution = .fillEqually
    
    stackView.frame = CGRect.init(x: 2, y: 2, width: frame.size.width-4, height: 46)
    self.contentView.addSubview(stackView)
    //    stackView.backgroundColor = UIColor.blue
    //    stackView.frame = CGRect.init(x: 0, y: 2, width: frame.size.width, height: 46)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class CutTheVideoViewController3: UIViewController , UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

  let movie = MPMoviePlayerController()
  var dataAry : [[UIImage]] = [[UIImage]]()
  var imgArry : [UIImage] =  [UIImage]()
  var assetSeconds:Int = 0
  fileprivate var videoKeyFrameCollectionView : UICollectionView! = nil
  let btnBgView = UIView()
  let scissorsBtn = UIButton()
  let lineView = UIView()
  let roundView = UIView()
  
  
  private var snapedImageView: UIView!
  
  /// 正在动画中不要接受新的手势
  private var canRecieveTouch = true
  
  private var currentIndexPath:NSIndexPath?
  
  private var deltaSize: CGSize!
  
  override func viewDidLoad() {
      super.viewDidLoad()

    
    navigationController?.setNavigationBarHidden(true, animated: false)
    
    initVideoKeyFrameData()
    initCustomNav()
    initCollectionView()
    initUI()
      // Do any additional setup after loading the view.
  }
  
  fileprivate func initUI(){
    btnBgView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    btnBgView.layer.cornerRadius = 34/2
    self.view.addSubview(btnBgView)
    btnBgView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(self.view).offset(-5)
      make.width.height.equalTo(34)
      make.centerX.equalTo(self.view)
    }
    
    scissorsBtn.setImage(UIImage.init(named: "ic_videocut"), for: .normal)
    scissorsBtn.backgroundColor = UIColor.clear
    self.view.addSubview(scissorsBtn)
    scissorsBtn.snp.makeConstraints { (make) -> Void in
      make.center.equalTo(btnBgView)
      make.width.height.equalTo(24)
    }
    scissorsBtn.addTarget(self, action: #selector(clickCutBtn), for: .touchUpInside)
    
    lineView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    self.view.addSubview(lineView)
    lineView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(btnBgView.snp.top)
      make.width.equalTo(1.5)
      make.height.equalTo(75.5)
      make.centerX.equalTo(self.view)
    }
    lineView.isUserInteractionEnabled = false
    
    roundView.backgroundColor = UIColor.init(red: 0, green: 171.0/255, blue: 255.0/255, alpha: 1)
    roundView.layer.cornerRadius = 3.25
    self.view.addSubview(roundView)
    roundView.snp.makeConstraints { (make) -> Void in
      make.bottom.equalTo(lineView.snp.top)
      make.centerX.equalTo(self.view)
      make.width.height.equalTo(6.5)
    }
    
  }
  fileprivate func initVideoKeyFrameData(){
    movie.view.translatesAutoresizingMaskIntoConstraints = false
    //      let moviePath = Bundle.main.path(forResource: "test02", ofType: "mov")
    let moviePath = Bundle.main.path(forResource: "test01", ofType: "mp4")
    let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: moviePath!))
    let image = getImage(with: asset, andTime: CMTimeMakeWithSeconds(0, 60))
    let bgimageView = UIImageView.init(image: image)
    self.view.addSubview(bgimageView)
    bgimageView.snp.makeConstraints { (make) -> Void in
      make.top.right.bottom.left.equalTo(self.view)
    }
    
    
    movie.contentURL = URL.init(fileURLWithPath: moviePath!)
    movie.shouldAutoplay = false
    
    
    let assetDuration = asset.duration
    
    
    var arry2:[NSNumber] = [NSNumber]()
    assetSeconds = Int(CMTimeGetSeconds(assetDuration))
    for i in 0...assetSeconds {
      arry2.append(NSNumber.init(value: Float(i)))
      print("xxxxx %d",i);
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(mpMoviePlayerThumbnailImageRequestDidFinishNotification(notification:)), name: Notification.Name.MPMoviePlayerThumbnailImageRequestDidFinish, object: movie)
    
    
    movie.requestThumbnailImages(atTimes:arry2, timeOption: .exact)
    
    print("OK");
  }
  
  fileprivate func initCustomNav(){
    self.view.backgroundColor = UIColor.black
    
    let img = UIImage.init(named: "nav-bg")
    let bgView=UIImageView(image: img)
    self.view.addSubview(bgView)
    bgView.snp.makeConstraints { (make) in
      make.top.left.right.equalTo(self.view)
      make.height.equalTo(40)
    }
    
    let backBtn = UIButton()
    
    backBtn.setImage(UIImage.init(named: "video_Shadowback"), for: .normal)
    
    
    
    backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
    self.view.addSubview(backBtn)
    backBtn.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(self.view).offset(10)
      make.left.equalTo(self.view).offset(12)
      make.width.height.equalTo(24)
    }
    
    let saveBtn = UIButton()
    saveBtn.setTitle("保存", for: .normal)
    saveBtn.titleLabel?.font = UIFont.init(name: "PingFangSC-Regular", size: 14)
    saveBtn.setTitleColor(UIColor.white, for: .normal)
    saveBtn.addTarget(self, action: #selector(clickSaveBtn), for: .touchUpInside)
    self.view.addSubview(saveBtn)
    saveBtn.snp.makeConstraints { (make) -> Void in
      make.width.equalTo(52)
      make.height.equalTo(40)
      make.top.right.equalTo(self.view)
    }
    
    let titleLabel = UILabel.init()
    titleLabel.backgroundColor = UIColor.clear;
    titleLabel.text = "视频剪辑"
    titleLabel.textColor = UIColor.white
    titleLabel.font = UIFont(name: "PingFangSC-Semibold", size: 14)
    titleLabel.textAlignment = NSTextAlignment.left
    //    titleLabel.addShadow(ofColor: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5), radius: 2, offset: CGSize(width:0,height:1), opacity: 0.5)
    self.view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints({ (make) -> Void in
      
      make.centerX.equalTo(self.view)
      make.centerY.equalTo(saveBtn)
    })
    
    
    
    
    
    //    musicCancleBtn.imageEdgeInsets = UIEdgeInsetsMake(4, 3, 4, 3)
    
    
  }
  
  fileprivate func initCollectionView(){
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize.init(width: 50, height: 50)
    //    layout.estimatedItemSize = CGSize.init(width: 50, height: 50)
    layout.scrollDirection = .horizontal
    //    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    //    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    layout.headerReferenceSize = CGSize.init(width: 0, height: 0)
    
    layout.footerReferenceSize = CGSize.init(width: UIScreen.main.bounds.size.width/2 - 50, height: 0)
    
    videoKeyFrameCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: 50), collectionViewLayout: layout)
    self.view.addSubview(videoKeyFrameCollectionView)
    
    videoKeyFrameCollectionView.backgroundColor = UIColor.clear
    videoKeyFrameCollectionView.delegate = self
    videoKeyFrameCollectionView.dataSource = self
    // 注册cell
    videoKeyFrameCollectionView.register(CutVideoPreviewCell.self, forCellWithReuseIdentifier: "cutVideoPreviewCell")
    videoKeyFrameCollectionView.showsHorizontalScrollIndicator = false
    videoKeyFrameCollectionView.showsVerticalScrollIndicator = false
    videoKeyFrameCollectionView.alwaysBounceHorizontal = true
    
    // 注册头视图
    videoKeyFrameCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionViewHeader")
    videoKeyFrameCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionViewFooter")
    
    //设置是否需要弹簧效果
    videoKeyFrameCollectionView.bounces = true
    videoKeyFrameCollectionView.clipsToBounds = false
    
    let longPressGr = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressed(ges:)))
    longPressGr.minimumPressDuration = 0.6
    videoKeyFrameCollectionView.addGestureRecognizer(longPressGr)
    
  }
  
  func longPressed(ges: UILongPressGestureRecognizer) {
    
//    panGes.isEnabled = true
    //    videoKeyFrameCollectionView.reloadData()
    
    
    guard canRecieveTouch else { return }
    
    let location = ges.location(in: self.videoKeyFrameCollectionView)
    // 当手指的位置不在collectionView的cell范围内时为nil
    let notSureIndexPath = self.videoKeyFrameCollectionView.indexPathForItem(at: location)
    switch ges.state {
    case .began:
      if let indexPath = notSureIndexPath { // 获取到的indexPath是有效的, 可以放心使用
        // 不要移动第一个 和只移动第一个section
        /*if indexPath.row == 0 || indexPath.section != 0 { return }*/
        
        currentIndexPath = indexPath as NSIndexPath
        let cell = videoKeyFrameCollectionView.cellForItem(at: indexPath)!
        snapedImageView = getTheCellSnap(targetView: cell)
        
        deltaSize = CGSize(width: location.x - cell.frame.origin.x, height: location.y - cell.frame.origin.y)
        
        snapedImageView.center = cell.center
        //        snapedImageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        snapedImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        cell.alpha = 0.0
        
        videoKeyFrameCollectionView.addSubview(snapedImageView)
      }
    case .changed:
      if snapedImageView == nil { return }
      // 同步改变位置
      //            snapedImageView.center = location
      snapedImageView.frame.origin.x = location.x - deltaSize.width
      snapedImageView.frame.origin.y = location.y - deltaSize.height
      
      
      
      if let newIndexPath = notSureIndexPath, let oldIndexPath = currentIndexPath {
        if newIndexPath != oldIndexPath as IndexPath && newIndexPath.section == oldIndexPath.section /*&& newIndexPath.row != 0*/ {// 只在同一组中移动且第一个不动
          
          // 更新数据源
          if newIndexPath.row > oldIndexPath.row {
            for index in oldIndexPath.row..<newIndexPath.row {
              dataAry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index + 1)
            }
          }
          
          if newIndexPath.row < oldIndexPath.row {
            var index = oldIndexPath.row
            for _ in newIndexPath.row..<oldIndexPath.row {
              
              dataAry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index - 1)
              index -= 1
            }
          }
          
          videoKeyFrameCollectionView.moveItem(at: oldIndexPath as IndexPath, to: newIndexPath)
          
          
          
          let cell = videoKeyFrameCollectionView.cellForItem(at: newIndexPath)
          cell?.alpha = 0.0
          currentIndexPath = newIndexPath as NSIndexPath
        }
        
      }
      
      if (ges.view?.center.x)! + location.x  > UIScreen.main.bounds.size.width-25 {
        if currentIndexPath?.row != dataAry.count - 1 {
          videoKeyFrameCollectionView.scrollToItem(at: IndexPath.init(row: (currentIndexPath?.row)! + 1, section: (currentIndexPath?.section)!), at: .left, animated: true)
//          videoKeyFrameCollectionView.setContentOffset(CGPoint.init(x: videoKeyFrameCollectionView.contentOffset.x+50, y: 0), animated: true)
          
        }
      }
      
      if (ges.view?.center.x)! + location.x  < 25 {
        if currentIndexPath?.row != 0 {
          videoKeyFrameCollectionView.scrollToItem(at: IndexPath.init(row: (currentIndexPath?.row)!  - 1, section: (currentIndexPath?.section)!), at: .right, animated: true)
//          videoKeyFrameCollectionView.setContentOffset(CGPoint.init(x: videoKeyFrameCollectionView.contentOffset.x-50, y: 0), animated: true)
          
        }
      }
      
    case .ended :
      
      if let oldIndexPath = currentIndexPath {
        let cell = videoKeyFrameCollectionView.cellForItem(at: oldIndexPath as IndexPath)!
        
        UIView.animate(withDuration: 0.25, animations: {[unowned self] in
          self.snapedImageView.transform = CGAffineTransform.identity
          self.snapedImageView.frame = cell.frame
          self.canRecieveTouch = false
          }, completion: {[unowned self] (_) in
            self.snapedImageView.removeFromSuperview()
            self.snapedImageView = nil
            self.currentIndexPath = nil
            cell.alpha = 1.0
            self.canRecieveTouch = true
            
            
        })
      }
    default:
      // 恢复初始状态
      snapedImageView = nil
      currentIndexPath = nil
      canRecieveTouch = true
      
    }
    
    
  }

  
  fileprivate func getImage(with asset:AVURLAsset, andTime:CMTime) -> UIImage? {
    let gen = AVAssetImageGenerator.init(asset: asset)
    gen.appliesPreferredTrackTransform = true
    //    let time = CMTimeMakeWithSeconds(0.0, 60)
    guard let image = try? gen.copyCGImage(at: andTime, actualTime: .none) else {
      return .none
    }
    let thumb = UIImage.init(cgImage: image)
    return thumb
  }
  
  // MARK: MPMoviePlayerThumbnailImageRequestDidFinishNotification Notification
  @objc fileprivate func mpMoviePlayerThumbnailImageRequestDidFinishNotification(notification: Notification) -> ()
  {
    //    NSNumber *timecode =[userInfo objectForKey: @"MPMoviePlayerThumbnailTimeKey"];
    //
    //    UIImage *image =[userInfo objectForKey: @"MPMoviePlayerThumbnailImageKey"];
    guard let info = notification.userInfo else {
      return
    }
    
    
    
    let timeCode = info["MPMoviePlayerThumbnailTimeKey"] as! Float
    
    let image = info["MPMoviePlayerThumbnailImageKey"] as! UIImage;
    
    imgArry.append(image)
    if imgArry.count ==  assetSeconds+1{
      print("MPMoviePlayerThumbnailImageRequestDidFinishNotification");
      dataAry.append(imgArry)
      
      videoKeyFrameCollectionView.reloadData()
      videoKeyFrameCollectionView.contentInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.size.width/2, 0, 0)
    }
    
    
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
//   MARK: collectionView delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
  
      return 1
  
    }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataAry.count
  }
  
  

  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: 50 * dataAry[indexPath.row].count + 4, height: 50)
    }
  

  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cutVideoPreviewCell", for: indexPath) as! CutVideoPreviewCell
  
      cell.stackView.subviews.map({$0.removeFromSuperview()})//.apply { $0.removeFromSuperview() }
      
      
      
      let imageAry = dataAry[indexPath.row]
      for i in 0..<imageAry.count {
        let imageView = UIImageView.init(frame: CGRect.init(x: 50 * CGFloat(i) , y: 0, width: 50, height: 46))
        imageView.image = imageAry[i]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        //      cell.stackView.addArrangedSubview(imageView)
        cell.stackView.addSubview(imageView)
      }
      
      
      return cell
  
  
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      print("xxxxx")
    }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    print("viewForSupplementaryElementOfKind  \(kind)")
    if kind ==  UICollectionElementKindSectionHeader{
      let headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionViewHeader", for: indexPath)
      headView.backgroundColor = UIColor.green
      return headView
    }else{
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionViewFooter", for: indexPath)
      footerView.backgroundColor = UIColor.green
      return footerView
    }
  }
  

  
  // 截图
  func getTheCellSnap(targetView: UIView) -> UIImageView {
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, 0.0)
    
    targetView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let gottenImageView = UIImageView(image: image)
    
    return gottenImageView
  }
  
  @objc private func back(){
    self.navigationController?.popViewController(animated: true)
    
    
  }
  @objc private func clickCutBtn(){
    print("clickCutBtn")
    let offsetX = videoKeyFrameCollectionView.contentOffset.x - (-(UIScreen.main.bounds.size.width/2))
    let a = offsetX/50
    
    let itemAry : [UIImage] = dataAry.first!
    
    var arya : [UIImage] =  [UIImage]() ; var aryb : [UIImage] =  [UIImage]()
    
    for i in 0..<itemAry.count {
      
      if i < Int(a){
        arya.append(itemAry[i])
      }else{
        aryb.append(itemAry[i])
      }
    }
    dataAry[0] = arya
    dataAry.append(aryb)
    
    videoKeyFrameCollectionView.reloadData()
    print("clickCutBtn \(offsetX)")
    
    
  }
  
  @objc private func clickSaveBtn(){
    
    
    
  }
  


}

//extension Array {
//  mutating func zj_exchangeObjectAtIndex(index: Int, withObjectAtIndex newIndex: Int) {
//    let temp = self[index]
//    self[index] = self[newIndex]
//    self[newIndex] = temp
//  }
//}
