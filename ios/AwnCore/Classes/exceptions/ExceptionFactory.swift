//
//  ExceptionFactory.swift
//  local_notifications
//
//  Created by Hưng Nguyễn on 03/06/23.
//

import Foundation


public class ExceptionFactory {
    
    static let TAG:String = "ExceptionFactory"
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:ExceptionFactory?
    public static var shared:ExceptionFactory {
        get {
            ExceptionFactory.instance = ExceptionFactory.instance ?? ExceptionFactory()
            return ExceptionFactory.instance!
        }
    }
    private init(){}
    
    // ************** FACTORY METHODS ***********************
    
    public func createNewLocalException(
                className:String,
                code:String,
                message:String,
                detailedCode:String
    ) -> LocalNotificationsException {
        return createNewLocalException(
                fromClassName: className,
                withLocalException:
                    LocalNotificationsException(
                        className: className,
                        code: code,
                        message: message,
                        detailedCode: detailedCode))
    }

    public func createNewLocalException(
            className:String,
            code:String,
            message:String,
            detailedCode:String,
            exception:Error
    ) -> LocalNotificationsException {
        return createNewLocalException(
                fromClassName: className,
                withLocalException:
                    LocalNotificationsException(
                        className: className,
                        code: code,
                        message: exception.localizedDescription,
                        detailedCode: detailedCode))
    }

    public func createNewLocalException(
            className:String,
            code:String,
            detailedCode:String,
            originalException:Error
    ) -> LocalNotificationsException {
        return createNewLocalException(
                fromClassName: className,
                withLocalException:
                    LocalNotificationsException(
                        className: className,
                        code: code,
                        message: originalException.localizedDescription,
                        detailedCode: detailedCode))
    }

    public func registerNewLocalException(
            className:String,
            code:String,
            message:String,
            detailedCode:String
    ) {
        _ = createNewLocalException(
                fromClassName: className,
                withLocalException:
                    LocalNotificationsException(
                        className: className,
                        code: code,
                        message: message,
                        detailedCode: detailedCode))
    }

    public func registerNewLocalException(
            className:String,
            code:String,
            message:String,
            detailedCode:String,
            originalException:Error
    ) {
        registerLocalException(
                fromClassName: className,
                withLocalException:
                    LocalNotificationsException(
                        className: className,
                        code: code,
                        message: message,
                        detailedCode: detailedCode))
    }

    public func registerNewLocalException(
            className:String,
            code:String,
            detailedCode:String,
            originalException:Error
    ) {
        registerLocalException(
            fromClassName: className,
            withLocalException:
                LocalNotificationsException(
                    className: className,
                    code: code,
                    message: originalException.localizedDescription,
                    detailedCode: detailedCode))
    }

    /// **************  FACTORY METHODS  *********************

    private func createNewLocalException(
        fromClassName className:String,
        withLocalException localException:LocalNotificationsException
    ) -> LocalNotificationsException {
        LocalExceptionReceiver
                .shared
                .notifyExceptionEvent(
                    fromClassName: className,
                    withLocalException: localException)
        return localException
    }

    private func registerLocalException(
        fromClassName className:String,
        withLocalException localException:LocalNotificationsException
    ) {
        LocalExceptionReceiver
                .shared
                .notifyExceptionEvent(
                    fromClassName: className,
                    withLocalException: localException)
    }
}
