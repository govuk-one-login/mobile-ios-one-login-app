// swiftlint:disable line_length
struct MockJWTs {
    ///
    /// Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    /// Payload:
    /// ```
    /// {
    ///    "aud": "bYrcuRVvnylvEgYSSbBjwXzHrwJ",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "c722338b-b18b-4a6c-80d8-c295e214e379",
    ///    "persistent_id": "af835f3a-b3f1-4b50-b3db-88c185eae46b",
    ///    "iat": 1772632245,
    ///    "exp": 1772632425,
    ///    "nonce": "ocOunJO44mNhS5dZCVB_omA0FJggLP25nM5jsDD4uz0",
    ///    "email": "mock@email.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "LpyvURud63e1LDVO0AEf7AJvXUrFlCGRfF-tl63vUe0"
    /// }
    /// ```
    static let genericToken = """
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.eyJhdWQiOiJiWXJjdVJWdm55bHZFZ1lTU2JCandYekhyd0oiLCJpc3MiOiJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwic3ViIjoiYzcyMjMzOGItYjE4Yi00YTZjLTgwZDgtYzI5NWUyMTRlMzc5IiwicGVyc2lzdGVudF9pZCI6ImFmODM1ZjNhLWIzZjEtNGI1MC1iM2RiLTg4YzE4NWVhZTQ2YiIsImlhdCI6MTc3MjYzMjI0NSwiZXhwIjoxNzcyNjMyNDI1LCJub25jZSI6Im9jT3VuSk80NG1OaFM1ZFpDVkJfb21BMEZKZ2dMUDI1bk01anNERDR1ejAiLCJlbWFpbCI6Im1vY2tAZW1haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInVrLmdvdi5hY2NvdW50LnRva2VuL3dhbGxldFN0b3JlSWQiOiJMcHl2VVJ1ZDYzZTFMRFZPMEFFZjdBSnZYVXJGbENHUmZGLXRsNjN2VWUwIn0.7ocBIY_vVO83eYlYpJJJuFvl_GtWqwkeYzEDiNjSfUGGatnIW5ahcoEC-tjkIxQhVjpKhmcS_HcE34836OSXrw
"""
    
    ///
    /// Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    /// Payload:
    /// ```
    /// {
    ///    "aud": "MOBILE_CLIENT_ID",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "9c5aac56-14c0-42d6-931d-b46cd3d35ae1",
    ///    "persistent_id": "af835f3a-b3f1-4b50-b3db-88c185eae46b",
    ///    "iat": 1715265903,
    ///    "exp": 1716475503,
    ///    "email": "abc@example.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "gjb6VfZa0q4h7pMLdnDnWbRbQeHGiriPn-iI8JbADVY"
    /// }
    /// ```
    static let malformedToken = """
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.eyJhdWQiOiJNT0JJTEVfQ0xJRU5UX0lEIiwiaXNzIjoiaHR0cHM6Ly90b2tlbi5idWlsZC5hY2NvdW50Lmdvdi51ayIsInN1YiI6IjljNWFhYzU2LTE0YzAtNDJkNi05MzFkLWI0NmNkM2QzNWFlMSIsImlhdCI6MTcxNTI2NTkwMywiZXhwIjoxNzE2NDc1NTAzLCJlbWFpbCI6ImFiY0BleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJ1ay5nb3YuYWNjb3VudC50b2tlbi93YWxsZXRTdG9yZUlkIjoiZ2piNlZmWmEwcTRoN3BNTGRuRG5XYlJiUWVIR2lyaVBuLWlJOEpiQURWWSJ9
"""
    
    ///
    /// Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    /// Payload:
    /// ```
    /// {
    ///    "aud": "bYrcuRVvnylvEgYSSbBjwXzHrwJ",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "f97f64cc-7725-4d4c-bb4d-3789a0959438",
    ///    "persistent_id": "1d003342-efd1-4ded-9c11-32e0f15acae6",
    ///    "iat": 1719397578,
    ///    "exp": 1719397758,
    ///    "nonce": "dySMrZsDhYcZPzt2GIFRjre1KakNwhMG5gSm2QMwHqE",
    ///    "email": "mock@email.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "gjb6VfZa0q4h7pMLdnDnWbRbQeHGiriPn-iI8JbADVY"
    /// }
    /// ```
    /// Signature: a signature that is not expected for the expected key
    static let tokenWithInvalidSignature = """
ewogICJhbGciOiAiRVMyNTYiLAogICJ0eXAiOiAiSldUIiwKICAia2lkIjogIjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCIKfQ.ewogICAgImF1ZCI6ICJiWXJjdVJWdm55bHZFZ1lTU2JCandYekhyd0oiLAogICAgImlzcyI6ICJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwKICAgICJzdWIiOiAiZjk3ZjY0Y2MtNzcyNS00ZDRjLWJiNGQtMzc4OWEwOTU5NDM4IiwKICAgICJwZXJzaXN0ZW50X2lkIjogIjFkMDAzMzQyLWVmZDEtNGRlZC05YzExLTMyZTBmMTVhY2FlNiIsCiAgICAiaWF0IjogMTcxOTM5NzU3OCwKICAgICJleHAiOiAxNzE5Mzk3NzU4LAogICAgIm5vbmNlIjogImR5U01yWnNEaFljWlB6dDJHSUZSanJlMUtha053aE1HNWdTbTJRTXdIcUUiLAogICAgImVtYWlsIjogIm1vY2tAZW1haWwuY29tIiwKICAgICJlbWFpbF92ZXJpZmllZCI6IHRydWUsCiAgICAidWsuZ292LmFjY291bnQudG9rZW4vd2FsbGV0U3RvcmVJZCI6ICJnamI2VmZaYTBxNGg3cE1MZG5EbldiUmJRZUhHaXJpUG4taUk4SmJBRFZZIgp9.ACgEiMqIEY8tamcBen9Tm5JVm6gbZka46UYcLmlYYqof-g0RoGxdlGn9pGQK1Ek7hEPY6bFT-JtVZXVmOKeLtg
"""

