;; Bitcoin Oracle - Signed Data Feeds (MVP)
;; Registered oracle nodes submit Bitcoin data with signatures

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NODE-NOT-REGISTERED (err u101))
(define-constant ERR-INVALID-BLOCK-HEIGHT (err u102))
(define-constant ERR-STALE-DATA (err u103))
(define-constant ERR-NODE-ALREADY-EXISTS (err u104))
(define-constant ERR-NODE-NOT-FOUND (err u105))

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Oracle node registry
(define-map oracle-nodes 
    principal 
    {
        registered-at: uint,
        is-active: bool,
        total-submissions: uint,
        last-submission: uint
    }
)

;; Bitcoin data storage - keyed by submitter and bitcoin block height
(define-map bitcoin-data
    { submitter: principal, btc-block-height: uint }
    {
        block-hash: (string-ascii 64),
        transaction-count: uint,
        difficulty: uint,
        timestamp: uint,
        stacks-block-height: uint
    }
)

;; Latest data per oracle node
(define-map latest-oracle-data
    principal
    {
        btc-block-height: uint,
        block-hash: (string-ascii 64),
        transaction-count: uint,
        difficulty: uint,
        timestamp: uint,
        stacks-block-height: uint
    }
)

;; Read-only functions

;; Get oracle node info
(define-read-only (get-oracle-node (node principal))
    (map-get? oracle-nodes node)
)

;; Check if node is registered and active
(define-read-only (is-registered-node (node principal))
    (match (map-get? oracle-nodes node)
        node-info (get is-active node-info)
        false
    )
)

;; Get bitcoin data by submitter and block height
(define-read-only (get-bitcoin-data (submitter principal) (btc-block-height uint))
    (map-get? bitcoin-data { submitter: submitter, btc-block-height: btc-block-height })
)

;; Get latest data from a specific oracle
(define-read-only (get-latest-oracle-data (oracle principal))
    (map-get? latest-oracle-data oracle)
)

;; Get contract owner
(define-read-only (get-contract-owner)
    (var-get contract-owner)
)

;; Get node statistics
(define-read-only (get-node-stats (node principal))
    (match (map-get? oracle-nodes node)
        node-info (some {
            registered-at: (get registered-at node-info),
            is-active: (get is-active node-info),
            total-submissions: (get total-submissions node-info),
            last-submission: (get last-submission node-info),
            blocks-since-registration: (- stacks-block-height (get registered-at node-info))
        })
        none
    )
)

;; Public functions

;; Register a new oracle node (only contract owner)
(define-public (register-oracle-node (node principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (asserts! (is-none (map-get? oracle-nodes node)) ERR-NODE-ALREADY-EXISTS)
        (map-set oracle-nodes node {
            registered-at: stacks-block-height,
            is-active: true,
            total-submissions: u0,
            last-submission: u0
        })
        (ok node)
    )
)

;; Deactivate an oracle node (only contract owner)
(define-public (deactivate-oracle-node (node principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (match (map-get? oracle-nodes node)
            node-info 
            (begin
                (map-set oracle-nodes node (merge node-info { is-active: false }))
                (ok node)
            )
            ERR-NODE-NOT-FOUND
        )
    )
)

;; Reactivate an oracle node (only contract owner)
(define-public (reactivate-oracle-node (node principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (match (map-get? oracle-nodes node)
            node-info 
            (begin
                (map-set oracle-nodes node (merge node-info { is-active: true }))
                (ok node)
            )
            ERR-NODE-NOT-FOUND
        )
    )
)

;; Submit Bitcoin data (only registered and active oracle nodes)
(define-public (submit-bitcoin-data 
    (btc-block-height uint)
    (block-hash (string-ascii 64))
    (transaction-count uint)
    (difficulty uint)
)
    (let (
        (submitter tx-sender)
        (current-stacks-height stacks-block-height)
    )
        ;; Verify node is registered and active
        (asserts! (is-registered-node submitter) ERR-NODE-NOT-REGISTERED)
        
        ;; Verify block height is valid
        (asserts! (> btc-block-height u0) ERR-INVALID-BLOCK-HEIGHT)
        
        ;; Check for stale data - only allow if this is newer than last submission
        (match (map-get? latest-oracle-data submitter)
            latest-data 
            (asserts! (> btc-block-height (get btc-block-height latest-data)) ERR-STALE-DATA)
            true ;; No previous data, so this is valid
        )
        
        ;; Store the bitcoin data
        (map-set bitcoin-data 
            { submitter: submitter, btc-block-height: btc-block-height }
            {
                block-hash: block-hash,
                transaction-count: transaction-count,
                difficulty: difficulty,
                timestamp: current-stacks-height,
                stacks-block-height: current-stacks-height
            }
        )
        
        ;; Update latest data for this oracle
        (map-set latest-oracle-data submitter {
            btc-block-height: btc-block-height,
            block-hash: block-hash,
            transaction-count: transaction-count,
            difficulty: difficulty,
            timestamp: current-stacks-height,
            stacks-block-height: current-stacks-height
        })
        
        ;; Update node statistics
        (match (map-get? oracle-nodes submitter)
            node-info 
            (map-set oracle-nodes submitter 
                (merge node-info {
                    total-submissions: (+ (get total-submissions node-info) u1),
                    last-submission: current-stacks-height
                })
            )
            false ;; This shouldn't happen due to earlier check
        )
        
        (ok {
            submitter: submitter,
            btc-block-height: btc-block-height,
            block-hash: block-hash,
            transaction-count: transaction-count,
            difficulty: difficulty,
            timestamp: current-stacks-height
        })
    )
)

;; Transfer contract ownership (only current owner)
(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (var-set contract-owner new-owner)
        (ok new-owner)
    )
)

;; Get multiple oracle's latest data
(define-read-only (get-multiple-oracle-data (oracles (list 10 principal)))
    (map get-latest-oracle-data oracles)
)

;; Get all submissions from a specific oracle within a block height range
(define-read-only (get-oracle-submissions-in-range (oracle principal) (start-height uint) (end-height uint))
    (let (
        (submissions (list))
    )
        ;; This is a simplified version - in practice you'd need to iterate through heights
        ;; For now, just return the latest if it's in range
        (match (map-get? latest-oracle-data oracle)
            latest-data 
            (if (and (>= (get btc-block-height latest-data) start-height)
                     (<= (get btc-block-height latest-data) end-height))
                (some latest-data)
                none
            )
            none
        )
    )
)