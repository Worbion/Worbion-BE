import Mailgun
import Vapor

extension MailgunDomain {
    static var sandbox: MailgunDomain { .init(Environment.get("MAILGUN_SANDBOX_MAIL") ?? "yourmail@yourdomain.com", .us)}
}
