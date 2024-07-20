import Mailgun
import Vapor

extension MailgunDomain {
    static var worbionDomain: MailgunDomain { .init(Environment.get("MAILGUN_WORBION_DOMAIN") ?? "xxxx@domain.com", .us)}
}
