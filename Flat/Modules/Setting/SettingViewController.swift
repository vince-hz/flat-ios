//
//  SettingViewController.swift
//  flat
//
//  Created by xuyunshi on 2021/10/15.
//  Copyright © 2021 agora.io. All rights reserved.
//


import UIKit
import Whiteboard

class SettingViewController: UITableViewController {
    enum DisplayVersion: CaseIterable {
        case flat
        case whiteboard
        
        var description: String {
            switch self {
            case .flat:
                return "Flat v\(Env().version) (\(Env().build))"
            case .whiteboard:
                return "Whiteboard v\(WhiteSDK.version())"
            }
        }
    }
    
    let cellIdentifier = "cellIdentifier"
    var items: [(UIImage, String, String, (NSObject, Selector)?)] = []
    var displayVersion: DisplayVersion = DisplayVersion.flat {
        didSet {
            updateItems()
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateItems()
    }
    
    func updateItems() {
        items = [
            (UIImage(named: "language")!,
             NSLocalizedString("Language Setting", comment: ""),
             LocaleManager.language?.name ?? "跟随系统",
             (self, #selector(self.onClickLanguage(sender:)))),
            
            (UIImage(named: "theme")!,
             NSLocalizedString("Theme", comment: ""),
             (Theme.shared.userPreferredStyle ?? ThemeStyle.default).description,
             (self, #selector(self.onClickTheme(sender:)))
            ),
            
            (UIImage(named: "update_version")!,
             NSLocalizedString("Version", comment: ""),
             displayVersion.description,
             (self, #selector(onVersion(sender:)))),
            
//            (UIImage(named: "message")!,
//             NSLocalizedString("Contact Us", comment: ""),
//             "",
//             (self, #selector(self.onClickContactUs))),
            
            (UIImage(named: "info")!,
             NSLocalizedString("About", comment: ""),
             "",
             (self, #selector(self.onClickAbout(sender:))))
        ]
        tableView.reloadData()
    }
    
    func setupViews() {
        title = NSLocalizedString("Setting", comment: "")
        tableView.backgroundColor = .whiteBG
        tableView.separatorColor = .borderColor
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 0)
        tableView.separatorStyle = .singleLine
        tableView.register(UINib(nibName: String(describing: SettingTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        let container = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: 40)))
        container.backgroundColor = .whiteBG
        container.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        tableView.tableFooterView = container
    }
    
    // MARK: - Action
    @objc func onClickLogout() {
        AuthStore.shared.logout()
    }
    
    @objc func onVersion(sender: Any?) {
        guard let i = DisplayVersion.allCases.firstIndex(of: displayVersion) else { return }
        let nextIndex = DisplayVersion.allCases.index(after: i)
        if nextIndex == DisplayVersion.allCases.endIndex {
            displayVersion = .allCases.first!
        } else {
            displayVersion = DisplayVersion.allCases[nextIndex]
        }
    }
    
    @objc func onClickAbout(sender: Any?) {
        navigationController?.pushViewController(AboutUsViewController(), animated: true)
    }

    @objc func onClickTheme(sender: Any?) {
        let alertController = UIAlertController(title: NSLocalizedString("Select Theme", comment: ""), message: nil, preferredStyle: .actionSheet)
        let manager = Theme.shared
        let current = manager.userPreferredStyle ?? ThemeStyle.default
        for i in ThemeStyle.allCases {
            let selected = NSLocalizedString("selected", comment: "")
            alertController.addAction(.init(title: i.description + ((current == i) ? selected : ""), style: .default, handler: { _ in
                manager.updateUserPreferredStyle(i)
                if #available(iOS 13.0, *) {
                    self.updateItems()
                } else {
                    self.rebootAndTurnToSetting()
                }
            }))
        }
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        let popPresent = alertController.popoverPresentationController
        if let cell = sender as? SettingTableViewCell {
            popPresent?.sourceView = cell.popOverAnchorView
        }
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func onClickLanguage(sender: Any?) {
        let alertController = UIAlertController(title: NSLocalizedString("Select Language", comment: ""), message: nil, preferredStyle: .actionSheet)
        let currentLanguage = LocaleManager.language
        for l in Language.allCases {
            alertController.addAction(.init(title: l == currentLanguage ? "\(l.name)\(NSLocalizedString("selected", comment: ""))" : l.name, style: .default, handler: { _ in
                Bundle.set(language: l)
                self.rebootAndTurnToSetting()
                print("local update", LocaleManager.languageCode)
            }))
        }
        alertController.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        let popPresent = alertController.popoverPresentationController
        if let cell = sender as? SettingTableViewCell {
            popPresent?.sourceView = cell.popOverAnchorView
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func rebootAndTurnToSetting() {
        if #available(iOS 13.0, *) {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.launch?.reboot()
        } else {
            (UIApplication.shared.delegate as? AppDelegate)?.launch?.reboot()
        }
        UIApplication.shared.topViewController?.mainContainer?.push(SettingViewController())
    }
    
    @objc func onClickContactUs() {
        navigationController?.pushViewController(ContactUsViewController(), animated: true)
    }
    
    // MARK: - Lazy
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "#F45454").cgColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.setTitleColor(.init(hexString: "#F45454"), for: .normal)
        button.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
        button.setImage(UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(onClickLogout), for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 0, left: 44, bottom: 0, right: 44)
        return button
    }()
    
    // MARK: - Tableview
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if let pairs = items[indexPath.row].3 {
            pairs.0.performSelector(onMainThread: pairs.1, with: cell, waitUntilDone: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SettingTableViewCell
        cell.iconImageView.image = item.0
        cell.iconImageView.tintColor = .text
        cell.settingTitleLabel.text = item.1
        cell.settingDetailLabel.text = item.2
        return cell
    }
}
