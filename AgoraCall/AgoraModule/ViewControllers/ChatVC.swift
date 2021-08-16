//
//  ChatVC.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import UIKit


class ChatVC: UIViewController {
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        callBtn.addTarget(self, action: #selector(startCall), for: .touchUpInside)
    }
    
    
    @objc private func startCall() {
        let uid = Auth.currenUserId
        selectUser { user in
            PushApiManager.startCall(uId: uid, user: user) { callId in
                CallManager.shared.callId = callId
                if callId == nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: nil, message: "Ошибка обращения к серверу. Возможно, вы не используете VPN", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let controller = storyboard.instantiateViewController(identifier: "CallVC") as? CallVC else { return }
                        controller.channelName = ChannelNameGenerator.get(uId: uid, userId: user)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                        print("go to call")
                    }
                }
            }
        }
    }
    
    
    private func selectUser(_ selectedUser: @escaping(String) -> Void) {
        let alert = UIAlertController(title: "Select User", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "IOSUser1", style: .default, handler: { _ in
            selectedUser("1")
        }))
        alert.addAction(UIAlertAction(title: "IOSUser3", style: .default, handler: { _ in
            selectedUser("3")
        }))
        alert.addAction(UIAlertAction(title: "WebUser1", style: .default, handler: { _ in
            selectedUser("4")
        }))
        alert.addAction(UIAlertAction(title: "WebUser2", style: .default, handler: { _ in
            selectedUser("5")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = .black
        text.text = (indexPath.row == 0) ? "Hi!" : ((indexPath.row == 1) ? "Hello!" : "Call me!")
        cell.addSubview(text)
        text.textAlignment = (indexPath.row == 0) ? .left : .right
        text.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15).isActive = true
        text.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15).isActive = true
        text.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
