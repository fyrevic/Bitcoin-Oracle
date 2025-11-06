;; Bitcoin Block Header Anchoring
;; Oracle nodes submit raw Bitcoin block headers for quorum-based verification

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-ALREADY-SUBMITTED (err u301))
(define-constant ERR-HEADER-NOT-FOUND (err u302))
(define-constant ERR-INVALID-HEADER (err u303))
(define-constant ERR-NODE-NOT-REGISTERED (err u304))
(define-constant ERR-LIST-OVERFLOW (err u305))

;; Contract configuration
(define-data-var quorum-threshold uint u3)

;; Block header storage
(define-map block-headers
    uint
    {
        header-hash: (buff 32),
        raw-header: (buff 80),
        submission-count: uint,
        submitters: (list 20 principal),
        approved: bool,
        first-seen: uint
    }
)

;; Track individual node submissions
(define-map node-submissions
    {btc-height: uint, node: principal}
    {
        header-hash: (buff 32),
        submitted-at: uint
    }
)

;; Oracle node registry (reusing from signed-data-feeds contract)
(define-map registered-nodes
    principal
    {
        active: bool,
        total-headers-submitted: uint
    }
)

;; Read-only functions

(define-read-only (get-header (btc-height uint))
    (map-get? block-headers btc-height)
)

(define-read-only (is-header-approved (btc-height uint))
    (match (map-get? block-headers btc-height)
        header (ok (get approved header))
        ERR-HEADER-NOT-FOUND
    )
)

(define-read-only (get-submission-count (btc-height uint))
    (match (map-get? block-headers btc-height)
        header (ok (get submission-count header))
        (ok u0)
    )
)

(define-read-only (did-node-submit (btc-height uint) (node principal))
    (is-some (map-get? node-submissions {btc-height: btc-height, node: node}))
)

(define-read-only (get-node-submission (btc-height uint) (node principal))
    (map-get? node-submissions {btc-height: btc-height, node: node})
)

(define-read-only (verify-header-quorum (btc-height uint))
    (match (map-get? block-headers btc-height)
        header (ok {
            header-hash: (get header-hash header),
            approved: (get approved header),
            submissions: (get submission-count header),
            required: (var-get quorum-threshold),
            submitters: (get submitters header)
        })
        ERR-HEADER-NOT-FOUND
    )
)

(define-read-only (get-quorum-threshold)
    (ok (var-get quorum-threshold))
)

(define-read-only (is-node-registered (node principal))
    (match (map-get? registered-nodes node)
        node-info (get active node-info)
        false
    )
)

;; Public functions

(define-public (register-node (node principal))
    (begin
        (map-set registered-nodes node {
            active: true,
            total-headers-submitted: u0
        })
        (ok true)
    )
)

(define-public (submit-header (btc-height uint) (header-hash (buff 32)) (raw-header (buff 80)))
    (let
        (
            (existing-header (map-get? block-headers btc-height))
            (node-already-submitted (map-get? node-submissions {btc-height: btc-height, node: tx-sender}))
            (node-info (map-get? registered-nodes tx-sender))
        )
        (asserts! (is-some node-info) ERR-NODE-NOT-REGISTERED)
        (asserts! (get active (unwrap! node-info ERR-NODE-NOT-REGISTERED)) ERR-NODE-NOT-REGISTERED)
        (asserts! (is-none node-already-submitted) ERR-ALREADY-SUBMITTED)
        
        ;; Record this node's submission
        (map-set node-submissions {btc-height: btc-height, node: tx-sender} {
            header-hash: header-hash,
            submitted-at: stacks-block-height
        })
        
        ;; Update node stats
        (map-set registered-nodes tx-sender
            (merge (unwrap-panic node-info) {
                total-headers-submitted: (+ (get total-headers-submitted (unwrap-panic node-info)) u1)
            })
        )
        
        ;; Update or create header entry
        (match existing-header
            header
                (if (is-eq (get header-hash header) header-hash)
                    (let
                        (
                            (current-submitters (get submitters header))
                            (new-submitters (unwrap! (as-max-len? (append current-submitters tx-sender) u20) ERR-LIST-OVERFLOW))
                            (new-count (+ (get submission-count header) u1))
                            (is-approved (>= new-count (var-get quorum-threshold)))
                        )
                        (map-set block-headers btc-height
                            (merge header {
                                submission-count: new-count,
                                submitters: new-submitters,
                                approved: is-approved
                            })
                        )
                        (ok {approved: is-approved, count: new-count})
                    )
                    (ok {approved: false, count: u0})
                )
            (begin
                (map-set block-headers btc-height {
                    header-hash: header-hash,
                    raw-header: raw-header,
                    submission-count: u1,
                    submitters: (list tx-sender),
                    approved: (>= u1 (var-get quorum-threshold)),
                    first-seen: stacks-block-height
                })
                (ok {approved: (>= u1 (var-get quorum-threshold)), count: u1})
            )
        )
    )
)

(define-public (update-quorum (new-threshold uint))
    (begin
        (asserts! (> new-threshold u0) ERR-INVALID-HEADER)
        (var-set quorum-threshold new-threshold)
        (ok true)
    )
)