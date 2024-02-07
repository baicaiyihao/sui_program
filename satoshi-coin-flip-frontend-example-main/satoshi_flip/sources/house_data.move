module satoshi_flip::house_data {

    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::package::{Self};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{Self};

    const ECallerNotHouse: u64 = 0;
    const EInsufficientBalance: u64 = 1;

    friend satoshi_flip::single_player_satoshi;
    // friend satoshi_flip::mev_attack_resistant_single_player_satoshi;

    struct HouseData has key {
        id: UID,
        balance: Balance<SUI>,
        house: address,
        public_key: vector<u8>,
        max_stake: u64,
        min_stake: u64,
        fees: Balance<SUI>,
        base_fee_in_bp: u16
    }

    struct HouseCap has key {
        id: UID
    }

    struct HOUSE_DATA has drop {}

    fun init(otw: HOUSE_DATA, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);

        let house_cap = HouseCap {
            id: object::new(ctx)
        };

        transfer::transfer(house_cap, tx_context::sender(ctx));
    }

    public fun initialize_house_data(house_cap: HouseCap, coin: Coin<SUI>, public_key: vector<u8>, ctx: &mut TxContext) {
        assert!(coin::value(&coin) > 0, EInsufficientBalance);

        let house_data = HouseData {
            id: object::new(ctx),
            balance: coin::into_balance(coin),
            house: tx_context::sender(ctx),
            public_key,
            max_stake: 50_000_000_000, // 50 SUI.
            min_stake: 1_000_000_000, // 1 SUI.
            fees: balance::zero(),
            base_fee_in_bp: 100 // 1% in basis points.
        };

        let HouseCap { id } = house_cap;
        object::delete(id);

        transfer::share_object(house_data);
    }

     public fun top_up(house_data: &mut HouseData, coin: Coin<SUI>, _: &mut TxContext) {
        coin::put(&mut house_data.balance, coin)
    }

    public fun withdraw(house_data: &mut HouseData, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == house(house_data), ECallerNotHouse);
        let total_balance = balance(house_data);
        let coin = coin::take(&mut house_data.balance, total_balance, ctx);
        transfer::public_transfer(coin, house(house_data));
    }

    public fun claim_fees(house_data: &mut HouseData, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == house(house_data), ECallerNotHouse);
        let total_fees = fees(house_data);
        let coin = coin::take(&mut house_data.fees, total_fees, ctx);
        transfer::public_transfer(coin, house(house_data));
    }

    public fun update_max_stake(house_data: &mut HouseData, max_stake: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == house(house_data), ECallerNotHouse);
        house_data.max_stake = max_stake;
    }

    public fun update_min_stake(house_data: &mut HouseData, min_stake: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == house(house_data), ECallerNotHouse);
        house_data.min_stake = min_stake;
    }

    // --------------- Mutable References ---------------

    public(friend) fun borrow_balance_mut(house_data: &mut HouseData): &mut Balance<SUI> {
        &mut house_data.balance
    }

    public(friend) fun borrow_fees_mut(house_data: &mut HouseData): &mut Balance<SUI> {
        &mut house_data.fees
    }

    public(friend) fun borrow_mut(house_data: &mut HouseData): &mut UID {
        &mut house_data.id
    }

    // --------------- Read-only References ---------------

    public(friend) fun borrow(house_data: &HouseData): &UID {
        &house_data.id
    }

    public fun balance(house_data: &HouseData): u64 {
        balance::value(&house_data.balance)
    }

    public fun house(house_data: &HouseData): address {
        house_data.house
    }

    public fun public_key(house_data: &HouseData): vector<u8> {
        house_data.public_key
    }

    public fun max_stake(house_data: &HouseData): u64 {
        house_data.max_stake
    }

    public fun min_stake(house_data: &HouseData): u64 {
        house_data.min_stake
    }

    public fun fees(house_data: &HouseData): u64 {
        balance::value(&house_data.fees)
    }

    public fun base_fee_in_bp(house_data: &HouseData): u16 {
        house_data.base_fee_in_bp
    }

    // --------------- Test-only Functions ---------------
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(HOUSE_DATA {}, ctx);
    }
}