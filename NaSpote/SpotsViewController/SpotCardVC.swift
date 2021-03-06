//
//  SpotCardVC.swift
//  NaSpote
//
//  Created by Артем Кудрявцев on 07.05.2022.
//

import UIKit
import Kingfisher
import MapKit

class SpotCardVC: UIViewController {
    
    var contacts: Contacts!
    var detailWakeboarManager = DetailWakeboardManager()
    
    var positionScroll = CGPoint()
    
    let exitButton = UIButton()
    let callButton = UIButton()
    let reserveButton = UIButton()
    let networksButton = UIButton()
    let instagramButton = UIButton()
    let vkButton = UIButton()
    let webButton = UIButton()
    
    var callButtonConstraint: NSLayoutConstraint!
    var reserveButtonConstraint: NSLayoutConstraint!
    var networkButtonConstraint: NSLayoutConstraint!
    var instagramButtonConstraint: NSLayoutConstraint!
    var vkButtonConstraint: NSLayoutConstraint!
    var webButtonConstraint: NSLayoutConstraint!
    
    var logo = String()
    var link = String()
    var infoTitle = [String]()
    var infoContent = [String]()
    
    var openSections = false
    
    @IBOutlet var cardSpotTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailWakeboarManager.delegate = self
        
        DispatchQueue.main.async {
            self.detailWakeboarManager.fetchSpot(self.link)
            self.cardSpotTable.register(UITableViewCell.self, forCellReuseIdentifier: "cardCell")
        }
        
        addCallButton()
        addReserveButton()
        addExitButton()
        addNetworksButton()
        addInstagrammButton()
        addVkButton()
        addWebButton()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(showButtons), name: Notification.Name("true"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideButtons), name: Notification.Name("false"), object: nil)
        
        cardSpotTable.delegate = self
        cardSpotTable.dataSource = self
        cardSpotTable.showsVerticalScrollIndicator = false
        cardSpotTable.rowHeight = UITableView.automaticDimension
        
        
        
    }
}

// MARK: - TableViewDelegate

extension SpotCardVC: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        positionScroll = scrollView.contentOffset
        
        if positionScroll.y < 0 {
            NotificationCenter.default.post(name: Notification.Name("false"), object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name("true"), object: nil)
        }
        
        cardSpotTable.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 3 {
            if openSections {
                
                return contacts.services.count + 1
                
            } else {
                
                return 1
            }
            
        }
        
        if section == 1 {
            
            return infoTitle.count
            
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: Title Cell
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleCell
            
            
            cell.addSubview(cell.logo)
            cell.addSubview(cell.title)
            cell.addSubview(cell.rating)

            cell.separatorInset.left = 0
            
            DispatchQueue.main.async {
                
                let processor = DownsamplingImageProcessor(size: cell.bounds.size)
            
                cell.logo.kf.indicatorType = .activity
                cell.logo.kf.setImage(with: URL(string: self.logo), placeholder: UIImage(named: "NotFound"), options: [.processor(processor)])
                cell.title.text = self.contacts.title
            }
            
            cell.UIfontLabel(label: cell.title, font: "Helvetica-bold", viewHeight: view.frame.height, size: 14)
            
            NSLayoutConstraint.activate([
                
                cell.logo.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                cell.logo.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
                cell.logo.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
                cell.logo.heightAnchor.constraint(equalToConstant: 100),
                cell.logo.widthAnchor.constraint(equalToConstant: 100),
                
                cell.title.topAnchor.constraint(equalTo: cell.topAnchor, constant: 20),
                cell.title.leadingAnchor.constraint(equalTo: cell.logo.trailingAnchor, constant: 20),
                cell.title.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                
                cell.rating.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -20),
                cell.rating.leadingAnchor.constraint(equalTo: cell.logo.trailingAnchor, constant: 20),
                
            ])
            
            return cell
            
        }
        
        // MARK: Info Cell
        
        if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! InfoCell
            
            cell.addSubview(cell.leftLabel)
            cell.addSubview(cell.rightLabel)
            
            cell.leftLabel.textAlignment = .left
            cell.rightLabel.textAlignment = .right
            
            cell.leftLabel.text = self.infoTitle[indexPath.row]
            cell.rightLabel.text = self.infoContent[indexPath.row]
           
            
            cell.UIfontLabel(label: cell.leftLabel, font: "helvetica-Light", viewHeight: view.frame.height, size: 8)
            cell.UIfontLabel(label: cell.rightLabel, font: "helvetica-Light", viewHeight: view.frame.height, size: 8)
            
            NSLayoutConstraint.activate([
                
                cell.leftLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 8),
                cell.leftLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
                cell.leftLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -8),
                cell.rightLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant:  8),
                cell.rightLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                cell.rightLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -8),
                cell.rightLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 2)
                
            ])
            
            return cell
            
        }
        
        // MARK: Photo Cell
        
        
        if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoCell
            
            cell.addSubview(cell.photoCollection)
            
            DispatchQueue.main.async {
                cell.viewHewight = Int(self.view.frame.height / 5.6)
                cell.array = self.contacts.gallery
            }
            
            
            cell.separatorInset.left = 0
            
            NSLayoutConstraint.activate([
                
                cell.photoCollection.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                cell.photoCollection.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0),
                cell.photoCollection.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0),
                cell.photoCollection.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
                cell.photoCollection.heightAnchor.constraint(equalToConstant: view.frame.height / 5.6)
                
            ])
            
            return cell
        }
        
        // MARK: Services Cell
        
        if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "servicesCell", for: indexPath) as! ServicesCell
                
                cell.addSubview(cell.title)
                cell.addSubview(cell.arrow)
                
                cell.title.text = "Услуги"
                cell.arrow.tintColor = .black
                
                if openSections {
                    cell.arrow.image = UIImage(systemName: "chevron.compact.up")
                } else {
                    cell.arrow.image = UIImage(systemName: "chevron.compact.down")
                }
                cell.UIfontLabel(label: cell.title, font: "Helvetica-Bold", viewHeight: view.frame.height, size: 16)
                
                NSLayoutConstraint.activate([
                    
                    cell.title.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                    cell.title.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant:  10),
                    cell.title.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
                    cell.arrow.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                    cell.arrow.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                    cell.arrow.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
                    cell.arrow.widthAnchor.constraint(equalTo: cell.arrow.heightAnchor)
                    
                ])
                
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
                
                var content = cell.defaultContentConfiguration()
                content.text = contacts.services[indexPath.row - 1]
                content.textProperties.font = .systemFont(ofSize: view.frame.height / 59.7)
                
                var services = [String]()
                for i in contacts.services {
                    if i == "Сауна/Баня" {
                        services.append("Сауна, Баня")
                    } else {
                        services.append(i)
                    }
                }
                
                content.image = UIImage(named: services[indexPath.row - 1])
                
                cell.contentConfiguration = content
                
                return cell
            }
            
        } else {
            
            // MARK: Location Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationCell
            
            cell.addSubview(cell.map)
            
            DispatchQueue.main.async {
                cell.location(self.contacts.location, cell.map)
                
            }
            
            NSLayoutConstraint.activate([
                
                cell.map.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                cell.map.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
                cell.map.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                cell.map.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10),
                cell.map.heightAnchor.constraint(equalToConstant: view.frame.height / 4)
                
            ])
            
            return cell
        }
    }
    
    // MARK: - Did Select Row
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            openSections = !openSections
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            if indexPath.row > 0 {
                
                return 40
            }
        }
        
        return  UITableView.automaticDimension
    }
}

