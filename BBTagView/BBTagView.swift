//
//  BBTagView.swift
//  BrainBank
//
//  Created by summer on 2022/1/21.
//  Copyright © 2022 yoao. All rights reserved.
//

import UIKit

@objc
protocol BBTagViewDelegate: UIScrollViewDelegate {
    @objc optional
    /// 每个view的size
    /// - Returns: size
    func tagView(_ tagView: BBTagView, sizeForIndexAt index: Int) -> CGSize
    
    @objc optional
    /// 选中
    func tagView(_ tagView: BBTagView, didSelectIndexAt index: Int)
    
    @objc optional
    /// 布局完成
    func tagViewDidLayout(_ tagView: BBTagView)

}

@objc
protocol BBTagViewDataSource: NSObjectProtocol {
    /// 每个位置的view
    /// - Returns: view
    func tagView(_ tagView: BBTagView, viewForIndexAt index: Int) -> UIView
    /// 总数
    /// - Returns: 数量
    func numberOfViews(in tagView: BBTagView) -> Int
}

@objc
/// 垂直布局时的代理
protocol BBTagViewVerticalDelegate {
    @objc optional
    /// 每行个数
    /// - Returns: 整数
    func numberOfItemsInLine(in tagView: BBTagView) -> Int
}


class BBTagView: UIView, UIGestureRecognizerDelegate{
    var dataSource: BBTagViewDataSource?
    var delegate: BBTagViewDelegate?
    /// 垂直代理
    var verticalDelegate: BBTagViewVerticalDelegate?
    
    /// 内边距
    var insets: UIEdgeInsets = .zero
    /// 水平间距
    var horizontalPadding: CGFloat = 0
    /// 垂直间距
    var verticalPadding: CGFloat = 0
    
    private let scrollView: UIScrollView = .init()
    private let contentView: UIView = .init()
    
    private var indexView: [Int: UIView] = [:]
    
    /// 内容size
    var contentSize: CGSize{
        return self.scrollView.contentSize
    }
    
    /// 样式
    enum Style {
        /// 水平布局
        case horizontal
        /// 垂直布局
        case vertical
    }
    
    /// 样式
    let style: BBTagView.Style
    
    init(frame: CGRect, style: BBTagView.Style, verticalDelegate: BBTagViewVerticalDelegate? = nil) {
        self.style = style
        self.verticalDelegate = verticalDelegate
        super.init(frame: frame)
    
        scrollView.frame = self.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(contentViewClick(_:)))
        tapGes.delegate = self
        contentView.addGestureRecognizer(tapGes)
    }
    
    override func gestureRecognizerShouldBegin(_ ges: UIGestureRecognizer) -> Bool {
        let tapPointInScrollView = ges.location(in: contentView)
        for (_, view) in indexView{
            if view.frame.contains(tapPointInScrollView) {
                return true
            }
        }
        return false
    }

    @objc
    func contentViewClick(_ ges: UIGestureRecognizer) {
        let tapPointInScrollView = ges.location(in: contentView)
        for (index, view) in indexView{
            if view.frame.contains(tapPointInScrollView) {
                self.delegate?.tagView?(self, didSelectIndexAt: index)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        didLayoutSubviews()
    }
    
    private
    var isDidLayoutSubviews = false
    
    private
    func didLayoutSubviews() {
        if isDidLayoutSubviews {
            return
        }
        isDidLayoutSubviews = true
        _layoutSubViews()
        self.delegate?.tagViewDidLayout?(self)
    }
    
    func reloadData() {
        isDidLayoutSubviews = false
        _layoutSubViews()
    }
    
    private
    func _layoutSubViews() {
        guard let dataSource = dataSource else {
            return
        }
        
        let count = dataSource.numberOfViews(in: self)
        var lastFrame: CGRect = .zero
        
        var maxY: CGFloat = insets.top
        
        let width = self.frame.width
        if width == 0 {
            return
        }
        
        indexView.forEach{ $1.removeFromSuperview() }
        indexView.removeAll()
        
        for index in 0..<count {
            var size: CGSize
            if let _size = delegate?.tagView?(self, sizeForIndexAt: index) {
                size = _size
            }else{
                size = .init(width: width - insets.left - insets.right, height: 44)
            }
            
            if let numberInLine = self.verticalDelegate?.numberOfItemsInLine?(in: self), numberInLine > 0{
                size.width = (width - horizontalPadding * CGFloat(numberInLine - 1) - insets.left - insets.right) / CGFloat(numberInLine)
            }
            
            let origin: CGPoint
            if index == 0 {
                origin = .init(x: insets.left, y: insets.top)
            }else{
                let maxX = lastFrame.maxX + horizontalPadding
                if style == .vertical, (maxX + size.width) > (width - insets.right) {
                    origin = .init(x: insets.left, y: maxY + verticalPadding)
                }else{
                    origin = .init(x: lastFrame.maxX + horizontalPadding, y: lastFrame.minY)
                }
            }
            
            var viewFrame = CGRect.zero
            viewFrame.origin = origin
            viewFrame.size = size
            
            let view = dataSource.tagView(self, viewForIndexAt: index)
            contentView.addSubview(view)
            view.frame = viewFrame
            indexView[index] = view
            
            lastFrame = viewFrame
            maxY = max(maxY, lastFrame.maxY)
        }
        
        if style == .vertical {
            scrollView.contentSize = .init(width: width, height: maxY + insets.bottom)
        } else {
            scrollView.contentSize = .init(width: lastFrame.maxX + insets.right, height: maxY + insets.bottom)
        }
        
        contentView.frame = .init(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        reloadData()
    }
    
    func isInScreen(_ frame: CGRect) -> Bool {
        let offsetY = self.scrollView.contentOffset.y
        let offsetX = self.scrollView.contentOffset.x
        
        switch style {
        case .vertical:
            return frame.maxY > offsetY && frame.origin.y < (bounds.height + offsetY)
        default:
            return frame.maxX > offsetX && frame.origin.x < (bounds.width + offsetX)
        }
    }
}
