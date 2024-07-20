import Vapor

struct RegisterRequest: Content {
    let name: String
    let surname: String
    let username: String
    let email: String
    let password: String
    let confirmPassword: String
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(3...))
        validations.add("name", as: String.self, is: .characterSet(.letters))
        validations.add("surname", as: String.self, is: .count(2...))
        validations.add("surname", as: String.self, is: .characterSet(.letters))
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
        validations.add("password", as: String.self, is: .count(5...15))
    }
}

extension UserEntity {
    convenience init(from register: RegisterRequest, hash: String) throws {
        self.init(name: register.name, surname: register.surname, email: register.email, username: register.username, passwordHash: hash)
    }
}
