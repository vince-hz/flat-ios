//
//  CloudStorageTableViewCell.swift
//  Flat
//
//  Created by xuyunshi on 2021/12/1.
//  Copyright © 2021 agora.io. All rights reserved.
//

import UIKit

class CloudStorageTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupViews() {
        backgroundColor = .whiteBG
        contentView.backgroundColor = .whiteBG
        let textStack = UIStackView(arrangedSubviews: [fileNameLabel, sizeAndTimeLabel])
        textStack.axis = .vertical
        textStack.distribution = .fillEqually
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [iconImage, textStack, addImage])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        iconImage.snp.makeConstraints { $0.width.equalTo(32) }
        addImage.snp.makeConstraints { $0.width.equalTo(24) }
        iconImage.addSubview(convertingIcon)
        convertingIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().inset(6)
        }
        convertingIcon.isHidden = true
        
        let line = UIView(frame: .zero)
        line.backgroundColor = .borderColor
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.right.equalTo(stackView)
            make.left.equalTo(textStack)
            make.height.equalTo(1 / UIScreen.main.scale)
            make.bottom.equalToSuperview()
        }
    }
    
    func stopConvertingAnimation() {
        convertingIcon.isHidden = true
        convertingIcon.layer.removeAnimation(forKey: "r")
    }
    
    func startConvertingAnimation() {
        convertingIcon.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = .infinity
        convertingIcon.layer.add(animation, forKey: "r")
    }
    
    
    func updateActivityAnimate(_ animate: Bool) {
        if animate {
            if activity.superview == nil {
                contentView.addSubview(activity)
                activity.snp.makeConstraints { make in
                    make.edges.equalTo(iconImage)
                }
            }
            activity.isHidden = false
            activity.startAnimating()
        } else {
            activity.stopAnimating()
        }
    }
    
    lazy var convertingIcon = UIImageView(image: UIImage(named: "converting"))
    
    lazy var activity: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()
    
    lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var addImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "storage_add"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var sizeAndTimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .subText
        return label
    }()
    
    lazy var fileNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14)
        label.textColor = .text
        return label
    }()
}