extension SpotCardVC {
    
    // MARK: - Call And Reserve Button
    
    func addCallButton() {
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("Позвонить", for: .normal)
        callButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        callButton.titleLabel?.textColor = .white
        callButton.backgroundColor = .systemGreen
        callButton.layer.cornerRadius = 7
        view.addSubview(callButton)
        
        
        let constraints = [
            callButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            callButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            callButton.heightAnchor.constraint(equalToConstant: 50),
            callButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        callButtonConstraint = NSLayoutConstraint(item: callButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 50)
        view.addConstraint(callButtonConstraint)
    }
    
    func addReserveButton() {
        
        let buttonWidth = view.frame.width / 2.5
        
        reserveButton.translatesAutoresizingMaskIntoConstraints = false
        reserveButton.setTitle("Забронировать", for: .normal)
        reserveButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        reserveButton.titleLabel?.textColor = .white
        reserveButton.backgroundColor = .systemBlue
        reserveButton.layer.cornerRadius = 7
        view.addSubview(reserveButton)
        
        let constraints = [
            reserveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width - buttonWidth - 20),
            reserveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),
            reserveButton.heightAnchor.constraint(equalToConstant: 50),
            reserveButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        reserveButtonConstraint = NSLayoutConstraint(item: reserveButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 50)
        view.addConstraint(reserveButtonConstraint)
    }
    
    // MARK: Exit Button
    
    func addExitButton() {
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.backgroundColor = .systemGray3
        exitButton.alpha = 0.4
        exitButton.layer.cornerRadius = 20
        exitButton.setImage(UIImage(systemName: "multiply"), for: .normal)
        exitButton.tintColor = .black
        view.addSubview(exitButton)
        
        let constraints = [
            exitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:  view.frame.width - 60),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 40),
            exitButton.widthAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func exitButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Networks Buttons
    
