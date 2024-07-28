import Vapor

func routes(_ app: Application) throws {
    try! app.register(collection: AuthenticationController())
    try! app.register(collection: UserController())
}
