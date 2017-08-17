//
//  CutTheVideoViewController2.swift
//  CutTheVideo
//
//  Created by huyangyang on 2017/8/15.
//  Copyright © 2017年 huyangyang. All rights reserved.
//

import ReSwift
import UIKit
import MediaPlayer
//import RAReorderableLayout
//import FDStackView


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

class CutTheVideoItemInfo: NSObject {
  var imageAry:[UIImage] = [UIImage]()
  var isShowGriddingShade : Bool = false
}




class CutTheVideoViewController2: ViewController , RAReorderableLayoutDelegate, RAReorderableLayoutDataSource{

  
  let movie = MPMoviePlayerController()
  
//  var dataAry : [[UIImage]] = [[UIImage]]()
  
  var dataAry : [CutTheVideoItemInfo] = [CutTheVideoItemInfo]()
  var imgArry : [UIImage] =  [UIImage]()
  
  var temporary: [UIImage] = [UIImage]()
  
  var assetSeconds:Int = 0
  fileprivate var videoKeyFrameCollectionView : UICollectionView! = nil
//  fileprivate let scissorView = CustomScissorsView.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width/2 - 17, y: UIScreen.main.bounds.size.height - 115, width: 34, height: 115))
  
  let btnBgView = UIView()
  let scissorsBtn = UIButton()
  let undoButton = UIButton()
  let lineView = UIView()
  let roundView = UIView()
  
  var isLongPrecess :Bool = false
  var longPrescessCellIndex :IndexPath = IndexPath.init(row: 0, section: 0)
		
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.setNavigationBarHidden(true, animated: false)


    
    initVideoKeyFrameData()
    
    let gradientImageView = UIImageView.init()
    gradientImageView.image = UIImage.init(named: "black-gradient")
    //    UIViewContentModeScaleToFill
    gradientImageView.contentMode = .scaleToFill
    self.view.addSubview(gradientImageView)
    gradientImageView.snp.makeConstraints { (make) -> Void in
      make.left.bottom.right.equalTo(self.view)
      make.height.equalTo(170)
    }
    
    initCustomNav()
    initCollectionView()
    initUI()
    
//    self.view.addSubview(scissorView)
    
      // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.subscribe(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.unsubscribe(self)
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
    
    undoButton.setTitle("U", for: .normal)
    undoButton.addTarget(self, action: #selector(undoButtonAction(button:)), for: .touchUpInside)
    view.addSubview(undoButton)
    undoButton.snp.makeConstraints { maker in
      maker.width.height.equalTo(34)
      maker.bottom.equalTo(self.view).offset(-5)
      maker.right.equalTo(self.view).offset(-5)
    }
    
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
          let moviePath = Bundle.main.path(forResource: "test02", ofType: "mov")
//    let moviePath = Bundle.main.path(forResource: "test01", ofType: "mp4")
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
    let layout = RAReorderableLayout()
    layout.itemSize = CGSize.init(width: 50, height: 54)
    //    layout.estimatedItemSize = CGSize.init(width: 50, height: 50)
    layout.scrollDirection = .horizontal
    //    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    //    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 10
    
    layout.headerReferenceSize = CGSize.init(width: 0, height: 0)
    
    layout.footerReferenceSize = CGSize.init(width: UIScreen.main.bounds.size.width/2 - 54, height: 0)
    
    videoKeyFrameCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: 54), collectionViewLayout: layout)
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
      
      let itemInfo = CutTheVideoItemInfo.init()
      itemInfo.imageAry = imgArry
      itemInfo.isShowGriddingShade = false
      dataAry.append(itemInfo)
      
      videoKeyFrameCollectionView.reloadData()
      videoKeyFrameCollectionView.contentInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.size.width/2, 0, 0)
    }
    
    
    
  }
  
  
  // MARK: collectionView delegate
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    print("viewForSupplementaryElementOfKind  \(kind)")
    if kind ==  UICollectionElementKindSectionHeader{
      let headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UICollectionViewHeader", for: indexPath)
      headView.backgroundColor = UIColor.green
      return headView
    }else{
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "UICollectionViewFooter", for: indexPath)
      footerView.backgroundColor = UIColor.clear
      return footerView
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataAry.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
//    if longPrescessCellIndex.row == indexPath.row  && isLongPrecess{
//      return CGSize(width: 50  + 4, height: 50)
//    }else{
//      return CGSize(width: 50 * dataAry[indexPath.row].count + 4, height: 50)
//    }
    
    return CGSize(width: 50 * dataAry[indexPath.row].imageAry.count + 4, height: 54)
    
    
  }
  
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
  //    return UIEdgeInsetsMake(0, 20.0, 0, 20.0)
  //  }
  
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
  //    return 20.0
  //  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cutVideoPreviewCell", for: indexPath) as! CutVideoPreviewCell
    
    cell.stackView.subviews.map({$0.removeFromSuperview()})//.apply { $0.removeFromSuperview() }
    