    func addNetworksButton() {
        
        networksButton.translatesAutoresizingMaskIntoConstraints = false
        networksButton.backgroundColor = .clear
        networksButton.alpha = 0.5
        networksButton.layer.cornerRadius = 50 / 2
        networksButton.setBackgroundImage(UIImage(systemName: "plus.circle"), for: .normal)
        networksButton.tintColor = .black
        view.addSubview(networksButton)
        
        let constraints = [
            networksButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width - 70),
            networksButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            networksButton.heightAnchor.constraint(equalToConstant: 50),
            networksButton.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        networkButtonConstraint = NSLayoutConstraint(item: networksButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20)
        view.addConstraint(networkButtonConstraint)
        
        networksButton.addTarget(self, action: #selector(openNetworks), for: .touchUpInside)
        
    }
    
    func addInstagrammButton() {
        
        instagramButton.translatesAutoresizingMaskIntoConstraints = false
        instagramButton.layer.cornerRadius = 25
        instagramButton.setBackgroundImage(UIImage(named: "instagram"), for: .normal)
        instagramButton.isHidden = true
        view.addSubview(instagramButton)
        
        let constraints = [
            instagramButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width - 70),
            instagramButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            instagramButton.heightAnchor.constraint(equalToConstant: 50),
            instagramButton.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        instagramButtonConstraint = NSLayoutConstraint(item: instagramButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20)
        view.addConstraint(instagramButtonConstraint)
        
    }
    
    func addVkButton() {
        
        vkButton.translatesAutoresizingMaskIntoConstraints = false
        vkButton.frame = CGRect(x: 414 - 80, y: 740, width: 50, height: 50)
        vkButton.layer.cornerRadius = 25
        vkButton.setBackgroundImage(UIImage(named: "vk"), for: .normal)
        vkButton.isHidden = true
        view.addSubview(vkButton)
        
        let constraints = [
            vkButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width - 70),
            vkButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            vkButton.heightAnchor.constraint(equalToConstant: 50),
            vkButton.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        vkButtonConstraint = NSLayoutConstraint(item: vkButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20)
        view.addConstraint(vkButtonConstraint)
        
    }
    
    func addWebButton() {
        
        webButton.translatesAutoresizingMaskIntoConstraints = false
        webButton.layer.cornerRadius = 25
        webButton.setBackgroundImage(UIImage(named: "safari"), for: .normal)
        webButton.isHidden = true
        view.addSubview(webButton)
        
        let constraints = [
            webButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.frame.width - 70),
            webButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            webButton.heightAnchor.constraint(equalToConstant: 50),
            webButton.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        webButtonConstraint = NSLayoutConstraint(item: webButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20)
        view.addConstraint(webButtonConstraint)
        
    }
    
    
    
    @objc func openNetworks() {
        
        
        if instagramButton.isHidden {
            
            networksButton.alpha = 1
            
            if self.instagramButtonConstraint.constant > -90 {
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseIn) {
                    self.webButtonConstraint.constant -= 70
                    self.view.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.1, delay: 0.05, options: .curveEaseIn) {
                    self.instagramButtonConstraint.constant -= 140
                    self.view.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                    self.vkButtonConstraint.constant -= 210
                    self.view.layoutIfNeeded()
                }
                
                instagramButton.isHidden = false
                vkButton.isHidden = false
                webButton.isHidden = false
                
            } else if self.instagramButtonConstraint.constant > -160  {
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseIn) {
                    self.webButtonConstraint.constant -= 70
                    self.view.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.1, delay: 0.05, options: .curveEaseIn) {
                    self.instagramButtonConstraint.constant -= 140
                    self.view.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                    self.vkButtonConstraint.constant -= 210
                    self.view.layoutIfNeeded()
                }
                
                instagramButton.isHidden = false
                vkButton.isHidden = false
                webButton.isHidden = false
            }
            
        } else {
            
            self.webButtonConstraint.constant += 70
            self.instagramButtonConstraint.constant += 140
            self.vkButtonConstraint.constant += 210
            
            instagramButton.isHidden = true
            vkButton.isHidden = true
            webButton.isHidden = true
            
            networksButton.alpha = 0.2
            
        }
    }
    
    // MARK: - Animated
    
    @objc func showButtons() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            if self.callButtonConstraint.constant > -20 {
                self.callButtonConstraint.constant -= 70
                self.reserveButtonConstraint.constant -= 70
                self.networkButtonConstraint.constant -= 70
                self.instagramButtonConstraint.constant -= 70
                self.vkButtonConstraint.constant -= 70
                self.webButtonConstraint.constant -= 70
                
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func hideButtons() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            if self.callButtonConstraint.constant == -20 {
                self.callButtonConstraint.constant += 70
                self.reserveButtonConstraint.constant += 70
                self.networkButtonConstraint.constant += 70
                self.instagramButtonConstraint.constant += 70
                self.vkButtonConstraint.constant += 70
                self.webButtonConstraint.constant += 70
                
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Spot Manager Delegate

extension SpotCardVC: DetailSpotManagerDelegate {
    
    func didUpdateSpot(spot: Contacts) {
        self.contacts = spot
        
        if spot.weekday.title != "" && spot.weekday.price != "" {
            infoTitle.append(spot.weekday.title)
            infoContent.append(spot.weekday.price)
        }
        
        if spot.weekend.title != "" && spot.weekend.price != "" {
            infoTitle.append(spot.weekend.title)
            infoContent.append(spot.weekend.price)
        }
        
        if spot.setDuration.title != "" && spot.setDuration.duration != "" {
            infoTitle.append(spot.setDuration.title)
            infoContent.append(spot.setDuration.duration)
        }
        
        if spot.workingHours.title != "" && spot.workingHours.hours != "" {
            infoTitle.append(spot.workingHours.title)
            infoContent.append(spot.workingHours.hours)
        }
        
        cardSpotTable.reloadData()
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


