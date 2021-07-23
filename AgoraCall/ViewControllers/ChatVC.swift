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
