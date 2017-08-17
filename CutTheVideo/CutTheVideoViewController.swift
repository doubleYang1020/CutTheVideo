//
//  CutTheVideoViewController.swift
//  CutTheVideo
//
//  Created by huyangyang on 2017/8/14.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import MediaPlayer
import AVKit
import RAReorderableLayout
fileprivate class CutVideoPreviewCell: UICollectionViewCell {
  
  let VideoKeyFrameImageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.green
  
    self.contentView.addSubview(VideoKeyFrameImageView)
    VideoKeyFrameImageView.contentMode = .scaleAspectFill
    VideoKeyFrameImageView.frame = CGRect.init(x: 0, y: 2, width: 50, height: 46)
    VideoKeyFrameImageView.clipsToBounds = true

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class CutTheVideoViewController: ViewController , RAReorderableLayoutDelegate, RAReorderableLayoutDataSource{

  let movie = MPMoviePlayerController()
  var arry:[UIImage] = [UIImage]()
  var assetSeconds:Int = 0
  
  fileprivate var videoKeyFrameCollectionView : UICollectionView! = nil
  
  private var longPressedAction: (() -> Void)?
  
  private lazy var panGes: UIPanGestureRecognizer! = {
    let panGes = UIPanGestureRecognizer(target: self, action: #selector(pan(ges:)))
    panGes.isEnabled = false
    return panGes
    
  }()
  
  private var snapedImageView: UIView!
  
  /// 正在动画中不要接受新的手势
  private var canRecieveTouch = true
  
  private var currentIndexPath:NSIndexPath?
  
  private var deltaSize: CGSize!
  
  private var showFrame: CGRect!
  private var hideFrame: CGRect! {
    return CGRect(x: 0.0, y: -showFrame.size.height, width: showFrame.size.width, height: showFrame.size.height)
  }
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
//      navigationController?.view.isHidden = false
      navigationController?.setNavigationBarHidden(true, animated: false)
      
//      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//      self.navigationController?.navigationBar.shadowImage = UIImage()

      movie.view.translatesAutoresizingMaskIntoConstraints = false
//      let moviePath = Bundle.main.path(forResource: "test02", ofType: "mov")
      let moviePath = Bundle.main.path(forResource: "test01", ofType: "mp4")
      //      guard let movieUrl = URL.init(fileURLWithPath: moviePath!) else {
      //        return
      //      }
      let asset = AVURLAsset.init(url: URL.init(fileURLWithPath: moviePath!))
      let image = getImage(with: asset, andTime: CMTimeMakeWithSeconds(0, 60))
      
      let bgimageView = UIImageView.init(image: image)

      self.view.addSubview(bgimageView)
      bgimageView.snp.makeConstraints { (make) -> Void in
        make.top.right.bottom.left.equalTo(self.view)
      }
      
//      let movie = MPMoviePlayerController.init(contentURL: URL.init(fileURLWithPath: moviePath!))
      movie.contentURL = URL.init(fileURLWithPath: moviePath!)
      movie.shouldAutoplay = false
//      let movie = AVPlayerViewController.init()

      let assetDuration = asset.duration
      
      
      var arry2:[NSNumber] = [NSNumber]()
      assetSeconds = Int(CMTimeGetSeconds(assetDuration))
      for i in 0...assetSeconds {
//        let time = CMTimeMakeWithSeconds(Float64(i), 60)
//        let time  = CMTimeMake(Int64(i*60), 60)
//        guard let image = getImage(with: asset, andTime: time )else {
//          return;
//        }
//        
//        arry.append(image)

        
  
        arry2.append(NSNumber.init(value: Float(i)))
        
      
//        movie?.thumbnailImage(atTime: TimeInterval(i), timeOption: .exact)
//        arry2.append(image2!)
//        let moviePlayerController = MPMoviePlayerController()
//        moviePlayerController.thumbnailImage(atTime: TimeInterval, timeOption: <#T##MPMovieTimeOption#>)
      
        

        print("xxxxx %d",i);
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(mpMoviePlayerThumbnailImageRequestDidFinishNotification(notification:)), name: Notification.Name.MPMoviePlayerThumbnailImageRequestDidFinish, object: movie)
      
      
      movie.requestThumbnailImages(atTimes:arry2, timeOption: .exact)

      print("OK");
      

      
      
      initCustomNav()
      initCollectionView()
    }
  
  fileprivate func initCollectionView(){
    let layout = RAReorderableLayout()
    layout.itemSize = CGSize.init(width: 50, height: 50)
//    layout.estimatedItemSize = CGSize.init(width: 50, height: 50)
    layout.scrollDirection = .horizontal
//    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
//    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    layout.headerReferenceSize = CGSize.init(width: 2, height: 0)
    
    layout.footerReferenceSize = CGSize.init(width: 2, height: 0)
    
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
//    (videoKeyFrameCollectionView.collectionViewLayout as! RAReorderableLayout).scrollDirection = .horizontal
//    videoKeyFrameCollectionView.addGestureRecognizer(self.panGes)
    
//    let longPressGr = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressed(ges:)))
//    longPressGr.minimumPressDuration = 0.6
//    videoKeyFrameCollectionView.addGestureRecognizer(longPressGr)

    videoKeyFrameCollectionView.clipsToBounds = false
    
  }
  func longPressed(ges: UILongPressGestureRecognizer) {

    panGes.isEnabled = true
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
              arry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index + 1)
            }
          }
          
          if newIndexPath.row < oldIndexPath.row {
            var index = oldIndexPath.row
            for _ in newIndexPath.row..<oldIndexPath.row {
              
              arry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index - 1)
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
                if currentIndexPath?.row != arry.count - 1 {
        videoKeyFrameCollectionView.scrollToItem(at: IndexPath.init(row: (currentIndexPath?.row)! + 1, section: (currentIndexPath?.section)!), at: .left, animated: true)
        
                }
      }
      
      if (ges.view?.center.x)! + location.x  < 25 {
        if currentIndexPath?.row != 0 {
          videoKeyFrameCollectionView.scrollToItem(at: IndexPath.init(row: (currentIndexPath?.row)!  - 1, section: (currentIndexPath?.section)!), at: .right, animated: true)
          
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
  
  func pan(ges: UIPanGestureRecognizer) {
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
        snapedImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
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
              arry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index + 1)
            }
          }
          
          if newIndexPath.row < oldIndexPath.row {
            var index = oldIndexPath.row
            for _ in newIndexPath.row..<oldIndexPath.row {
              
              arry.zj_exchangeObjectAtIndex(index: index, withObjectAtIndex: index - 1)
              index -= 1
            }
          }
          
          videoKeyFrameCollectionView.moveItem(at: oldIndexPath as IndexPath, to: newIndexPath)
          
          
          let cell = videoKeyFrameCollectionView.cellForItem(at: newIndexPath)
          cell?.alpha = 0.0
          currentIndexPath = newIndexPath as NSIndexPath
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
  
  // 截图
  func getTheCellSnap(targetView: UIView) -> UIImageView {
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, 0.0)
    
    targetView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let gottenImageView = UIImageView(image: image)
    
    return gottenImageView
  }
  
  func show() {
    
//    frame = hideFrame
//    UIView.animateWithDuration(0.3, animations: {[unowned self] in
//      self.frame = self.showFrame
//      
//    }) { (_) in
//      
//    }
    
  }
  
  func hide() {
    
//    UIView.animateWithDuration(0.3, animations: {
//      self.frame = self.hideFrame
//      
//    }) {[unowned self] (_) in
//      
//      self.removeFromSuperview()
//    }
  }
  
  // MARK: collectionView delegate
