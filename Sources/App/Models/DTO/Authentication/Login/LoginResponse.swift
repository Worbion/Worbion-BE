import Vapor

struct LoginResponse: Content {
    let accessToken: String
    let refreshToken: String
}

struct GuestLoginResponse: Content {
    let accessToken: String
}
