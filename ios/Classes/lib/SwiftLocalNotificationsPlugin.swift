
#if !ACTION_EXTENSION
import UIKit
import Flutter
import UserNotifications
import IosAwnCore

public class SwiftLocalNotificationsPlugin:
                NSObject,
                FlutterPlugin,
                LocalEventListener,
                UNUserNotificationCenterDelegate
{
    static let TAG = "LocalNotificationsPlugin"
    
    static var flutterRegistrantCallback: FlutterPluginRegistrantCallback?
    var localNotifications:LocalNotifications?
    var flutterChannel:FlutterMethodChannel?
    
    public override init() {
        super.init()
    }
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        let flutterChannel = FlutterMethodChannel(
            name: Definitions.CHANNEL_FLUTTER_PLUGIN,
            binaryMessenger: registrar.messenger())
        
        SwiftLocalNotificationsPlugin()
            .AttachLocalNotificationsPlugin(
                usingRegistrar: registrar,
                throughFlutterChannel: flutterChannel)
    }
    
    @objc
    public static func setPluginRegistrantCallback(_ callback: @escaping FlutterPluginRegistrantCallback) {
        flutterRegistrantCallback = callback
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        detacheLocalNotifications(usingRegistrar: registrar)
    }
    
    private func AttachLocalNotificationsPlugin(
        usingRegistrar registrar: FlutterPluginRegistrar,
        throughFlutterChannel channel: FlutterMethodChannel
    ){
        flutterChannel = channel
        
        do {
            DartLocalNotificationsExtension.registrar = registrar
            DartLocalNotificationsExtension.initialize()
            
            try LocalNotifications.loadExtensions()
            localNotifications = LocalNotifications()
            
            registrar.addMethodCallDelegate(self, channel: self.flutterChannel!)
            registrar.addApplicationDelegate(self)
            
            if LocalNotifications.debug {
                Logger.d(SwiftLocalNotificationsPlugin.TAG, "Local Notifications plugin attached to iOS \(floor(NSFoundationVersionNumber))")
                Logger.d(SwiftLocalNotificationsPlugin.TAG, "Local Notifications - App Group : \(Definitions.USER_DEFAULT_TAG)")
            }
        }
        catch {
            Logger.e(SwiftLocalNotificationsPlugin.TAG, error.localizedDescription)
        }
    }
    
    private func detacheLocalNotifications(
        usingRegistrar registrar: FlutterPluginRegistrar
    ){
        flutterChannel = nil
        
        localNotifications?.detachAsMainInstance(listener: self)
        localNotifications?.dispose()
        localNotifications = nil
        
        if localNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, "Local Notifications plugin detached from iOS \(floor(NSFoundationVersionNumber))")
        }
    }
    
    public func onNewLocalEvent(eventType: String, content: [String : Any?]) {
        if Definitions.EVENT_SILENT_ACTION == eventType {
            var updatedContent = [:].merging(content, uniquingKeysWith: { (current, _) in current })
            updatedContent[Definitions.ACTION_HANDLE] = localNotifications?.getActionHandle()
            flutterChannel?.invokeMethod(eventType, arguments: updatedContent)
        }
        else {
            flutterChannel?.invokeMethod(eventType, arguments: content)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if localNotifications == nil {
            let exception:LocalNotificationsException
                = ExceptionFactory
                        .shared
                        .createNewLocalException(
                            className: SwiftLocalNotificationsPlugin.TAG,
                            code: ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                            message: "Local notifications is currently not available",
                            detailedCode: ExceptionCode.DETAILED_INITIALIZATION_FAILED+".localNotifications.core")
            
            result(
                FlutterError.init(
                    code: exception.code,
                    message: exception.message,
                    details: exception.detailedCode
                )
            )
            return
        }
		
		do {
			switch call.method {
				
				case Definitions.CHANNEL_METHOD_INITIALIZE:
                    try channelMethodInitialize(call: call, result: result)
					return
                
                case Definitions.CHANNEL_METHOD_SET_ACTION_HANDLE:
                    try channelMethodSetActionHandle(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_GET_DRAWABLE_DATA:
                    try channelMethodGetDrawableData(call: call, result: result)
                    return

				case Definitions.CHANNEL_METHOD_IS_NOTIFICATION_ALLOWED:
                    try channelMethodIsNotificationAllowed(call: call, result: result)
					return
                
                case Definitions.CHANNEL_METHOD_SHOULD_SHOW_RATIONALE:
                    try channelMethodShouldShowRationale(call: call, result: result)
                    return
                
                case Definitions.CHANNEL_METHOD_SHOW_NOTIFICATION_PAGE:
                    try channelMethodShowNotificationConfigPage(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_SHOW_ALARM_PAGE:
                    try channelMethodShowPreciseAlarmsPage(call: call, result: result)
                    return
                
                case Definitions.CHANNEL_METHOD_SHOW_GLOBAL_DND_PAGE:
                    try channelMethodShowGlobalDndPage(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_CHECK_PERMISSIONS:
                    try channelMethodCheckPermissions(call: call, result: result)
                    return

				case Definitions.CHANNEL_METHOD_REQUEST_NOTIFICATIONS:
                    try channelMethodRequestNotification(call: call, result: result)
					return
						
				case Definitions.CHANNEL_METHOD_CREATE_NOTIFICATION:
                    try channelMethodCreateNotification(call: call, result: result)
					return
					
				case Definitions.CHANNEL_METHOD_SET_NOTIFICATION_CHANNEL:
                    try channelMethodSetChannel(call: call, result: result)
					return
                
                case Definitions.CHANNEL_METHOD_REMOVE_NOTIFICATION_CHANNEL:
                    try channelMethodRemoveChannel(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_GET_INITIAL_ACTION:
                    try channelMethodGetInitialAction(call: call, result: result)
                    return
					
				case Definitions.CHANNEL_METHOD_GET_BADGE_COUNT:
                    try channelMethodGetBadgeCounter(call: call, result: result)
					return
					
				case Definitions.CHANNEL_METHOD_SET_BADGE_COUNT:
                    try channelMethodSetBadgeCounter(call: call, result: result)
					return

				case Definitions.CHANNEL_METHOD_INCREMENT_BADGE_COUNT:
                    try channelMethodIncrementBadgeCounter(call: call, result: result)
					return

				case Definitions.CHANNEL_METHOD_DECREMENT_BADGE_COUNT:
                    try channelMethodDecrementBadgeCounter(call: call, result: result)
					return
					
				case Definitions.CHANNEL_METHOD_RESET_BADGE:
                    try channelMethodResetBadge(call: call, result: result)
					return
                    
                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATION:
                    try channelMethodDismissNotification(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULE:
                    try channelMethodCancelSchedule(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATION:
                    try channelMethodCancelNotification(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATIONS_BY_CHANNEL_KEY:
                    try channelMethodDismissNotificationsByChannelKey(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULES_BY_CHANNEL_KEY:
                    try channelMethodCancelSchedulesByChannelKey(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATIONS_BY_CHANNEL_KEY:
                    try channelMethodCancelNotificationsByChannelKey(call: call, result: result)
                    return

                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATIONS_BY_GROUP_KEY:
                    try channelMethodDismissNotificationsByGroupKey(call: call, result: result)
                    return

                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULES_BY_GROUP_KEY:
                    try channelMethodCancelSchedulesByGroupKey(call: call, result: result)
                    return

                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATIONS_BY_GROUP_KEY:
                    try channelMethodCancelNotificationsByGroupKey(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_DISMISS_ALL_NOTIFICATIONS:
                    try channelMethodDismissAllNotifications(call: call, result: result)
                    return
					
				case Definitions.CHANNEL_METHOD_CANCEL_ALL_SCHEDULES:
                    try channelMethodCancelAllSchedules(call: call, result: result)
					return
                    
                case Definitions.CHANNEL_METHOD_CANCEL_ALL_NOTIFICATIONS:
                    try channelMethodCancelAllNotifications(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_GET_NEXT_DATE:
                    try channelMethodGetNextDate(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_GET_UTC_TIMEZONE_IDENTIFIER:
                    try channelMethodGetUTCTimeZoneIdentifier(call: call, result: result)
                    return
                    
                case Definitions.CHANNEL_METHOD_GET_LOCAL_TIMEZONE_IDENTIFIER:
                    try channelMethodGetLocalTimeZoneIdentifier(call: call, result: result)
                    return
					
				case Definitions.CHANNEL_METHOD_LIST_ALL_SCHEDULES:
					try channelMethodListAllSchedules(call: call, result: result)
					return

				default:
                    throw ExceptionFactory
                        .shared
                        .createNewLocalException(
                            className: SwiftLocalNotificationsPlugin.TAG,
                            code: ExceptionCode.CODE_MISSING_METHOD,
                            message: "method \(call.method) not found",
                            detailedCode: ExceptionCode.DETAILED_MISSING_METHOD+"."+call.method)
			}

        } catch let localError as LocalNotificationsException {
            result(
                FlutterError.init(
                    code: localError.code,
                    message: localError.message,
                    details: localError.detailedCode
                )
            )
        } catch {
            let exception =
                ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                        detailedCode: ExceptionCode.DETAILED_UNEXPECTED_ERROR,
                        originalException: error)
            
            result(
                FlutterError.init(
                    code: exception.code,
                    message: exception.message,
                    details: exception.detailedCode
                )
            )
        }
    }
    
    private func channelMethodGetDrawableData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        
        let bitmapReference:String = call.arguments as! String
        guard let data:Data =
                localNotifications?
                    .getDrawableData(bitmapReference: bitmapReference)
        else {
            result(nil)
            return
        }
        
        result(
            FlutterStandardTypedData
                .init(bytes: data))
    }
    
    private func channelMethodSetChannel(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
		guard let channelData:[String:Any?] = call.arguments as? [String:Any?]
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Channel data is invalid",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.data")
        }
                
		let channel:NotificationChannelModel =
                NotificationChannelModel()
                    .fromMap(
                        arguments: channelData) as! NotificationChannelModel
		
        let updated = localNotifications?
                            .setChannel(channel: channel) ?? false
        
        if LocalNotifications.debug {
            Logger.e(SwiftLocalNotificationsPlugin.TAG, "Channel \(updated ? "" : "wasn't ")updated")
        }
		
		result(updated)
    }
    
    private func channelMethodRemoveChannel(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
	
		guard let channelKey:String = call.arguments as? String
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Empty channel key",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.key")
		}
        
        if localNotifications?
            .removeChannel(channelKey: channelKey) ?? false {
            
            if LocalNotifications.debug {
                Logger.d(SwiftLocalNotificationsPlugin.TAG, "Channel removed")
            }
            result(true)
        }
        else {
            if LocalNotifications.debug {
                Logger.d(SwiftLocalNotificationsPlugin.TAG, "Channel '\(channelKey)' not found")
            }
            result(false)
        }
    }
    
    private func channelMethodGetInitialAction(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let removeFromEvents:Bool = call.arguments as? Bool ?? false
        
        localNotifications?
            .getInitialAction(
                removeFromEvents: removeFromEvents,
                completionHandler: { actionReceived in
                    result(actionReceived?.toMap())
                })
    }
    
    private func channelMethodGetBadgeCounter(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        result(
            localNotifications?
                .getGlobalBadgeCounter() ?? 0)
    }
    
    private func channelMethodSetBadgeCounter(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let ammount:Int = call.arguments as? Int
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid Badge value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".badge.value")
        }
        
        localNotifications?
            .setGlobalBadgeCounter(
                withAmmount: ammount)
        
        result(nil)
    }

    private func channelMethodIncrementBadgeCounter(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        result(
            localNotifications?
                .incrementGlobalBadgeCounter() ?? 0)
    }

    private func channelMethodDecrementBadgeCounter(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        result(
            localNotifications?
                .decrementGlobalBadgeCounter() ?? 0)
    }
    
    private func channelMethodResetBadge(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .resetGlobalBadgeCounter()
        result(nil)
    }
    
    private func channelMethodDismissNotification(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let notificationId:Int? = call.arguments as? Int
        if notificationId == nil || notificationId! < 0 {
            throw ExceptionFactory
                .shared
                .createNewLocalException(
                    className: SwiftLocalNotificationsPlugin.TAG,
                    code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                    message: "Invalid id value",
                    detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id")
        }
        
        let dismissed =
            localNotifications?
                .dismissNotification(byId: notificationId!) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, dismissed ?
                  "Notification \(notificationId!) dismissed":
                  "Notification \(notificationId!) was not found")
        }
        
        result(dismissed)
    }
    
    private func channelMethodCancelSchedule(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let notificationId:Int? = call.arguments as? Int
        if notificationId == nil || notificationId! < 0 {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid id value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id")
        }
        
        let cancelled =
            localNotifications?
                .cancelSchedule(byId: notificationId!) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, cancelled ?
                  "Schedule \(notificationId!) cancelled":
                  "Schedule \(notificationId!) was not found")
        }
        
        result(cancelled)
    }
    
    private func channelMethodCancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let notificationId:Int? = call.arguments as? Int
        if notificationId == nil || notificationId! < 0 {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid id value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id")
        }
        
        let cancelled =
            localNotifications?
                .cancelNotification(byId: notificationId!) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, cancelled ?
                  "Notification \(notificationId!) cancelled":
                  "Notification \(notificationId!) was not found")
        }
        
        result(cancelled)
    }

    private func channelMethodDismissNotificationsByChannelKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let channelKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid channel key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey")
        }
        
        let success =
            localNotifications?
                .dismissNotifications(byChannelKey: channelKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Notifications from channel \(channelKey) dismissed":
                  "Notifications from channel \(channelKey) not found")
        }
        
        result(success)
    }

    private func channelMethodCancelSchedulesByChannelKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let channelKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid channel key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey")
        }
        
        let success =
            localNotifications?
                .cancelSchedules(byChannelKey: channelKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Scheduled notifications from channel \(channelKey) canceled":
                  "Scheduled notifications from channel \(channelKey) not found")
        }
        
        result(success)
    }

    private func channelMethodCancelNotificationsByChannelKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let channelKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid channel key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey")
        }
        
        let success =
            localNotifications?
                .cancelNotifications(byChannelKey: channelKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Notifications and schedules from channel \(channelKey) canceled":
                  "Notifications and schedules from channel \(channelKey) not found")
        }
        
        result(success)
    }

    private func channelMethodDismissNotificationsByGroupKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let groupKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid group key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey")
        }
        
        let success =
            localNotifications?
                .dismissNotifications(byGroupKey: groupKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Notifications from group \(groupKey) dismissed":
                  "Notifications from group \(groupKey) not found")
        }
        
        result(success)
    }

    private func channelMethodCancelSchedulesByGroupKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let groupKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid group key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey")
        }
        
        let success =
            localNotifications?
                .cancelSchedules(byGroupKey: groupKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Scheduled notifications from group \(groupKey) cancelled":
                  "Scheduled notifications from group \(groupKey) not found")
        }
        
        result(success)
    }

    private func channelMethodCancelNotificationsByGroupKey(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let groupKey:String = call.arguments as? String else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Invalid group key value",
                        detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey")
        }
        
        let success =
            localNotifications?
                .cancelNotifications(byGroupKey: groupKey) ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, success ?
                  "Notifications and schedules from group \(groupKey) cancelled":
                  "Notifications and schedules from group \(groupKey) not found")
        }
        
        result(success)
    }
    
    private func channelMethodDismissAllNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let success =
            localNotifications?
                .dismissAllNotifications() ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, "All notifications was dismissed")
        }
        
        result(success)
    }
    
    private func channelMethodCancelAllSchedules(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let success =
            localNotifications?
                .cancelAllSchedules() ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, "All schedules was cancelled")
        }
        
        result(success)
    }

    private func channelMethodCancelAllNotifications(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let success =
            localNotifications?
                .cancelAllNotifications() ?? false
        
        if LocalNotifications.debug {
            Logger.d(SwiftLocalNotificationsPlugin.TAG, "All notifications was cancelled")
        }
        
        result(success)
    }
    
    private func channelMethodListAllSchedules(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .listAllPendingSchedules { (schedules:[NotificationModel]) in
                var mapData:[[String:Any?]] = []
                for schedule in schedules {
                    mapData.append(schedule.toMap())
                }
                result(mapData)
            }
    }
    
    private func channelMethodGetNextDate(call: FlutterMethodCall, result: @escaping FlutterResult) throws {

        let platformParameters:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        guard let fixedDate:String = platformParameters[Definitions.NOTIFICATION_INITIAL_FIXED_DATE] as? String
        else  {
            result(nil)
            return
        }
        guard let scheduleData:[String : Any?] =
                platformParameters[Definitions.NOTIFICATION_MODEL_SCHEDULE] as? [String : Any?]
        else {
            result(nil)
            return
        }
        
        let timezone:String =
            (platformParameters[Definitions.NOTIFICATION_SCHEDULE_TIMEZONE] as? String) ??
            DateUtils.shared.utcTimeZone.identifier
        
        guard let scheduleModel:NotificationScheduleModel =
                (scheduleData[Definitions.NOTIFICATION_SCHEDULE_INTERVAL] != nil) ?
                    NotificationIntervalModel().fromMap(arguments: scheduleData) as? NotificationScheduleModel :
                    NotificationCalendarModel().fromMap(arguments: scheduleData) as? NotificationScheduleModel
        else {
            result(nil)
            return
        }
        
        let nextValidDate:RealDateTime? =
                localNotifications?
                    .getNextValidDate(
                        scheduleModel: scheduleModel,
                        fixedDate: fixedDate,
                        timeZoneName: timezone)
        
        result(nextValidDate?.description)
    }
    
    private func channelMethodGetUTCTimeZoneIdentifier(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        result(
            localNotifications?
                .getUtcTimeZone()
                .identifier ?? "UTC")
    }
    
    private func channelMethodGetLocalTimeZoneIdentifier(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        result(
            localNotifications?
                .getLocalTimeZone()
                .identifier ?? "UTC")
    }
    
    private func channelMethodIsNotificationAllowed(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .areNotificationsGloballyAllowed(
                whenCompleted: { (allowed) in
                    result(allowed)
                })
    }
    
    private func channelMethodShowPreciseAlarmsPage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .showPreciseAlarmPage(
                whenUserReturns: {
                    result(true)
                })
    }
    
    private func channelMethodShowGlobalDndPage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .showDnDGlobalOverridingPage(
                whenUserReturns: {
                    result(true)
                })
    }
    
    private func channelMethodShowNotificationConfigPage(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        localNotifications?
            .showNotificationPage(
                whenUserReturns: {
                    result(true)
                })
    }

    private func channelMethodCheckPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let platformParameters:[String:Any?] = call.arguments as? [String:Any?]
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                        message: "Arguments are missing",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS)
        }
        
        let channelKey:String? = platformParameters[Definitions.NOTIFICATION_CHANNEL_KEY] as? String
        guard let permissions:[String] = platformParameters[Definitions.NOTIFICATION_PERMISSIONS] as? [String] else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }

        if(permissions.isEmpty){
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }
        
        localNotifications?
            .arePermissionsAllowed(
                permissions,
                filteringByChannelKey: channelKey,
                whenGotResults: { (permissionsAllowed) in
                    result(permissionsAllowed)
                })
    }
    
    private func channelMethodShouldShowRationale(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let platformParameters:[String:Any?] = call.arguments as? [String:Any?]
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                        message: "Arguments are missing",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS)
        }
        
        let channelKey:String? = platformParameters[Definitions.NOTIFICATION_CHANNEL_KEY] as? String
        guard let permissions:[String] = platformParameters[Definitions.NOTIFICATION_PERMISSIONS] as? [String] else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }

        if(permissions.isEmpty){
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }

        localNotifications?
            .shouldShowRationale(
                permissions,
                filteringByChannelKey: channelKey,
                whenGotResults: { (permissionsAllowed) in
                    result(permissionsAllowed)
                })
    }

    private func channelMethodRequestNotification(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let platformParameters:[String:Any?] = call.arguments as? [String:Any?]
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                        message: "Arguments are missing",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS)
        }
        
        let channelKey:String? = platformParameters[Definitions.NOTIFICATION_CHANNEL_KEY] as? String
        guard let permissions:[String] = platformParameters[Definitions.NOTIFICATION_PERMISSIONS] as? [String] else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }

        if(permissions.isEmpty){
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Permission list is required",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList")
        }
        
        try localNotifications?
                .requestUserPermissions(
                    permissions,
                    filteringByChannelKey: channelKey,
                    whenUserReturns: { (deniedPermissions) in
                        result(deniedPermissions)
                    })
    }
    
    private func channelMethodCreateNotification(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let pushData:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        guard let notificationModel = NotificationModel().fromMap(arguments: pushData) as? NotificationModel
        else {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                        message: "Notification content is invalid",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".notificationModel.data")
        }
        
        try localNotifications?
            .createNotification(
                fromNotificationModel: notificationModel,
                afterCreated: { sent, content, error in
                    
                    if error != nil {
                        let flutterError:FlutterError?
                        if let localException = error as? LocalNotificationsException {
                            flutterError = FlutterError.init(
                                code: localException.code,
                                message: localException.message,
                                details: localException.detailedCode
                            )
                        }
                        else {
                            let localException = ExceptionFactory
                                .shared
                                .createNewLocalException(
                                    className: SwiftLocalNotificationsPlugin.TAG,
                                    code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                                    message: "Notification content is invalid",
                                    detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".notificationModel.data")
                            
                            flutterError = FlutterError.init(
                                code: localException.code,
                                message: localException.message,
                                details: localException.detailedCode
                            )
                        }
                        result(flutterError)
                        return
                    }
                    else {
                        result(sent)
                        return
                    }
                    
                })
    }
    
    private func channelMethodInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let platformParameters:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        if platformParameters.isEmpty {
            throw ExceptionFactory
                    .shared
                    .createNewLocalException(
                        className: SwiftLocalNotificationsPlugin.TAG,
                        code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                        message: "Arguments are missing",
                        detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS)
        }
        
		let defaultIconPath:String? = platformParameters[Definitions.INITIALIZE_DEFAULT_ICON] as? String
        let debug:Bool = platformParameters[Definitions.INITIALIZE_DEBUG_MODE] as? Bool ?? false
        let dartBgHandle:Int64 = platformParameters[Definitions.BACKGROUND_HANDLE] as? Int64 ?? 0
        
        var channels:[NotificationChannelModel] = []
        let channelsData:[Any] = platformParameters[Definitions.INITIALIZE_CHANNELS] as? [Any] ?? []
        
        for channelData in channelsData {
            guard let channelMap = channelData as? [String : Any?]
            else {
                throw ExceptionFactory
                        .shared
                        .createNewLocalException(
                            className: SwiftLocalNotificationsPlugin.TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "Notification channel `\(channelsData)` is invalid",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.invalid.\(channelsData)")
            }
            
            guard let channel:NotificationChannelModel =
                            NotificationChannelModel()
                                .fromMap(arguments: channelMap) as? NotificationChannelModel
            else {
                throw ExceptionFactory
                        .shared
                        .createNewLocalException(
                            className: SwiftLocalNotificationsPlugin.TAG,
                            code: ExceptionCode.CODE_INVALID_ARGUMENTS,
                            message: "Notification channel `\(channelsData)` is invalid",
                            detailedCode: ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.invalid.\(channelsData)")
            }
            
            channels.append(channel)
        }

        try localNotifications?
                .initialize(
                    defaultIconPath: defaultIconPath,
                    channels: channels,
                    backgroundHandle: dartBgHandle,
                    debug: debug)
		
		Logger.d(SwiftLocalNotificationsPlugin.TAG, "Local Notifications service initialized")
		result(localNotifications != nil)
    }
    
    private func channelMethodSetActionHandle(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let platformParameters:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        let actionHandle:Int64 = platformParameters[Definitions.ACTION_HANDLE] as? Int64 ?? 0
        let getLostDisplayed:Bool = platformParameters[Definitions.RECOVER_DISPLAYED] as? Bool ?? false
        
        localNotifications?.attachAsMainInstance(usingLocalEventListener: self)
        try localNotifications?
                .setActionHandle(
                        actionHandle: actionHandle,
                        recoveringLostDisplayed: getLostDisplayed)
        
        let success = actionHandle != 0
        if !success {
            Logger.e(SwiftLocalNotificationsPlugin.TAG, "Attention: there is no valid static method to receive notification action data in background")
        }
        
        result(success)
    }
}
#endif
