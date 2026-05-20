# Absolute Zero-Trust Security Standard
1. Never hardcode credentials, webhook URLs, tokens, or private keys into source files or documentation.
2. All user inputs, configuration flags, and network payloads must be strictly validated before processing.
3. Ensure file system access is restricted within the authorized workspace boundaries (Deny-by-default).
4. Implement rate limiting and throttling on all public-facing endpoints to prevent abuse and DoS.
5. Never log PII (personally identifiable information), passwords, tokens, or session identifiers — use masking or hashing.
6. Run dependency vulnerability scans (e.g., `cargo audit`, `npm audit`, `trivy`) in CI/CD before every release.
7. Enforce secure defaults: TLS everywhere, HTTPS-only redirects, secure and HttpOnly cookie flags, HSTS headers.
8. Sanitize all inputs against OWASP Top 10: XSS, SQL injection, path traversal, SSRF, and command injection.
9. Apply the principle of least privilege: services, tokens, and users receive only the minimum permissions required.
10. Rotate secrets on a defined schedule and use short-lived tokens (JWT with tight expiry, OAuth refresh flows).
11. Validate and verify all external data: schema-check API responses, verify TLS certificates, pin dependency checksums.
12. Implement defense-in-depth: multiple security layers so a single bypass does not compromise the entire system.