    ///
    /// Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    /// Payload:
    /// ```
    /// {
    ///    "aud": "bYrcuRVvnylvEgYSSbBjwXzHrwJ",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "f97f64cc-7725-4d4c-bb4d-3789a0959438",
    ///    "persistent_id": "1d003342-efd1-4ded-9c11-32e0f15acae6",
    ///    "iat": 1719397578,
    ///    "exp": 1719397758,
    ///    "nonce": "dySMrZsDhYcZPzt2GIFRjre1KakNwhMG5gSm2QMwHqE",
    ///    "email": "mock@email.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "gjb6VfZa0q4h7pMLdnDnWbRbQeHGiriPn-iI8JbADVY"
    /// }
    /// ```
    static let tokenMissingSignature = """
ewogICJhbGciOiAiRVMyNTYiLAogICJ0eXAiOiAiSldUIiwKICAia2lkIjogIjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCIKfQ.ewogICAgImF1ZCI6ICJiWXJjdVJWdm55bHZFZ1lTU2JCandYekhyd0oiLAogICAgImlzcyI6ICJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwKICAgICJzdWIiOiAiZjk3ZjY0Y2MtNzcyNS00ZDRjLWJiNGQtMzc4OWEwOTU5NDM4IiwKICAgICJwZXJzaXN0ZW50X2lkIjogIjFkMDAzMzQyLWVmZDEtNGRlZC05YzExLTMyZTBmMTVhY2FlNiIsCiAgICAiaWF0IjogMTcxOTM5NzU3OCwKICAgICJleHAiOiAxNzE5Mzk3NzU4LAogICAgIm5vbmNlIjogImR5U01yWnNEaFljWlB6dDJHSUZSanJlMUtha053aE1HNWdTbTJRTXdIcUUiLAogICAgImVtYWlsIjogIm1vY2tAZW1haWwuY29tIiwKICAgICJlbWFpbF92ZXJpZmllZCI6IHRydWUsCiAgICAidWsuZ292LmFjY291bnQudG9rZW4vd2FsbGV0U3RvcmVJZCI6ICJnamI2VmZaYTBxNGg3cE1MZG5EbldiUmJRZUhHaXJpUG4taUk4SmJBRFZZIgp9.
"""
    
    ///
    /// Header: {"alg":"none","typ":"JWT"}
    /// Payload:
    /// ```
    /// {
    ///    "aud": "bYrcuRVvnylvEgYSSbBjwXzHrwJ",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "f97f64cc-7725-4d4c-bb4d-3789a0959438",
    ///    "persistent_id": "1d003342-efd1-4ded-9c11-32e0f15acae6",
    ///    "iat": 1719397578,
    ///    "exp": 1719397758,
    ///    "nonce": "dySMrZsDhYcZPzt2GIFRjre1KakNwhMG5gSm2QMwHqE",
    ///    "email": "mock@email.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "gjb6VfZa0q4h7pMLdnDnWbRbQeHGiriPn-iI8JbADVY"
    /// }
    /// ```
    static let tokenWithNoneAlgorithm = """
ewogICJhbGciOiAibm9uZSIsCiAgInR5cCI6ICJKV1QiLAogICJraWQiOiAiMTZkYjY1ODctNTQ0NS00NWQ2LWE3ZDktOTg3ODFlYmRmOTNkIgp9.ewogICAgImF1ZCI6ICJiWXJjdVJWdm55bHZFZ1lTU2JCandYekhyd0oiLAogICAgImlzcyI6ICJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwKICAgICJzdWIiOiAiZjk3ZjY0Y2MtNzcyNS00ZDRjLWJiNGQtMzc4OWEwOTU5NDM4IiwKICAgICJwZXJzaXN0ZW50X2lkIjogIjFkMDAzMzQyLWVmZDEtNGRlZC05YzExLTMyZTBmMTVhY2FlNiIsCiAgICAiaWF0IjogMTcxOTM5NzU3OCwKICAgICJleHAiOiAxNzE5Mzk3NzU4LAogICAgIm5vbmNlIjogImR5U01yWnNEaFljWlB6dDJHSUZSanJlMUtha053aE1HNWdTbTJRTXdIcUUiLAogICAgImVtYWlsIjogIm1vY2tAZW1haWwuY29tIiwKICAgICJlbWFpbF92ZXJpZmllZCI6IHRydWUsCiAgICAidWsuZ292LmFjY291bnQudG9rZW4vd2FsbGV0U3RvcmVJZCI6ICJnamI2VmZaYTBxNGg3cE1MZG5EbldiUmJRZUhHaXJpUG4taUk4SmJBRFZZIgp9.

"""
}
// swiftlint:enable line_length
