import Kitura
import LoggerAPI
import HeliumLogger
import CloudFoundryEnv

// Initialize HeliumLogger
HeliumLogger.use()

// Create a new router
let router = Router()

router.all("/static", middleware: StaticFileServer())

let controller = Controller(kituraRouter: router)
do{
    var appEnv = try CloudFoundryEnv.getAppEnv()
    var port = appEnv.port

    // Add an HTTP server and connect it to the router
    Kitura.addHTTPServer(onPort: port, with: router)
    // Start the Kitura runloop (this call never returns)
    Kitura.run()
} catch let error {
    Log.error(error.localizedDescription)
    Log.error("Kitura Server did not start!")
}
