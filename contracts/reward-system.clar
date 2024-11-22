;; Reward System

(use-trait ft-trait .language-learning-token.llt)

;; Define constants
(define-constant err-unauthorized (err u500))
(define-constant contract-owner tx-sender)

;; Define reward amounts
(define-constant learner-completion-reward u10)
(define-constant tutor-completion-reward u15)
(define-constant high-rating-bonus u5)

;; Define public functions
(define-public (distribute-rewards (session-id uint) (learner-rating uint) (tutor-rating uint) (token <ft-trait>))
  (let ((session (unwrap! (contract-call? .session-management get-session session-id) err-unauthorized))
        (learner (get learner session))
        (tutor (get tutor session)))

    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)

    ;; Distribute rewards to learner
    (try! (as-contract (contract-call? token mint learner-completion-reward learner)))
    (if (>= learner-rating u4)
      (try! (as-contract (contract-call? token mint high-rating-bonus learner)))
      true)

    ;; Distribute rewards to tutor
    (try! (as-contract (contract-call? token mint tutor-completion-reward tutor)))
    (if (>= tutor-rating u4)
      (try! (as-contract (contract-call? token mint high-rating-bonus tutor)))
      true)

    ;; Update user reputations
    (try! (contract-call? .user-registry update-reputation learner learner-rating))
    (try! (contract-call? .user-registry update-reputation tutor tutor-rating))

    (ok true)))

