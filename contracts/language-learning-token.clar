;; Language Learning Token (LLT)

;; Define the token
(define-fungible-token llt)

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))

;; Define public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-owner-only)
    (try! (ft-transfer? llt amount sender recipient))
    (ok true)))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? llt amount recipient)))

;; Read-only functions
(define-read-only (get-balance (account principal))
  (ft-get-balance llt account))

(define-read-only (get-total-supply)
  (ft-get-supply llt))

;; Initialize the token with a total supply of 1,000,000 LLT
(ft-mint? llt u1000000 contract-owner)

