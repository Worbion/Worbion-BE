//
//  InConsentBundleConfirmationResponseDTO.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor

// MARK: - InConsentBundleConfirmationResponseDTO
struct InConsentBundleConfirmationResponseDTO: Content {
    let consents: [InConsentBundleConfirmationResponseItemDTO]
}

// MARK: - ConsentBundleResponseItemDTO
struct InConsentBundleConfirmationResponseItemDTO: Content {
    let isRequired: Bool
    let attributedText: AttributedTextDTO
}

// MARK: - InBundleConsentEntity + InConsentBundleConfirmationResponseItemDTO
extension InBundleConsentEntity {
    func mapToInBundleConsentConfirmationResponse(request: Request) -> InConsentBundleConfirmationResponseItemDTO {
        let consentDeepLinkOption = ConsentDeepLinkOption.consentDetail(type: consent.consentType)
        let deepLinkStr = request.defaultDeepLinkGenerator.generate(option: consentDeepLinkOption)
        
        let linkDTO = LinkDTO(
            url: deepLinkStr,
            openType: .deepLink
        )
        
        let clickableText = ClickableTextDTO(
            text: confirmationClickablePartText,
            link: linkDTO
        )
        
        let attributedText = AttributedTextDTO(
            text: confirmationText,
            clickablePartsOfText: [clickableText]
        )
        
        let responseItem = InConsentBundleConfirmationResponseItemDTO(
            isRequired: isRequired,
            attributedText: attributedText
        )
        return responseItem
    }
}
