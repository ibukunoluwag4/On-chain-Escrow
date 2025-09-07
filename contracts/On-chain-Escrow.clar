;; P2P Freelancing Escrow Contract
;; Simple escrow system for milestone-based payments

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ESCROW-NOT-FOUND (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-MILESTONE-NOT-SUBMITTED (err u103))
(define-constant ERR-ALREADY-RELEASED (err u104))
(define-constant ERR-INSUFFICIENT-FUNDS (err u105))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Escrow counter for unique IDs
(define-data-var escrow-counter uint u0)

;; Escrow data structure
(define-map escrows uint {
  client: principal,
  freelancer: principal,
  amount: uint,
  milestone-description: (string-ascii 500),
  milestone-submitted: bool,
  milestone-data: (string-ascii 1000),
  released: bool,
  created-at: uint
})

;; Get escrow details
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows escrow-id)
)

;; Get current escrow counter
(define-read-only (get-escrow-counter)
  (var-get escrow-counter)
)

;; Create new escrow
(define-public (create-escrow (freelancer principal) (amount uint) (milestone-description (string-ascii 500)))
  (let (
    (escrow-id (+ (var-get escrow-counter) u1))
  )
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    (map-set escrows escrow-id {
      client: tx-sender,
      freelancer: freelancer,
      amount: amount,
      milestone-description: milestone-description,
      milestone-submitted: false,
      milestone-data: "",
      released: false,
      created-at: block-height
    })

    (var-set escrow-counter escrow-id)
    (ok escrow-id)
  )
)

;; Submit milestone (freelancer only)
(define-public (submit-milestone (escrow-id uint) (milestone-data (string-ascii 1000)))
  (let (
    (escrow (unwrap! (map-get? escrows escrow-id) ERR-ESCROW-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get freelancer escrow)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get released escrow)) ERR-ALREADY-RELEASED)

    (map-set escrows escrow-id 
      (merge escrow {
        milestone-submitted: true,
        milestone-data: milestone-data
      })
    )
    (ok true)
  )
)

;; Verify milestone and release payment (client only)
(define-public (verify-and-release (escrow-id uint))
  (let (
    (escrow (unwrap! (map-get? escrows escrow-id) ERR-ESCROW-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get client escrow)) ERR-NOT-AUTHORIZED)
    (asserts! (get milestone-submitted escrow) ERR-MILESTONE-NOT-SUBMITTED)
    (asserts! (not (get released escrow)) ERR-ALREADY-RELEASED)

    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get freelancer escrow))))

    (map-set escrows escrow-id 
      (merge escrow { released: true })
    )
    (ok true)
  )
)

;; Emergency release by contract owner (dispute resolution)
(define-public (emergency-release (escrow-id uint) (release-to principal))
  (let (
    (escrow (unwrap! (map-get? escrows escrow-id) ERR-ESCROW-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (get released escrow)) ERR-ALREADY-RELEASED)

    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender release-to)))

    (map-set escrows escrow-id 
      (merge escrow { released: true })
    )
    (ok true)
  )
)