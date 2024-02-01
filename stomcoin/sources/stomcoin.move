module stomcoin::stomcoin{
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    //coin's name
    struct STOMCOIN has drop {}

    //init
    fun init(witness: STOMCOIN,ctx: &mut TxContext) {
        let (treasury_cap,metadata) = coin::create_currency<STOMCOIN>(witness, 2, b"STOMCOIN", b"SC", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    //mint new coins
    public fun mint(
        treasury_cap: &mut TreasuryCap<STOMCOIN>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    //burn coins
    public fun burn(treasury_cap: &mut TreasuryCap<STOMCOIN>, coin: Coin<STOMCOIN>) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    // Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(STOMCOIN {}, ctx)
    }
}