//  func numberOfSections(in collectionView: UICollectionView) -> Int {
//
//    return 1
//    
//  }
//  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return arry.count
//  }
//  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cutVideoPreviewCell", for: indexPath) as! CutVideoPreviewCell
//    
//    cell.VideoKeyFrameImageView.image = arry[indexPath.row]
//    
//
//    return cell
//  }
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//   
//  }
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
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arry.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 50.0, height: 50.0)
  }
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//    return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
//  }
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 20.0
//  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cutVideoPreviewCell", for: indexPath) as! CutVideoPreviewCell
    
        cell.VideoKeyFrameImageView.image = arry[indexPath.row]
    
    
        return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {
    let book = arry.remove(at: (at as NSIndexPath).item)
    arry.insert(book, at: (toIndexPath as NSIndexPath).item)
  }
  
  func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 50, 0, 50)
  }
  
  func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
    return 15.0
  }
  

  
//  func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
//    return UIEdgeInsetsMake(0, 50, 0, 50)
//  }
//  
//  func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
//    return 15.0
//  }
//  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    return CGSize(width: 130.0, height: 170.0)
//  }
//  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//    return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
//  }
//  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 20.0
//  }
  
  
  
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
    
    arry.append(image)
    if arry.count ==  assetSeconds+1{
      print("MPMoviePlayerThumbnailImageRequestDidFinishNotification");
      videoKeyFrameCollectionView.reloadData()
      videoKeyFrameCollectionView.contentInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.size.width/2, 0, 0)
    }
    
    
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
//  fileprivate func getImage(with url:URL, andTime:CMTime) -> UIImage? {
//    let asset = AVURLAsset.init(url: url)
//    let gen = AVAssetImageGenerator.init(asset: asset)
//    gen.appliesPreferredTrackTransform = true
//    //    let time = CMTimeMakeWithSeconds(0.0, 60)
//    guard let image = try? gen.copyCGImage(at: andTime, actualTime: .none) else {
//      return .none
//    }
//    let thumb = UIImage.init(cgImage: image)
//    return thumb
//  }
  
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
  

  
  @objc private func back(){
    self.navigationController?.popViewController(animated: true)

    
  }
  @objc private func clickSaveBtn(){

    
    
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Array {
  mutating func zj_exchangeObjectAtIndex(index: Int, withObjectAtIndex newIndex: Int) {
    let temp = self[index]
    self[index] = self[newIndex]
    self[newIndex] = temp
  }
}
