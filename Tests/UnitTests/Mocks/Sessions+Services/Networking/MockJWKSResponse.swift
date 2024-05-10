import Foundation
// swiftlint:disable line_length
struct MockJWKSResponse {
    static var jwksJson: Data = {
        """
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
        """.data(using: .utf8)!
    }()
    
    static let idToken =  "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.eyJhdWQiOiJNT0JJTEVfQ0xJRU5UX0lEIiwiaXNzIjoiaHR0cHM6Ly90b2tlbi5idWlsZC5hY2NvdW50Lmdvdi51ayIsInN1YiI6IjBkZjZmZjg3LTc0MGItNGMzYy05YzIwLTU3ZjI5YjUyZTg0ZiIsImlhdCI6MTUzNjE2NTU0MCwiZXhwIjoxNTM2MTY1NzIwLCJlbWFpbCI6ImFiY0BleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfQ.IrlLVm5xg7b5psaCrYARqVo-6mSX8DOBfOwlPQ_XrE8PcNCW3DWXn_dHBzah-qLT4Tdf4Y0rb1-vE_pnRm2o8Q"
}
// swiftlint:enable line_length
