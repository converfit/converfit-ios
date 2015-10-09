// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Conversation.swift instead.

import CoreData

public enum ConversationAttributes: String {
    case avatar = "avatar"
    case conectionStatus = "conectionStatus"
    case conversationKey = "conversationKey"
    case creationLastMessage = "creationLastMessage"
    case flagNewUserMessage = "flagNewUserMessage"
    case fname = "fname"
    case lastMessage = "lastMessage"
    case lastUpdate = "lastUpdate"
    case lname = "lname"
    case userKey = "userKey"
}

@objc public
class _Conversation: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Conversation"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Conversation.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var avatar: NSData

    // func validateAvatar(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var conectionStatus: String

    // func validateConectionStatus(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var conversationKey: String

    // func validateConversationKey(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var creationLastMessage: String

    // func validateCreationLastMessage(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var flagNewUserMessage: NSNumber

    // func validateFlagNewUserMessage(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var fname: String

    // func validateFname(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var lastMessage: String

    // func validateLastMessage(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var lastUpdate: String

    // func validateLastUpdate(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var lname: String

    // func validateLname(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var userKey: String

    // func validateUserKey(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

}

