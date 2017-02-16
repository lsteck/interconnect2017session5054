import PackageDescription

let package = Package(
    name: "contacts",
    dependencies:[
      .Package(url: "https://github.com/IBM-Swift/Kitura-CredentialsHTTP", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/HeliumLogger", majorVersion: 1, minor: 6)
    ]
)
