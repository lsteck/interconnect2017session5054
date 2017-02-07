//
//  controller.swift
//  contacts
//
//  Created by Larry Steck on 2/1/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON


public class Controller {
    public let router: Router
    var contacts: [Contact] = []
    var contactsID = 0;
    
    public init(kituraRouter: Router){
        router = kituraRouter
        router.all("*", middleware: BodyParser())
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
