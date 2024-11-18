struct AppAttestJWTHeader {
    let alg: String
    
    init(alg: String) {
        self.alg = alg
    }
    
    var value: [String: String] {
        ["alg": alg]
    }
}
