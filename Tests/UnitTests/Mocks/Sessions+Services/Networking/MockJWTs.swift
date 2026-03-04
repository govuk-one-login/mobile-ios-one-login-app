// swiftlint:disable line_length
struct MockJWTs {
    ///
    ///Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    ///Payload:
    ///```
    ///{
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
    ///}
    ///```
    static let genericToken = """
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9.eyJhdWQiOiJiWXJjdVJWdm55bHZFZ1lTU2JCandYekhyd0oiLCJpc3MiOiJodHRwczovL3Rva2VuLmJ1aWxkLmFjY291bnQuZ292LnVrIiwic3ViIjoiYzcyMjMzOGItYjE4Yi00YTZjLTgwZDgtYzI5NWUyMTRlMzc5IiwicGVyc2lzdGVudF9pZCI6ImFmODM1ZjNhLWIzZjEtNGI1MC1iM2RiLTg4YzE4NWVhZTQ2YiIsImlhdCI6MTc3MjYzMjI0NSwiZXhwIjoxNzcyNjMyNDI1LCJub25jZSI6Im9jT3VuSk80NG1OaFM1ZFpDVkJfb21BMEZKZ2dMUDI1bk01anNERDR1ejAiLCJlbWFpbCI6Im1vY2tAZW1haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInVrLmdvdi5hY2NvdW50LnRva2VuL3dhbGxldFN0b3JlSWQiOiJMcHl2VVJ1ZDYzZTFMRFZPMEFFZjdBSnZYVXJGbENHUmZGLXRsNjN2VWUwIn0.7ocBIY_vVO83eYlYpJJJuFvl_GtWqwkeYzEDiNjSfUGGatnIW5ahcoEC-tjkIxQhVjpKhmcS_HcE34836OSXrw
"""
    
    ///
    ///Header: {"alg":"ES256","typ":"JWT","kid":"16db6587-5445-45d6-a7d9-98781ebdf93d"}
    ///Payload:
    ///```
    ///{
    ///    "aud": "MOBILE_CLIENT_ID",
    ///    "iss": "https://token.build.account.gov.uk",
    ///    "sub": "9c5aac56-14c0-42d6-931d-b46cd3d35ae1",
    ///    "persistent_id": "af835f3a-b3f1-4b50-b3db-88c185eae46b",
    ///    "iat": 1715265903,
    ///    "exp": 1716475503,
    ///    "email": "abc@example.com",
    ///    "email_verified": true,
    ///    "uk.gov.account.token/walletStoreId": "gjb6VfZa0q4h7pMLdnDnWbRbQeHGiriPn-iI8JbADVY"
    ///}
    ///```
    static let malformedToken = """
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjE2ZGI2NTg3LTU0NDUtNDVkNi1hN2Q5LTk4NzgxZWJkZjkzZCJ9eyJhdWQiOiJNT0JJTEVfQ0xJRU5UX0lEIiwiaXNzIjoiaHR0cHM6Ly90b2tlbi5idWlsZC5hY2NvdW50Lmdvdi51ayIsInN1YiI6IjljNWFhYzU2LTE0YzAtNDJkNi05MzFkLWI0NmNkM2QzNWFlMSIsImlhdCI6MTcxNTI2NTkwMywiZXhwIjoxNzE2NDc1NTAzLCJlbWFpbCI6ImFiY0BleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJ1ay5nb3YuYWNjb3VudC50b2tlbi93YWxsZXRTdG9yZUlkIjoiZ2piNlZmWmEwcTRoN3BNTGRuRG5XYlJiUWVIR2lyaVBuLWlJOEpiQURWWSJ9
"""
}
// swiftlint:enable line_length
