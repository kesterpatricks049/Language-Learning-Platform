;; Payment Handler

(use-trait ft-trait .language-learning-token.llt)

;; Define data variables
(define-map payments uint
  { amount: uint,
    status: (string-ascii 20) })

;; Define constants
(define-constant err-payment-not-found (err u400))
(define-constant err-unauthorized (err u401))
(define-constant contract-owner tx-sender)

;; Define public functions
(define-public (create-payment (session-id uint) (amount uint) (token <ft-trait>))
  (let ((learner (get learner (unwrap! (contract-call? .session-management get-session session-id) err-payment-not-found))))
    (asserts! (is-eq tx-sender learner) err-unauthorized)
    (try! (contract-call? token transfer amount tx-sender (as-contract tx-sender)))
    (map-set payments session-id
      { amount: amount,
        status: "held" })
    (ok true)))

(define-public (release-payment (session-id uint) (token <ft-trait>))
  (let ((session (unwrap! (contract-call? .session-management get-session session-id) err-payment-not-found))
        (payment (unwrap! (map-get? payments session-id) err-payment-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (try! (as-contract (contract-call? token transfer (get amount payment) tx-sender (get tutor session))))
    (map-set payments session-id
      (merge payment { status: "released" }))
    (ok true)))

;; Read-only functions
(define-read-only (get-payment (session-id uint))
  (map-get? payments session-id))

