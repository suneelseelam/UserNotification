//
//  UserNotificationScheduler.swift
//  UserNotificationDemo
//
//  Created by suneel seelam on 10/06/20.
//  Copyright © 2020 suneel seelam. All rights reserved.
//

import Foundation
import UserNotifications

/// A callback to pass notification response.
public typealias NotificationResponseHandler = (UNNotificationResponse) -> Void

/**
 * An ErrorType enumerating errors for notification authorization status.
 * @Denied, The app is not authorized to schedule or receive notifications.
 */
public enum UserNotificationError: Error {
	case denied
}

///  User notification scheduler class.
@objc public class UserNotificationScheduler: NSObject {
	/// Shared  notification scheduler.
	public static var shared: UserNotificationScheduler {
		return self.instance
	}
	
	 private static let instance = UserNotificationScheduler()
	
	/// The notification central object for managing notification-related activities.
	fileprivate let notificationCenter = UNUserNotificationCenter.current()
	
	/// The completion handler call to return results.
	private var responseHandler: NotificationResponseHandler?

	/// Notification presentation options.
	lazy var presentationOptions: UNNotificationPresentationOptions = {
		return [.alert, .sound]
	}()
	
	override private init() {
		super.init()
		self.notificationCenter.delegate = self
	}
	
	/**
	 * Requests and returns the notification settings status of the app.
	 */
	@objc public func getNotificationSettingStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
		notificationCenter.getNotificationSettings { settings in
			completionHandler(settings.authorizationStatus)
		}
	}
	
	/**
	 * Requests authorization to interact with the user when local and remote notifications are delivered to the user’s device.
	 * Note Always call this method before scheduling any local notifications and before registering with the Apple Push Notification service.
	 * @param options The options are constants for requesting authorization to interact with the user.
	 * @param completionHandler The call back to send status of the request.
	 * discussion Based on notification setting status of the app, will request for authorization. If it already authorized, It's not necessary for new request.
	 */
	@objc public func requestAuthorization(with options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
		self.getNotificationSettingStatus { [weak self] authorizationStatus in
			switch authorizationStatus {
				case .notDetermined:
					self?.notificationCenter.requestAuthorization(options: options) { response, error in
						completionHandler(response, error)
					}
				case .authorized, .provisional:
					completionHandler(true, nil)
				case .denied:
					completionHandler(false, UserNotificationError.denied)
				default:
					break
			}
		}
	}
	
	/**
	 * Schedules user notification for delivery.
	 * @param notification The  Notification object that includes content, category and trigger to schedule user notification.
	 * @param requestHandler The callback to send notification request status.
	 * @param responseHandler The callback to send notification response from did receive.
	 */
	fileprivate func _schedule(notification: UserNotification, requestHandler: ((Error?) -> Void)? = nil, responseHandler: @escaping NotificationResponseHandler) {
		self.responseHandler = responseHandler
		if let category = notification.category {
			// Adding notification types and the custom actions.
			self.notificationCenter.setNotificationCategories([category])
		}
		// A request to schedule a local notification, which includes the content of the notification and the trigger conditions for delivery.
		let request = UNNotificationRequest(identifier: notification.identifier, content: notification.content, trigger: notification.trigger)
		self.notificationCenter.add(request) { error in
			if let error = error {
				requestHandler?(error)
			}
		}
	}
	
	/**
 	 * discussion Before scheduling the notification, verifying notification `authorization status` of the application. If user has authorized, notification is scheduled and If the has been
 	 * If authorization status is `authorized`, `provisional`, notification is scheduled.
 	 * If  authorization status is `notDetermined`, requesting for authorization and based on the response will schedule notification.
 	 * If authorization status is `denied`,  sending status error through call back.
	 */
	@objc public func scheduleNotification(with notification: UserNotification, requestHandler: ((Error?) -> Void)? = nil, responseHandler: @escaping NotificationResponseHandler) {
		self.getNotificationSettingStatus { authorizationStatus in
			switch authorizationStatus {
			case .authorized, .provisional:
				self._schedule(notification: notification, requestHandler: requestHandler, responseHandler: responseHandler)
			case .notDetermined:
				self.requestAuthorization(with: [.alert, .sound]) { response, error in
					if let error = error {
						requestHandler?(error)
					}
					if response {
						self._schedule(notification: notification, requestHandler: requestHandler, responseHandler: responseHandler)
					}
				}
			default:
				break
			}
		}
	}
	
	/**
	 * Returns a list of all notification requests that are scheduled and waiting to be delivered.
	 */
	@objc public func getAllPendingNotifications(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
		self.notificationCenter.getPendingNotificationRequests { notificationRequests in
			completionHandler(notificationRequests)
		}
	}
	
	/**
	 * Returns a list of the notifications that are still displayed in notification center.
	 */
	@objc public func getDeliveredNotifications(completionHandler: @escaping ([UNNotification]) -> Void) {
		self.notificationCenter.getDeliveredNotifications { notifications in
			completionHandler(notifications)
		}
	}
	
	/**
	 * Removes the specified notification requests from notification center.
	 * @param identifiers The identifiers helps to remove the notification request selectively from notification center
	 */
	@objc public func removeDeliveredNotification(with identifiers: [String]) {
		self.notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
	}
	
	/**
	 * Unschedules the specified notification requests from notification center.
	 * @param identifiers The identifiers helps to unschedule the notification request selectively from notification center.
	 */
	@objc public func removePendingNotification(with identifiers: [String]) {
		self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
	}
	
	/**
	 * Removes all the delivered notifications from notification center.
	 */
	@objc public func removeAllDeliveredNotification() {
		self.notificationCenter.removeAllDeliveredNotifications()
	}
	
	/**
	 * Unschedules all pending notification requests from notification center.
	 */
	@objc public func removeAllPendingNotifications() {
		self.notificationCenter.removeAllPendingNotificationRequests()
	}
}

extension UserNotificationScheduler: UNUserNotificationCenterDelegate {
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.badge, .sound, .alert])
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		self.responseHandler?(response)
		completionHandler()
	}
}
