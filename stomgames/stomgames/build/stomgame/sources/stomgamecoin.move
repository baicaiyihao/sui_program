module stomgame::stomgamecoin{
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext, sender};
    use sui::table::{Self, Table};
    use sui::event;
    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID};
    use sui::clock::{Self, Clock};

    // friend stomgame::stomgame;

    struct UCA has store {
        user: address,
    }

    //coin's name
    struct STOMGAMECOIN has drop {}

    struct Vault has key {
        id: UID,
        balance: Balance<STOMGAMECOIN>,
        userlist: Table<address, UCA>,
    }


    fun init(witness: STOMGAMECOIN,ctx: &mut TxContext) {
        let (treasury_cap,metadata) = coin::create_currency(witness, 0, b"STOMGAMECOIN", b"SC", b"", option::none(), ctx);
        let coins_minted = coin::mint<STOMGAMECOIN>(&mut treasury_cap, 100, ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
        transfer::share_object(
            Vault {
                id: object::new(ctx),
                balance: coin::into_balance<STOMGAMECOIN>(coins_minted),
                userlist: table::new<address, UCA>(ctx),
            }
        );
    }

    //signIn everyday
    public entry fun signIn(
        vault: &mut Vault, ctx: &mut TxContext
    ) {
        assert!(!table::contains<address, UCA>(&vault.userlist, sender(ctx)),1);
        let balance_drop = balance::split(&mut vault.balance, 10);
        let coin_drop = coin::take(&mut balance_drop, 10, ctx);
        transfer::public_transfer(coin_drop, sender(ctx));
        balance::destroy_zero(balance_drop);
        table::add<address, UCA>(&mut vault.userlist, sender(ctx), UCA {
            user: sender(ctx),
        });
    }


    //burn coins
    public fun burn(treasury_cap: &mut TreasuryCap<STOMGAMECOIN>, coin: Coin<STOMGAMECOIN>) {
        coin::burn(treasury_cap, coin);
    }

    #[test_only]
    // Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(STOMGAMECOIN {}, ctx)
    }
}
