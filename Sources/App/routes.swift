import Vapor

func routes(_ app: Application) throws {
    try! app.register(collection: AuthenticationController())
    try! app.register(collection: UserController())
    try! app.register(collection: ConsentController())
    try! app.register(collection: DeviceController())
    try! app.register(collection: BankController())
    try! app.register(collection: UserBankAccountController())
    try! app.register(collection: AddressController())
}
