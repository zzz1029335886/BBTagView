//
//  ViewController.swift
//  BBTagView
//
//  Created by summer on 2022/1/21.
//

import UIKit
import SnapKit

extension UIColor {
    /// 返回随机颜色
    open class var random: UIColor{
        get{
            let red = CGFloat(arc4random() % 256) / 255.0
            let green = CGFloat(arc4random() % 256) / 255.0
            let blue = CGFloat(arc4random() % 256) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController, BBTagViewDataSource, BBTagViewDelegate, BBTagViewVerticalDelegate {
    func tagViewDidLayout(_ tagView: BBTagView) {
        print(tagView.contentSize)
    }
    
    func tagView(_ tagView: BBTagView, didSelectIndexAt index: Int) {
        print(index)
    }
    
    func tagView(_ tagView: BBTagView, sizeForIndexAt index: Int) -> CGSize {
        var size = sizes[index]
        return size
    }
    
    func tagView(_ tagView: BBTagView, viewForIndexAt index: Int) -> UIView {
        let label = getTitleLabel("\(index)")
        label.textColor = .random
//        label.isUserInteractionEnabled = true
//        label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(labelClick)))
        label.backgroundColor = .random
        return label
    }
    
//    @objc
//    func labelClick() {
//        print(123)
//    }
    
    func numberOfItemsInLine(in tagView: BBTagView) -> Int {
        return 3
    }
    
    func numberOfViews(in tagView: BBTagView) -> Int {
        return sizes.count
    }
    
    var tagView: BBTagView!
    
    var sizes: [CGSize] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizes = (0..<100).compactMap({ index in
            let maxWidth: CGFloat = 100
            let minWidth: CGFloat = 30
            let maxHeight: CGFloat = 30
            let minHeight: CGFloat = 10
            
            let w = maxWidth - minWidth
            let h = maxHeight - minHeight
            
            let width = Int(arc4random() % UInt32(w)) + Int(minWidth)
            let height = Int(arc4random() % UInt32(h)) + Int(minHeight)

            return .init(width: width, height: height)
        })
        
        tagView = BBTagView.init(frame: .zero, style: .vertical, verticalDelegate: self)
        tagView.backgroundColor = .random
        tagView.verticalPadding = 8
        tagView.horizontalPadding = 16
        tagView.insets = .init(top: 10, left: 20, bottom: 40, right: 10)
        tagView.dataSource = self
        tagView.delegate = self
        self.view.addSubview(tagView)
        tagView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tagView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tagViewClick)))
    }
    
    @objc
    func tagViewClick() {
        tagView.reloadData()
    }

    func getTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }
    
    
}

