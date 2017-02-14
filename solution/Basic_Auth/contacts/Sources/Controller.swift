import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON
import Credentials
import CredentialsHTTP


public class Controller {
    public let router: Router
    var contacts: [Contact] = []
    var contactsID = 0;
    
    public init(kituraRouter: Router){
        router = kituraRouter
        router.all("*", middleware: BodyParser())
        setUpSecurity(kituraRouter: router)
        router.get("/contacts", handler: getContacts)
        router.post("/contacts", handler: createContact)
        router.put("/contact/:id", handler: updateContact)
        router.delete("/contact/:id", handler: deleteContact)
        
        // load some initial contacts
        do{
            var contact = try addContact(json: JSON(["first": "Alice", "last": "Zebber", "phone": "555.1111"]))
            Log.info("added contact \(contact)")
            contact = try addContact(json: JSON(["first": "Bob", "last": "Yith", "phone": "555.1212"]))
            Log.info("added contact \(contact)")
            contact = try addContact(json: JSON(["first": "Carol", "last": "Xorn", "phone": "555.1313"]))
            Log.info("added contact \(contact)")
        } catch {
            Log.error("Error loading default contacts")
        }
        
    }
    
    func setUpSecurity(kituraRouter: Router){
        let credentials = Credentials()
        let users = ["Tom" : "12345", "Jane" : "p@ssw0rd", "localuser" : "passw0rd"]
        let basicAuthCredentials = CredentialsHTTPBasic(verifyPassword: { userId, password, callback in
            if let storedPassword = users[userId] {
                if (storedPassword == password) {
                    callback(UserProfile(id: userId, displayName: userId, provider: "HTTPBasic"))
                }
            }
            // else if userId or password does not match
            callback(nil)
        }, realm: "Users")
        
        
        credentials.register(plugin: basicAuthCredentials)
        // We allow read only but for add update and delete require signon
        router.post("/contacts", middleware: credentials)
        router.all("/contact", middleware: credentials)
    }
    
    
    func addContact(json: JSON) throws -> Contact {
        var myjson = json
        myjson["id"].int = contactsID
        let contact = try Contact(json: myjson)
        contactsID += 1
        contacts.append(contact)
        return contact
    }
    
    func getContacts(request: RouterRequest, response: RouterResponse, callNextHandler: @escaping () -> Void) throws {
            Log.info("start: getContacts")
            let profile = request.userProfile
            let userId = profile?.id
            let userName = profile?.displayName
            Log.info("user id: \(userId), user name: \(userName)")
            response.send(json: JSON(contacts.dictionary))
            callNextHandler()
    }

    func createContact(
        request: RouterRequest,
        response: RouterResponse,
        callNextHandler: @escaping () -> Void) throws {
            Log.info("start: createContact")
            guard case let .json(jsonBody)? = request.body
                else {
                    response.status(.badRequest)
                    callNextHandler()
                    return
            }
            let profile = request.userProfile
            let userId = profile?.id
            let userName = profile?.displayName
            Log.info("user id: \(userId), user name: \(userName)")
            Log.info("jSonBody \(jsonBody)")
            let contact = try addContact(json: jsonBody)
            response.send(json: JSON(contact.dictionary))
            callNextHandler()
    }
    
    func updateContact(
        request: RouterRequest,
        response: RouterResponse,
        callNextHandler: @escaping () -> Void) throws {
            Log.info("start: updateContact")
            guard let parameterID = request.parameters["id"] else {
                    Log.error("id parameter not found in request")
                    response.status(.badRequest)
                    callNextHandler()
                    return
            }
            guard case let .json(jsonBody)? = request.body else {
                Log.error("Invalid JSON Body")
                response.status(.badRequest)
                callNextHandler()
                return
            }
            let profile = request.userProfile
            let userId = profile?.id
            let userName = profile?.displayName
            Log.info("user id: \(userId), user name: \(userName)")
            let contactID = Int(parameterID)
            Log.info("contactID \(contactID)")
            if let index = contacts.index(where: {$0.id == contactID}) {
                contacts[index] = try Contact(json: jsonBody)
                response.send(json: JSON(contacts[index].dictionary))
            } else {
                response.status(.badRequest)
            }
            callNextHandler()
    }

    func deleteContact(
        request: RouterRequest,
        response: RouterResponse,
        callNextHandler: @escaping () -> Void) throws {
            guard let parameterID = request.parameters["id"] else {
                response.status(.badRequest)
                Log.error("id parameter not found in request")
                callNextHandler()
                return
            }
            let profile = request.userProfile
            let userId = profile?.id
            let userName = profile?.displayName
            Log.info("user id: \(userId), user name: \(userName)")
            let contactID = Int(parameterID)
            Log.info("contactID \(contactID)")
            if let index = contacts.index(where: {$0.id == contactID}) {
                let removedContact = contacts[index]
                contacts.remove(at: index)
                response.send(json: JSON(removedContact.dictionary))
            } else {
                response.status(.badRequest)
            }
            callNextHandler()
        }

}
