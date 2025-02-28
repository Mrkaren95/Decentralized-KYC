;; Decentralized KYC Platform Smart Contract
;; This contract implements a decentralized KYC system where:
;; 1. Authorized verifiers can validate user identities
;; 2. Users can submit their information for verification
;; 3. Third parties can check if a user is verified
;; 4. Users maintain control over their identity data

(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-not-authorized (err u100))
(define-constant err-already-verifier (err u101))
(define-constant err-not-verifier (err u102))
(define-constant err-user-already-verified (err u103))
(define-constant err-user-not-verified (err u104))
(define-constant err-invalid-verification-level (err u105))
(define-constant err-not-owner (err u106))
(define-constant err-invalid-data-hash (err u107))

;; Data structures
(define-map verifiers principal bool)
(define-map user-verification 
  { user: principal } 
  { 
    verified: bool, 
    verification-level: uint, 
    verification-date: uint, 
    data-hash: (buff 32),
    verifier: principal 
  }
)

;; Verification levels
;; 1 = Basic verification
;; 2 = Advanced verification
;; 3 = Premium verification

;; Read-only functions

;; Check if an address is an authorized verifier
(define-read-only (is-verifier (address principal))
  (default-to false (get-verifier address))
)

;; Get verifier status
(define-read-only (get-verifier (address principal))
  (map-get? verifiers address)
)

;; Check if a user is verified
(define-read-only (is-user-verified (user principal))
  (default-to false (get verified (get-user-verification user)))
)

;; Get user verification details
(define-read-only (get-user-verification (user principal))
  (map-get? user-verification { user: user })
)

;; Get user verification level
(define-read-only (get-user-verification-level (user principal))
  (default-to u0 (get verification-level (get-user-verification user)))
)

;; Helper function to validate verification level
(define-private (is-valid-verification-level (level uint))
  (or (is-eq level u1) (is-eq level u2) (is-eq level u3))
)

;; Helper function to validate data hash (non-zero)
(define-private (is-valid-data-hash (hash (buff 32)))
  (not (is-eq hash 0x0000000000000000000000000000000000000000000000000000000000000000))
)

;; Public functions

;; Add a new verifier (only contract owner can do this)
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (not (is-verifier verifier)) err-already-verifier)
    (ok (map-set verifiers verifier true))
  )
)

;; Remove a verifier (only contract owner can do this)
(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (is-verifier verifier) err-not-verifier)
    (ok (map-set verifiers verifier false))
  )
)

;; Verify a user (only authorized verifiers can do this)
(define-public (verify-user (user principal) (verification-level uint) (data-hash (buff 32)))
  (begin
    (asserts! (is-verifier tx-sender) err-not-authorized)
    (asserts! (is-valid-verification-level verification-level) err-invalid-verification-level)
    (asserts! (is-valid-data-hash data-hash) err-invalid-data-hash)
    
    ;; Use a variable to store the sanitized user data structure
    (let ((user-entry { user: user })
          (verification-data { 
            verified: true, 
            verification-level: verification-level, 
            verification-date: block-height, 
            data-hash: data-hash,
            verifier: tx-sender 
          }))
      (ok (map-set user-verification user-entry verification-data))
    )
  )
)

;; Revoke verification for a user (can be done by the verifier who verified the user or contract owner)
(define-public (revoke-verification (user principal))
  (let ((current-verification (unwrap! (get-user-verification user) err-user-not-verified))
        (user-entry { user: user })
        (revoked-data { 
          verified: false, 
          verification-level: u0, 
          verification-date: block-height, 
          data-hash: 0x0000000000000000000000000000000000000000000000000000000000000000,
          verifier: tx-sender 
        }))
    (begin
      (asserts! (or 
                 (is-eq tx-sender (get verifier current-verification))
                 (is-eq tx-sender contract-owner)) 
                err-not-authorized)
      (ok (map-set user-verification user-entry revoked-data))
    )
  )
)

;; Users can remove their own verification (self-revocation)
(define-public (self-revoke-verification)
  (let ((user tx-sender)
        (user-entry { user: tx-sender })
        (revoked-data { 
          verified: false, 
          verification-level: u0, 
          verification-date: block-height, 
          data-hash: 0x0000000000000000000000000000000000000000000000000000000000000000,
          verifier: tx-sender 
        }))
    (begin
      (asserts! (is-user-verified user) err-user-not-verified)
      (ok (map-set user-verification user-entry revoked-data))
    )
  )
)

;; Update verification level (only authorized verifiers can do this)
(define-public (update-verification-level (user principal) (new-verification-level uint))
  (let ((current-verification (unwrap! (get-user-verification user) err-user-not-verified))
        (user-entry { user: user }))
    (begin
      (asserts! (is-verifier tx-sender) err-not-authorized)
      (asserts! (is-valid-verification-level new-verification-level) err-invalid-verification-level)
      
      ;; Create an updated verification record with the new level
      (let ((updated-verification (merge current-verification { verification-level: new-verification-level })))
        (ok (map-set user-verification user-entry updated-verification))
      )
    )
  )
)