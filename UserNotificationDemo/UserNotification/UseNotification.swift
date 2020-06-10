//
//  UseNotification.swift
//  UserNotificationDemo
//
//  Created by suneel seelam on 10/06/20.
//  Copyright © 2020 suneel seelam. All rights reserved.
//

import Foundation
import UserNotifications

// The modifiable content for user notification.
public typealias NotificationContent = UNMutableNotificationContent

/// Action to perform in response to a delivered notification.
public typealias NotificationAction = UNNotificationAction

/// A type of notification that your app supports and the custom actions to display with it.
public typealias NotificationCategory = UNNotificationCategory

/// The common behaviour for subclasses that trigger the delivery of a local or remote notification.
public typealias NotificationTrigger = UNNotificationTrigger

/// User notification identifiers.
public struct NotificationIdentifier {
	// Category Identifiers.
	public struct Category {
		public static let test = "Test"
	}
	
	// Action Identifiers.
	public struct Action {
		public static let show = "Show"
		public static let close = "Close"
	}
}

///  user notification object
@objc public class UserNotification: NSObject {
	/// The unique identifier for the local notification.
	var identifier: String
	
	var content: NotificationContent
	
	var category: NotificationCategory?
	
	var trigger: NotificationTrigger
	
	public init(identifier: String, content: NotificationContent, trigger: NotificationTrigger) {
		self.identifier = identifier
		self.content = content
		self.trigger = trigger
	}
	
	public convenience init(identifier: String, content: NotificationContent, category: NotificationCategory, trigger: NotificationTrigger) {
		self.init(identifier: identifier, content: content, trigger: trigger)
		self.category = category
	}
}
