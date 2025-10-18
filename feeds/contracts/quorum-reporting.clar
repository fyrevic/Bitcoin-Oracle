;; Bitcoin Oracle Aggregation Module
;; Quorum-based consensus for multi-node Bitcoin data feeds

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u200))
(define-constant ERR-INVALID-QUORUM (err u201))
(define-constant ERR-INSUFFICIENT-SUBMISSIONS (err u202))
(define-constant ERR-FEED-NOT-FOUND (err u203))
(define-constant ERR-DUPLICATE-SUBMISSION (err u207))
(define-constant ERR-LIST-OVERFLOW (err u208))

;; Contract configuration
(define-data-var contract-owner principal tx-sender)
(define-data-var quorum-threshold uint u2)

;; Aggregated feed data
(define-map aggregated-feeds
    uint
    {
        block-hash: (string-ascii 64),
        transaction-count: uint,
        difficulty: uint,
        submitter-count: uint,
        submitters: (list 20 principal),
        consensus-achieved: bool,
        last-updated: uint
    }
)

;; Track submissions to prevent duplicates
(define-map feed-submissions
    { feed-id: uint, submitter: principal }
    bool
)

;; Read-only functions

(define-read-only (get-quorum-threshold)
    (var-get quorum-threshold)
)

(define-read-only (get-aggregated-feed (btc-block-height uint))
    (map-get? aggregated-feeds btc-block-height)
)

(define-read-only (is-consensus-achieved (btc-block-height uint))
    (match (map-get? aggregated-feeds btc-block-height)
        feed-data (get consensus-achieved feed-data)
        false
    )
)

(define-read-only (get-consensus-feed (btc-block-height uint))
    (match (map-get? aggregated-feeds btc-block-height)
        feed-data 
        (if (get consensus-achieved feed-data)
            (ok feed-data)
            ERR-INSUFFICIENT-SUBMISSIONS
        )
        ERR-FEED-NOT-FOUND
    )
)

(define-read-only (get-feed-submitters (btc-block-height uint))
    (match (map-get? aggregated-feeds btc-block-height)
        feed-data (ok (get submitters feed-data))
        ERR-FEED-NOT-FOUND
    )
)

(define-read-only (has-submitted (btc-block-height uint) (submitter principal))
    (is-some (map-get? feed-submissions { feed-id: btc-block-height, submitter: submitter }))
)

;; Public functions

(define-public (submit-data 
    (btc-block-height uint)
    (block-hash (string-ascii 64))
    (transaction-count uint)
    (difficulty uint)
    (submitter principal)
)
    (let (
        (threshold (var-get quorum-threshold))
        (existing (map-get? aggregated-feeds btc-block-height))
        (already-submitted (has-submitted btc-block-height submitter))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (asserts! (not already-submitted) ERR-DUPLICATE-SUBMISSION)
        
        (if (is-some existing)
            (let (
                (feed (unwrap! existing ERR-FEED-NOT-FOUND))
                (current-submitters (get submitters feed))
                (current-count (get submitter-count feed))
                (new-count (+ current-count u1))
                (new-submitters (unwrap! (as-max-len? (append current-submitters submitter) u20) ERR-LIST-OVERFLOW))
                (consensus (>= new-count threshold))
            )
                (map-set aggregated-feeds btc-block-height {
                    block-hash: block-hash,
                    transaction-count: transaction-count,
                    difficulty: difficulty,
                    submitter-count: new-count,
                    submitters: new-submitters,
                    consensus-achieved: consensus,
                    last-updated: stacks-block-height
                })
                (map-set feed-submissions { feed-id: btc-block-height, submitter: submitter } true)
                (ok { submitter-count: new-count, consensus-achieved: consensus })
            )
            (begin
                (map-set aggregated-feeds btc-block-height {
                    block-hash: block-hash,
                    transaction-count: transaction-count,
                    difficulty: difficulty,
                    submitter-count: u1,
                    submitters: (list submitter),
                    consensus-achieved: (>= u1 threshold),
                    last-updated: stacks-block-height
                })
                (map-set feed-submissions { feed-id: btc-block-height, submitter: submitter } true)
                (ok { submitter-count: u1, consensus-achieved: (>= u1 threshold) })
            )
        )
    )
)

(define-public (set-quorum-threshold (threshold uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (asserts! (> threshold u0) ERR-INVALID-QUORUM)
        (var-set quorum-threshold threshold)
        (ok threshold)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (var-set contract-owner new-owner)
        (ok new-owner)
    )
)