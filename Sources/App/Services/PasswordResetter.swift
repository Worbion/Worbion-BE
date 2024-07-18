import Vapor
import Queues
import Fluent

struct PasswordResetter {
    let queue: Queue
    let config: AppConfig
    let generator: RandomGenerator
    let db: Database
    
    /// Sends a email to the user with a reset-password URL
    func reset(for user: UserEntity) async throws {
        let token = generator.generate(bits: 256)
        let resetPasswordToken = try PasswordTokenEntity(userID: user.requireID(), token: SHA256.hash(token))
        let url = resetURL(for: token)
        let email = ResetPasswordEmail(resetURL: url)
        try await resetPasswordToken.create(on: db)
        try await queue.dispatch(EmailJob.self, .init(email, to: user.email))
    }
    
    private func resetURL(for token: String) -> String {
        "\(config.frontendURL)/auth/reset-password?token=\(token)"
    }
}

// MARK: - Request + PasswordResetter
extension Request {
    var passwordResetter: PasswordResetter {
        return PasswordResetter(
            queue: queue,
            config: application.config,
            generator: application.random,
            db: db
        )
    }
}
