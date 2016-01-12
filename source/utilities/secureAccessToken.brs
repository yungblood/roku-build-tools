Function GenerateAccessToken(secret As String) As String
    key = "302a6a0d70a7e9b967f91d39fef3e387816e3095925ae4537bce96063311f9c5"
    
    ' Generate a random IV
    ivLength = 16
    iv = GetRandomHexString(ivLength * 2)
    
    ' Generate the unique token
    nonce = NowDate().AsSeconds().ToStr()
    token = nonce + "|" + secret
    
    ' Encrypt the token
    cipherText = HexEncrypt("AES-256-CBC", key, iv, token)
    
    ' Build the access token string
    ' IV Length + IV + Encrypted Token
    output = IntToHex(ivLength) + iv + cipherText

    ' Base64 encode the access token
    Return HexToBase64(output)
End Function
