//
//  SettingViewController.swift
//  flat
//
//  Created by xuyunshi on 2021/10/15.
//  Copyright © 2021 agora.io. All rights reserved.
//


import UIKit
import Whiteboard

private var fpaKey: String? {
    guard let uid = AuthStore.shared.user?.userUUID else { return nil }
    let key = uid + "useFPA"
    return key
}

/// Global value for user
var userUseFPA: Bool {
    get {
        guard let fpaKey = fpaKey else { return false }
        return (UserDefaults.standard.value(forKey: fpaKey) as? Bool) ?? false
    }
    set {
        guard let fpaKey = fpaKey else { return }
        UserDefaults.standard.setValue(newValue, forKey: fpaKey)
        if !newValue {
            if #available(iOS 13.0, *) {
                FpaProxyService.shared().stop()
            }
        }
    }
}

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
    var items: [Item] = []
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
    
    struct Item {
        let image: UIImage
        let title: String
        let detail: Any
        let targetAction: (NSObject, Selector)?
    }
    
    func updateItems() {
        items = [
            .init(image: UIImage(named: "language")!,
                  title: NSLocalizedString("Language Setting", comment: ""),
                  detail: LocaleManager.language?.name ?? "跟随系统",
                  targetAction: (self, #selector(self.onClickLanguage(sender:)))),
            .init(image: UIImage(named: "theme")!,
                  title: NSLocalizedString("Theme", comment: ""),
                  detail: (Theme.shared.userPreferredStyle ?? ThemeStyle.default).description,
                  targetAction: (self, #selector(self.onClickTheme(sender:)))),
            .init(image: UIImage(named: "update_version")!,
                  title: NSLocalizedString("Version", comment: ""),
                  detail: displayVersion.description,
                  targetAction: (self, #selector(onVersion(sender:)))),
            .init(image: UIImage(named: "info")!,
                  title: NSLocalizedString("About", comment: ""),
                  detail: "",
                  targetAction: (self, #selector(self.onClickAbout(sender:))))
        ]
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .light, scale: .small)
            let image = UIImage(systemName: "bolt", withConfiguration: config)!
            items.insert(.init(image: image,
                               title: NSLocalizedString("FPA", comment: ""),
                               detail: userUseFPA ? true : false,
                               targetAction: (self, #selector(self.onClickFPA(sender:)))),
                         at: 2)
        }
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
    
    @objc func onClickFPA(sender: Any?) {
        guard let sender = sender as? UISwitch else { return }
        userUseFPA = sender.isOn
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
        let item = items[indexPath.row]
        if item.detail is String, let pairs = item.targetAction {
            pairs.0.performSelector(onMainThread: pairs.1, with: cell, waitUntilDone: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SettingTableViewCell
        cell.iconImageView.image = item.image
        cell.iconImageView.tintColor = .text
        cell.settingTitleLabel.text = item.title
        if let bool = item.detail as? Bool {
            cell.settingDetailLabel.isHidden = true
            cell.switch.isHidden = false
            cell.switch.isOn = bool
            cell.accessoryType = .none
            if let pair = item.targetAction {
                cell.switch.addTarget(pair.0, action: pair.1, for: .valueChanged)
                    }
        }
        if let description = item.detail as? String {
            cell.accessoryType = .disclosureIndicator
            cell.settingDetailLabel.isHidden = false
            cell.switch.isHidden = true
            cell.settingDetailLabel.text = description
        }
        return cell
    }
}
