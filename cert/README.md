Please replace domain name in hosts section in pmp-csr.json and use `cfssl` or `openssl` to generate new certificate.

# Generate CA certificate and key
cfssl gencert -initca pmp-csr.json
# Sign pmp certificate request with generated CA cert and key
cfssl sign -ca-key=key.pem -ca=cert.pem csr.pem
