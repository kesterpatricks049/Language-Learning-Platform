;; Session Management

;; Define data variables
(define-map sessions uint
  { learner: principal,
    tutor: principal,
    language: (string-ascii 20),
    start-time: uint,
    duration: uint,
    status: (string-ascii 20) })

(define-data-var next-session-id uint u0)

;; Define constants
(define-constant err-invalid-participants (err u300))
(define-constant err-session-not-found (err u301))
(define-constant err-unauthorized (err u302))

;; Define public functions
(define-public (create-session (tutor principal) (language (string-ascii 20)) (start-time uint) (duration uint))
  (let ((session-id (var-get next-session-id)))
    (asserts! (not (is-eq tx-sender tutor)) err-invalid-participants)
    (map-set sessions session-id
      { learner: tx-sender,
        tutor: tutor,
        language: language,
        start-time: start-time,
        duration: duration,
        status: "scheduled" })
    (var-set next-session-id (+ session-id u1))
    (ok session-id)))

(define-public (update-session-status (session-id uint) (new-status (string-ascii 20)))
  (let ((session (unwrap! (map-get? sessions session-id) err-session-not-found)))
    (asserts! (or (is-eq tx-sender (get learner session)) (is-eq tx-sender (get tutor session))) err-unauthorized)
    (map-set sessions session-id
      (merge session { status: new-status }))
    (ok true)))

;; Read-only functions
(define-read-only (get-session (session-id uint))
  (map-get? sessions session-id))