//    if longPrescessCellIndex.row == indexPath.row && isLongPrecess {
//      let imageAry = dataAry[indexPath.row]
//      let imageView = UIImageView.init(frame: CGRect.init(x: 0 , y: 0, width: 50, height: 46))
//      imageView.image = imageAry.first
//      imageView.contentMode = .scaleAspectFill
//      imageView.clipsToBounds = true
//      cell.stackView.addSubview(imageView)
//    }else{
//      let imageAry = dataAry[indexPath.row]
//      for i in 0..<imageAry.count {
//        let imageView = UIImageView.init(frame: CGRect.init(x: 50 * CGFloat(i) , y: 0, width: 50, height: 46))
//        imageView.image = imageAry[i]
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        //      cell.stackView.addArrangedSubview(imageView)
//        cell.stackView.addSubview(imageView)
//      }
//      
//    }
    
    
    let imageAry = dataAry[indexPath.row].imageAry
    let isShowGriddingShade = dataAry[indexPath.row].isShowGriddingShade
    for i in 0..<imageAry.count {
      let imageView = UIImageView.init(frame: CGRect.init(x: 50 * CGFloat(i) , y: 0, width: 50, height: 50))
      imageView.image = imageAry[i]
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
      //      cell.stackView.addArrangedSubview(imageView)
      cell.stackView.addSubview(imageView)
//     imageName icHidemask
      if isShowGriddingShade {
        let griddingShadeImageView = UIImageView.init(frame: imageView.frame)
        griddingShadeImageView.image = UIImage.init(named: "icHidemask")
        griddingShadeImageView.contentMode = .scaleAspectFill
        griddingShadeImageView.clipsToBounds = true
        cell.stackView.addSubview(griddingShadeImageView)
        
        cell.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.5)
        imageView.alpha = 0.5
        
      }else{
        cell.backgroundColor = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
      }
      
      
      
    }
    
    

    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    clickCell(at: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, at: IndexPath, willMoveTo toIndexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, at: IndexPath, didMoveTo toIndexPath: IndexPath) {
    let book = dataAry.remove(at: (at as NSIndexPath).item)
    dataAry.insert(book, at: (toIndexPath as NSIndexPath).item)
    store.dispatch(
      Actions.AddUndoOperation(operation:
        UndoHistory.Operation.Rearrange(from: at, to: toIndexPath)
      )
    )
  }
  
  func scrollTrigerEdgeInsetsInCollectionView(_ collectionView: UICollectionView) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 50, 0, 50)
  }
  
  func scrollSpeedValueInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
    return 15.0
  }
  
  func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willBeginDraggingItemAt indexPath: IndexPath) {
//    isLongPrecess = true
  }
  
  
  func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, willBeginLongPrecessItemAt indexPath: IndexPath) {
    
    if isLongPrecess == false {
      print("willBeginLongPrecessItemAt")
      longPrescessCellIndex = indexPath
      temporary  = dataAry[indexPath.row].imageAry
      
      dataAry[indexPath.row].imageAry = [temporary.first!]
      isLongPrecess = true
      self.videoKeyFrameCollectionView.reloadItems(at: [indexPath])
      
    }

  }
  
  
  func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didEndDraggingItemTo indexPath: IndexPath) {
    isLongPrecess = false
    dataAry[indexPath.row].imageAry = temporary
    self.videoKeyFrameCollectionView.reloadItems(at: [indexPath])
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isLongPrecess {
      return
    }
    setCutBtnViewStateForCanNotDoing()
    print("scrollViewDidScroll \(scrollView.contentOffset.x)")
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    print("scrollViewDidEndScrollingAnimation")
    
    self.detectionCutBtnViewsState()
    
//    let arryIndex = getCurrentAryIndex()
//    let offsetX = scrollView.contentOffset.x + (UIScreen.main.bounds.size.width/2)
//    
//    var offSetX2 : CGFloat = 0.0
//    
//    for i in 0...arryIndex {
//      
//      let arry = dataAry[i].imageAry
//      offSetX2 = CGFloat(arry.count*50 + 14) + offSetX2
//    }
//    
//    if offsetX == offSetX2 - 12 || offsetX == offSetX2 - 5 || offsetX == offSetX2 - CGFloat(12) - CGFloat(dataAry[arryIndex].imageAry.count)*CGFloat(50) {
//      print("落点在头在尾")
//      setCutBtnViewStateForCanNotDoing()
//      
//    }else{
//      setCutBtnViewStateForCanDoing()
//      print("落点在中间")
//    }
    
    
    
    
    
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    if isLongPrecess {
      return
    }
    
    if decelerate {
      
      print("scrollViewDidEndDragging \(scrollView.contentOffset.x)")
//      videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet(scrollView: scrollView)
      
    }else{
      print("scrollViewDidEndDragging decelerate is false \(scrollView.contentOffset.x)")
      videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet(scrollView: scrollView)
    }
    
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    if isLongPrecess {
      return
    }
      print("scrollViewDidEndDecelerating \(scrollView.contentOffset.x)")
    
    videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet(scrollView: scrollView)
  }
  
  func getCurrentAryIndex() -> (Int){
    var i = 0
    var currentOffSetX = 0.0
    while CGFloat(currentOffSetX) < videoKeyFrameCollectionView.contentOffset.x  + UIScreen.main.bounds.size.width/2{
      let arry = dataAry[i].imageAry
      currentOffSetX = Double(arry.count*50 + 14) + currentOffSetX
      
      i += 1
    }
    
    if i>=1 {
      i -= 1
    }
    return i
  }
  
  func videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet(scrollView: UIScrollView)  {
    // start -187.5  cell width = 2+ 50*i
    
//    dataAry
    
    let i = getCurrentAryIndex()
    
    
    
    
    let offsetX = scrollView.contentOffset.x - (-(UIScreen.main.bounds.size.width/2)) - 2 - CGFloat(i*(14))
    let a = offsetX.truncatingRemainder(dividingBy: 50)
    if a>25 {
      print("videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet \(a)")
      scrollView.setContentOffset(CGPoint.init(x: scrollView.contentOffset.x + (50 - a)  , y: 0), animated: true)
    }else{
      print("videoKeyFrameCollectionViewScrolleToCorrectContentOfFSet \(a)")
      scrollView.setContentOffset(CGPoint.init(x: scrollView.contentOffset.x - a , y: 0) , animated: true)
    }
  }
  
  func setCutBtnViewStateForCanDoing() {
    btnBgView.alpha = 1
    scissorsBtn.alpha = 1
    scissorsBtn.isEnabled = true
    lineView.alpha = 1
    roundView.alpha = 1
  }
  
  func setCutBtnViewStateForCanNotDoing() {
    btnBgView.alpha = 0.5
    scissorsBtn.alpha = 0.5
    scissorsBtn.isEnabled = false
    lineView.alpha = 0.5
    roundView.alpha = 0.5
  }
  
  fileprivate func detectionCutBtnViewsState() {
    let indexPath = getCurrentAryIndex()
    let itemInfo = dataAry[indexPath]
    if itemInfo.isShowGriddingShade {
      // btn 不可用
      setCutBtnViewStateForCanNotDoing()
      return
    }else{
      setCutBtnViewStateForCanDoing()
    }
    
    
        let offsetX = videoKeyFrameCollectionView.contentOffset.x + (UIScreen.main.bounds.size.width/2)
    
        var offSetX2 : CGFloat = 0.0
    
        for i in 0...indexPath {
    
          let arry = dataAry[i].imageAry
          offSetX2 = CGFloat(arry.count*50 + 14) + offSetX2
        }
    
        if offsetX == offSetX2 - 12 || offsetX == offSetX2 - 5 || offsetX == offSetX2 - CGFloat(12) - CGFloat(dataAry[indexPath].imageAry.count)*CGFloat(50) {
          print("落点在头在尾")
          setCutBtnViewStateForCanNotDoing()
    
        }else{
          setCutBtnViewStateForCanDoing()
          print("落点在中间")
        }
    
    
    
    
  }
  
  
  
  @objc private func back(){
    self.navigationController?.popViewController(animated: true)
    
    
  }

  
  fileprivate func clickCell(at indexPath: IndexPath){
    
    let alertController = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
    
    let isShowGriddingShade = dataAry[indexPath.row].isShowGriddingShade
    let firstTitleStr  = isShowGriddingShade ? "显示视频" : "隐藏视频"
    
    let showOrHiddenAction = UIAlertAction(title: firstTitleStr, style: .default, handler:{
      (UIAlertAction) -> Void in
      
      if isShowGriddingShade {
        // 隐藏 GriddingShade
        let cutVideoItemInfo = self.dataAry[indexPath.row]
        cutVideoItemInfo.isShowGriddingShade = false
        self.dataAry[indexPath.row] = cutVideoItemInfo
        
        
      }else{
        // 显示 GriddingShade
        let cutVideoItemInfo = self.dataAry[indexPath.row]
        cutVideoItemInfo.isShowGriddingShade = true
        self.dataAry[indexPath.row] = cutVideoItemInfo
      }
      
      self.videoKeyFrameCollectionView.reloadItems(at: [indexPath])
      
      self.detectionCutBtnViewsState()
      

    })
    let deleatAction = UIAlertAction(title: "删除视频", style: .destructive, handler: {
      (UIAlertAction) -> Void in
      
      self.dataAry.remove(at: indexPath.row)
      self.videoKeyFrameCollectionView.deleteItems(at: [indexPath])
      self.detectionCutBtnViewsState()
    })
    
    let cancelAction = UIAlertAction(title: "取消", style: .default, handler: {
      (UIAlertAction) -> Void in
    })
    
    alertController.addAction(showOrHiddenAction)
    alertController.addAction(deleatAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  
  @objc private func clickCutBtn(){
    print("clickCutBtn")
    
    let x = getCurrentAryIndex()

    
//    let offsetX = videoKeyFrameCollectionView.contentOffset.x - (-(UIScreen.main.bounds.size.width/2))
    
    let cellFrame = videoKeyFrameCollectionView.cellForItem(at: IndexPath.init(row: x, section: 0))?.frame
    
    let offsetX = videoKeyFrameCollectionView.contentOffset.x - (-(UIScreen.main.bounds.size.width/2)) - (cellFrame?.origin.x)!
    let a = offsetX/50
    
    let itemAry : [UIImage] = dataAry[x].imageAry

    var arya : [UIImage] =  [UIImage]() ; var aryb : [UIImage] =  [UIImage]()
    
    for i in 0..<itemAry.count {
    
      if i < Int(a){
        arya.append(itemAry[i])
      }else{
        aryb.append(itemAry[i])
      }
    }
    
    dataAry[x].imageAry = arya
    
    let itemtInfo = CutTheVideoItemInfo.init()
    itemtInfo.imageAry = aryb
    itemtInfo.isShowGriddingShade = false
    
    if dataAry.count - 1 > x {
      

      
      dataAry.insert(itemtInfo, at: x+1)
    }else{
      dataAry.append(itemtInfo)
    }
    
    
    
    videoKeyFrameCollectionView.reloadData()
    print("clickCutBtn \(offsetX)")
    
    videoKeyFrameCollectionView.setContentOffset(CGPoint.init(x: videoKeyFrameCollectionView.contentOffset.x + CGFloat.init(7), y: 0), animated: true)
    setCutBtnViewStateForCanNotDoing()
    
    // Dispatch
    store.dispatch(
      Actions.AddUndoOperation(
        operation: UndoHistory.Operation.Cut(
          indexPath: IndexPath(item: Int(a), section: x)
        )
      )
    )
    
  }
  
  @objc private func clickSaveBtn(){
    fatalError("not implement")
    // generate video segments
    let segments = dataAry.reduce([]) { (acc, xs) -> [VideoSegment] in
      return []
    }
    let videoSourceURL = URL(fileURLWithPath: "")
    let videoDestinationURL = URL(fileURLWithPath: "")
    try? VideoSegmentComposition.bar(source: videoSourceURL, destination: videoDestinationURL, instruction: segments)
  }
  
  @objc private func undoButtonAction(button: UIButton) -> () {
    print("undo action")
    guard let oper = store.state.undoHistory.undo() else { return () }
    switch oper {
      
    case .Cut(let indexPath):
      let sectionA = dataAry.remove(at: indexPath.section)
      let sectionB = dataAry.remove(at: indexPath.section)
      let combinedArray = sectionA.imageAry + sectionB.imageAry
      
      let infoItem = CutTheVideoItemInfo.init()
      infoItem.imageAry = combinedArray
      infoItem.isShowGriddingShade = false
      
      dataAry.insert(infoItem, at: indexPath.section)
      videoKeyFrameCollectionView.reloadData()
      // TODO: scroll to cut position
      
    case .Rearrange(let to, let from):
      let t = dataAry.remove(at: to.item)
      dataAry.insert(t, at: from.item)
      videoKeyFrameCollectionView.reloadItems(at: [from, to])
      
    default:
      print("unimplement")
      
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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

// MARK: - StoreSubscriber 
extension CutTheVideoViewController2: StoreSubscriber {
  func newState(state: AppState) {
    print(state)
  }
}
