import Foundation
// swiftlint:disable line_length
struct MockJWKSResponse {
    static var jwksJson = Data("""
        {
            "keys": [
              {
                "kty": "EC",
                "x": "nfKPgSUMcrJ96ejGHr-tAvfzZOgLuFK-W_pz3Jjcs-Y",
                "y": "Z7xBQNM9ipvaDp1Lp3DNAn7RWQ_JaUBXstcXnefLR5k",
                "crv": "P-256",
                "use": "sig",
                "alg": "ES256",
                "kid": "16db6587-5445-45d6-a7d9-98781ebdf93d"
              },
              {
                "kty": "RSA",
                "n": "rhd_K6nAaBtW03UFkHuFlCZVbBm0-3qr5YF0UwPw7NECjGigoRNRE5UJ7oOLPOJr04Ju5vPqbyuTWLTqI_cjcnL68H2EUgEsunFHsexThk_lK5B5OpjYPbcqNVhPszwFHrqdzsFAjbFBN3EPDv90Lf8ZjnKXKzpQ0aMdD66n5jx8Av2dZ6H-63R5mGlOrpzyu5x31AcJ_N0YFpTyqy3a2nC--taagBpfq8rL4ypg7egfq0irRglfsXhbkt1p0IwI516jWSlvdhe4Z1yJbZU_dGt4bZemf7BWs7KfmPHQRkmRg09-VXZo80K5BPWRIXrYCurA-2wNafnRoO6KmDYuXw",
                "e": "AQAB",
                "use": "enc",
                "alg": "RSA-OAEP-256",
                "kid": "849bb6a3-eb58-471a-b279-75be3c60601b"
              }
            ]
        }
        """.utf8)
    
    static var jwksJsonNonMatchingKIDs = Data("""
        {
            "keys": [
              {
                "kty": "EC",
                "x": "nfKPgSUMcrJ96ejGHr-tAvfzZOgLuFK-W_pz3Jjcs-Z",
                "y": "Z7xBQNM9ipvaDp1Lp3DNAn7RWQ_JaUBXstcXnefLR58",
                "crv": "P-256",
                "use": "sig",
                "alg": "ES256",
                "kid": "16db6587-5445-45d6-a7d9-98781nomatch"
              },
              {
                "kty": "RSA",
                "n": "rhd_K6nAaBtW03UFkHuFlCZVbBm0-3qr5YF0UwPw7NECjGigoRNRE5UJ7oOLPOJr04Ju5vPqbyuTWLTqI_cjcnL68H2EUgEsunFHsexThk_lK5B5OpjYPbcqNVhPszwFHrqdzsFAjbFBN3EPDv90Lf8ZjnKXKzpQ0aMdD66n5jx8Av2dZ6H-63R5mGlOrpzyu5x31AcJ_N0YFpTyqy3a2nC--taagBpfq8rL4ypg7egfq0irRglfsXhbkt1p0IwI516jWSlvdhe4Z1yJbZU_dGt4bZemf7BWs7KfmPHQRkmRg09-VXZo80K5BPWRIXrYCurA-2wNafnRoO6KmDYuXw",
                "e": "AQAB",
                "use": "enc",
                "alg": "RSA-OAEP-256",
                "kid": "849bb6a3-eb58-471a-b279-75be3nomatch"
              }
            ]
        }
        """.utf8)
}
// swiftlint:enable line_length
