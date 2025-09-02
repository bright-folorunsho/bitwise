;; Title: BitWise - Next-Generation Bitcoin Prediction Markets
;;
;; Summary: Revolutionary decentralized prediction platform empowering users to
;;          monetize Bitcoin market insights through sophisticated prediction mechanics
;;
;; Description: BitWise transforms cryptocurrency forecasting into a profitable,
;;              transparent prediction ecosystem on the Stacks blockchain. Our platform
;;              enables traders to stake STX tokens on Bitcoin price movements,
;;              earning proportional rewards based on prediction accuracy and market
;;              participation. Featuring real-time oracle integration, automated
;;              settlement mechanisms, dynamic fee structures, and institutional-grade
;;              security protocols. BitWise democratizes access to prediction markets
;;              while maintaining the highest standards of decentralization and fairness
;;              for both individual traders and enterprise participants.

;; SYSTEM CONSTANTS & CONFIGURATION

;; Contract Administration
(define-constant CONTRACT_OWNER tx-sender)

;; Comprehensive Error Handling System
(define-constant ERR_UNAUTHORIZED (err u100)) ;; Access denied
(define-constant ERR_RESOURCE_NOT_FOUND (err u101)) ;; Resource unavailable
(define-constant ERR_INVALID_PREDICTION (err u102)) ;; Prediction format error
(define-constant ERR_MARKET_INACTIVE (err u103)) ;; Market closed/expired
(define-constant ERR_REWARDS_CLAIMED (err u104)) ;; Already distributed
(define-constant ERR_INSUFFICIENT_FUNDS (err u105)) ;; Balance too low
(define-constant ERR_INVALID_PARAMS (err u106)) ;; Parameter validation failed

;; PLATFORM VARIABLES & STATE MANAGEMENT

;; Oracle Configuration for Price Feeds
(define-data-var oracle-principal principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Economic Model Parameters
(define-data-var minimum-stake-amount uint u1000000) ;; 1 STX minimum stake
(define-data-var platform-fee-rate uint u2) ;; 2% protocol fee
(define-data-var global-market-id uint u0) ;; Market ID counter

;; DATA STRUCTURES & STORAGE MAPS

;; Primary Market Registry
;; Comprehensive market lifecycle tracking
(define-map prediction-markets
  uint ;; Market identifier
  {
    initial-btc-price: uint, ;; Market opening Bitcoin price
    final-btc-price: uint, ;; Oracle-settled closing price  
    bullish-stake-total: uint, ;; Total STX staked on price increase
    bearish-stake-total: uint, ;; Total STX staked on price decrease
    market-start-height: uint, ;; Blockchain height at market open
    market-end-height: uint, ;; Blockchain height at market close
    settlement-completed: bool, ;; Market resolution status
  }
)

;; Participant Position Tracking
;; Individual user prediction and payout registry
(define-map trader-positions
  {
    market-id: uint, ;; Reference to prediction market
    trader: principal, ;; User wallet address
  }
  {
    direction: (string-ascii 4), ;; "up" or "down" prediction
    staked-amount: uint, ;; STX tokens committed
    rewards-claimed: bool, ;; Payout status flag
  }
)

;; CORE PROTOCOL FUNCTIONS

;; MARKET CREATION & MANAGEMENT

;; Create New Prediction Market
;; Initializes fresh Bitcoin price prediction opportunity
(define-public (initialize-market
    (opening-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let ((new-market-id (var-get global-market-id)))
    ;; Authorization validation
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    ;; Parameter validation
    (asserts! (> end-block start-block) ERR_INVALID_PARAMS)
    (asserts! (> opening-price u0) ERR_INVALID_PARAMS)

    ;; Initialize market with default parameters
    (map-set prediction-markets new-market-id {
      initial-btc-price: opening-price,
      final-btc-price: u0,
      bullish-stake-total: u0,
      bearish-stake-total: u0,
      market-start-height: start-block,
      market-end-height: end-block,
      settlement-completed: false,
    })

    ;; Increment global market counter
    (var-set global-market-id (+ new-market-id u1))

    (ok new-market-id)
  )
)

;; PREDICTION SUBMISSION SYSTEM

;; Submit Bitcoin Price Prediction
;; Allows users to stake STX on Bitcoin price direction
(define-public (submit-prediction
    (market-id uint)
    (price-direction (string-ascii 4))
    (stake-amount uint)
  )
  (let (
      (market-data (unwrap! (map-get? prediction-markets market-id) ERR_RESOURCE_NOT_FOUND))
      (current-height stacks-block-height)
    )
    ;; Market timing validation
    (asserts!
      (and
        (>= current-height (get market-start-height market-data))
        (< current-height (get market-end-height market-data))
      )
      ERR_MARKET_INACTIVE
    )

    ;; Prediction parameter validation  
    (asserts! (or (is-eq price-direction "up") (is-eq price-direction "down"))
      ERR_INVALID_PREDICTION
    )
    (asserts! (>= stake-amount (var-get minimum-stake-amount))
      ERR_INVALID_PREDICTION
    )
    (asserts! (<= stake-amount (stx-get-balance tx-sender))
      ERR_INSUFFICIENT_FUNDS
    )

    ;; Transfer stake to contract escrow
    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))

    ;; Record trader position
    (map-set trader-positions {
      market-id: market-id,
      trader: tx-sender,
    } {
      direction: price-direction,
      staked-amount: stake-amount,
      rewards-claimed: false,
    })

    ;; Update market aggregates
    (map-set prediction-markets market-id
      (merge market-data {
        bullish-stake-total: (if (is-eq price-direction "up")
          (+ (get bullish-stake-total market-data) stake-amount)
          (get bullish-stake-total market-data)
        ),
        bearish-stake-total: (if (is-eq price-direction "down")
          (+ (get bearish-stake-total market-data) stake-amount)
          (get bearish-stake-total market-data)
        ),
      })
    )

    (ok true)
  )
)

;; ORACLE SETTLEMENT MECHANISM  

;; Resolve Market with Final Price
;; Oracle-driven market settlement with Bitcoin price data
(define-public (settle-market
    (market-id uint)
    (closing-price uint)
  )
  (let ((market-data (unwrap! (map-get? prediction-markets market-id) ERR_RESOURCE_NOT_FOUND)))
    ;; Oracle authorization check
    (asserts! (is-eq tx-sender (var-get oracle-principal)) ERR_UNAUTHORIZED)

    ;; Settlement timing and status validation
    (asserts! (>= stacks-block-height (get market-end-height market-data))
      ERR_MARKET_INACTIVE
    )
    (asserts! (not (get settlement-completed market-data)) ERR_MARKET_INACTIVE)
    (asserts! (> closing-price u0) ERR_INVALID_PARAMS)

    ;; Finalize market settlement
    (map-set prediction-markets market-id
      (merge market-data {
        final-btc-price: closing-price,
        settlement-completed: true,
      })
    )

    (ok true)
  )
)