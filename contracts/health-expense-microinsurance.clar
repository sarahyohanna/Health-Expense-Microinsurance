
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-insufficient-funds (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-claim-not-found (err u104))
(define-constant err-claim-already-processed (err u105))
(define-constant err-invalid-claim (err u106))
(define-constant err-member-exists (err u107))
(define-constant err-claim-expired (err u108))

(define-data-var total-pool-balance uint u0)
(define-data-var claim-counter uint u0)
(define-data-var member-counter uint u0)
(define-data-var minimum-contribution uint u1000000)
(define-data-var maximum-claim-amount uint u50000000)
(define-data-var claim-period-blocks uint u4320)

(define-map members 
    principal 
    {
        contribution: uint,
        join-block: uint,
        active: bool
    })

(define-map claims 
    uint 
    {
        claimant: principal,
        amount: uint,
        description: (string-ascii 256),
        status: (string-ascii 20),
        submit-block: uint,
        process-block: uint
    })

(define-map member-claims principal (list 50 uint))

(define-read-only (get-pool-balance)
    (var-get total-pool-balance))

(define-read-only (get-member-info (member principal))
    (map-get? members member))

(define-read-only (is-member (user principal))
    (match (map-get? members user)
        member-info (get active member-info)
        false))

(define-read-only (get-claim-info (claim-id uint))
    (map-get? claims claim-id))

(define-read-only (get-member-claims (member principal))
    (default-to (list) (map-get? member-claims member)))

(define-read-only (get-contract-settings)
    {
        minimum-contribution: (var-get minimum-contribution),
        maximum-claim-amount: (var-get maximum-claim-amount),
        claim-period-blocks: (var-get claim-period-blocks),
        total-members: (var-get member-counter),
        claim-counter: (var-get claim-counter)
    })

(define-public (join-pool (contribution-amount uint))
    (let 
        (
            (existing-member (map-get? members tx-sender))
        )
        (asserts! (>= contribution-amount (var-get minimum-contribution)) err-invalid-amount)
        (asserts! (is-none existing-member) err-member-exists)
        (try! (stx-transfer? contribution-amount tx-sender (as-contract tx-sender)))
        (map-set members tx-sender {
            contribution: contribution-amount,
            join-block: stacks-block-height,
            active: true
        })
        (var-set total-pool-balance (+ (var-get total-pool-balance) contribution-amount))
        (var-set member-counter (+ (var-get member-counter) u1))
        (ok true)))

(define-public (contribute-to-pool (amount uint))
    (let 
        (
            (member-info (unwrap! (map-get? members tx-sender) err-not-member))
        )
        (asserts! (get active member-info) err-not-member)
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set members tx-sender (merge member-info {
            contribution: (+ (get contribution member-info) amount)
        }))
        (var-set total-pool-balance (+ (var-get total-pool-balance) amount))
        (ok true)))

(define-public (submit-claim (amount uint) (description (string-ascii 256)))
    (let 
        (
            (member-info (unwrap! (map-get? members tx-sender) err-not-member))
            (new-claim-id (+ (var-get claim-counter) u1))
            (member-claim-list (default-to (list) (map-get? member-claims tx-sender)))
        )
        (asserts! (get active member-info) err-not-member)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (<= amount (var-get maximum-claim-amount)) err-invalid-amount)
        (asserts! (<= amount (var-get total-pool-balance)) err-insufficient-funds)
        (map-set claims new-claim-id {
            claimant: tx-sender,
            amount: amount,
            description: description,
            status: "pending",
            submit-block: stacks-block-height,
            process-block: u0
        })
        (map-set member-claims tx-sender (unwrap! (as-max-len? (append member-claim-list new-claim-id) u50) err-invalid-claim))
        (var-set claim-counter new-claim-id)
        (ok new-claim-id)))

(define-public (approve-claim (claim-id uint))
    (let 
        (
            (claim-info (unwrap! (map-get? claims claim-id) err-claim-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-eq (get status claim-info) "pending") err-claim-already-processed)
        (asserts! (<= (get amount claim-info) (var-get total-pool-balance)) err-insufficient-funds)
        (asserts! (< (- stacks-block-height (get submit-block claim-info)) (var-get claim-period-blocks)) err-claim-expired)
        (try! (as-contract (stx-transfer? (get amount claim-info) tx-sender (get claimant claim-info))))
        (map-set claims claim-id (merge claim-info {
            status: "approved",
            process-block: stacks-block-height
        }))
        (var-set total-pool-balance (- (var-get total-pool-balance) (get amount claim-info)))
        (ok true)))

(define-public (reject-claim (claim-id uint))
    (let 
        (
            (claim-info (unwrap! (map-get? claims claim-id) err-claim-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-eq (get status claim-info) "pending") err-claim-already-processed)
        (map-set claims claim-id (merge claim-info {
            status: "rejected",
            process-block: stacks-block-height
        }))
        (ok true)))

(define-public (deactivate-member (member principal))
    (let 
        (
            (member-info (unwrap! (map-get? members member) err-not-member))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set members member (merge member-info {
            active: false
        }))
        (ok true)))

(define-public (update-minimum-contribution (new-minimum uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set minimum-contribution new-minimum)
        (ok true)))

(define-public (update-maximum-claim (new-maximum uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set maximum-claim-amount new-maximum)
        (ok true)))

(define-public (update-claim-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set claim-period-blocks new-period)
        (ok true)))

(define-read-only (get-pending-claims-count)
    (var-get claim-counter))

(define-private (is-pending-claim (claim-id uint))
    (match (map-get? claims claim-id)
        claim-info (is-eq (get status claim-info) "pending")
        false))

(define-read-only (calculate-member-coverage (member principal))
    (let 
        (
            (member-info (unwrap! (map-get? members member) (ok u0)))
        )
        (if (> (var-get total-pool-balance) u0)
            (ok (/ (* (get contribution member-info) (var-get total-pool-balance)) (var-get total-pool-balance)))
            (ok u0))))

(define-read-only (get-claim-statistics)
    {
        total-claims: (var-get claim-counter),
        total-members: (var-get member-counter),
        pool-balance: (var-get total-pool-balance)
    })

(define-read-only (is-claim-approved (claim-id uint))
    (match (map-get? claims claim-id)
        claim-info (is-eq (get status claim-info) "approved")
        false))

(define-read-only (is-claim-rejected (claim-id uint))
    (match (map-get? claims claim-id)
        claim-info (is-eq (get status claim-info) "rejected")
        false))

(define-public (emergency-withdraw)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender contract-owner)))
        (var-set total-pool-balance u0)
        (ok true)))

