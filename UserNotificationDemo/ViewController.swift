//
//  ViewController.swift
//  UserNotificationDemo
//
//  Created by suneel seelam on 10/06/20.
//  Copyright © 2020 suneel seelam. All rights reserved.
//

import Cocoa
import UserNotifications

class ViewController: NSViewController {

	/// Notification content to add in local notification.
	lazy var notificationContent: NotificationContent = {
		let content = NotificationContent()
		content.title = "Demo App"
		content.categoryIdentifier = NotificationIdentifier.Category.test
		content.sound = UNNotificationSound.default
		content.body = NSString.localizedUserNotificationString(forKey: "Attachment download", arguments: nil)
		return content
	}()
	
	/// Notification custom actions and category.
	lazy var notificationCategory: NotificationCategory = {
		// Actions
		let show = NotificationAction(identifier: NotificationIdentifier.Action.show, title: NSLocalizedString("Show", comment: ""), options: .foreground)
		let close = NotificationAction(identifier: NotificationIdentifier.Action.close, title: NSLocalizedString("Close", comment: ""), options: .destructive)
		// Category
		let category = NotificationCategory(identifier: NotificationIdentifier.Category.test, actions: [show, close], intentIdentifiers: [])
		return category
	}()

	
	@IBAction func buttonOneTapped(_ sender: Any) {
		
		let show = NotificationAction(identifier: NotificationIdentifier.Action.show, title: NSLocalizedString("Show", comment: ""), options: .foreground)
		let close = NotificationAction(identifier: NotificationIdentifier.Action.close, title: NSLocalizedString("Close", comment: ""), options: .destructive)
		// Category
		let category = NotificationCategory(identifier: NotificationIdentifier.Category.test, actions: [show, close], intentIdentifiers: [])
		
		// Configure the notification trigger.
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

		let uuid = UUID().uuidString
		print("----Notify1----\(uuid)--")
		let notification = UserNotification(identifier: uuid, content: self.notificationContent, category: category, trigger: trigger)
		let notificationResponse: NotificationResponseHandler  = { (response) in
			let identifier = response.notification.request.identifier
			print("Identifier-------\(identifier)")
		}
		UserNotificationScheduler.shared.scheduleNotification(with: notification, responseHandler: notificationResponse)
		
		
	}
	
	
	@IBAction func button2Tapped(_ sender: Any) {
		
		let uuid = UUID().uuidString
		print("----Notify 2----\(uuid)--")
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
		let notification = UserNotification(identifier: uuid, content: self.notificationContent, category: self.notificationCategory, trigger: trigger)
		UserNotificationScheduler.shared.scheduleNotification(with: notification, responseHandler: { (notificationResponse) in
			let identifier = notificationResponse.notification.request.identifier
			print("Identifier-------\(identifier)")
		})
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

