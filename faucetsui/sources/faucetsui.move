/*
/// Module: faucetsui
module faucetsui::faucetsui;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module faucetsui::faucetsui{
    use std::string::String;
    use sui::balance::{Balance, zero};
    use sui::coin::{Coin, into_balance, from_balance};
    use sui::event;
    use sui::sui::SUI;
    use sui::table::{Self, Table};

    public struct AdminCap has key {
        id: UID,
    }

    public struct Gaspool has key{
        id: UID,
        coin: Balance<SUI>
    }

    public struct HoHCourse has key{
        id: UID,
        name: String,
        description: String,
        studentlist: Table<String,address>
    }

    public struct HoHCourceCreate has copy, drop{
        name: String,
        id: ID
    }

    fun init(ctx:&mut TxContext){
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };

        let gaspool = Gaspool{
            id: object::new(ctx),
            coin: zero<SUI>()
        };

        transfer::transfer(admin_cap,ctx.sender());
        transfer::share_object(gaspool)
    }

    public fun mintAdminCap(_: &AdminCap, user: address, ctx: &mut TxContext) {
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        transfer::transfer(admin_cap, user);
    }

    public fun createHOHCource(
        _admincap: &AdminCap,
        name: String,
        description: String,
        addresses: vector<address>,
        githubids: vector<String>,
        ctx: &mut TxContext
    ){
        assert!(vector::length(&addresses) == vector::length(&githubids), 1);
        let len = vector::length(&githubids);
        let mut studentlist = table::new<String, address>(ctx);

        let mut i = 0;
        while (i < len) {
            let addr = vector::borrow(&addresses, i);
            let id = vector::borrow(&githubids, i);
            table::add(&mut studentlist, *id, *addr);
            i = i + 1;
        };

        let hohcource = HoHCourse{
            id: object::new(ctx),
            name,
            description,
            studentlist
        };

        let id = object::id(&hohcource);
        transfer::share_object(hohcource);
        event::emit(
            HoHCourceCreate{
                name,
                id
            }
        )
    }

    public fun addstudent(
        _: &AdminCap,
        addresses: vector<address>,
        githubids: vector<String>,
        hohcource:&mut HoHCourse,
        _:&mut TxContext
    ){
        assert!(vector::length(&addresses) == vector::length(&githubids), 1);
        let len = vector::length(&githubids);
        let mut i = 0;
        while (i < len) {
            let addr = vector::borrow(&addresses, i);
            let id = vector::borrow(&githubids, i);
            table::add(&mut hohcource.studentlist,*id,*addr);
            i = i + 1;
        };

    }

    public fun addgas(
        suicoin: Coin<SUI>,
        gaspool: &mut Gaspool,
        _: &mut TxContext
    ){
        assert!(suicoin.value() != 0, 0);
        let coinbalance = into_balance(suicoin);
        gaspool.coin.join(coinbalance);
    }

    public entry fun faucetgas(
        githubid: String,
        gaspool:&mut Gaspool,
        hohcource:&mut HoHCourse,
        ctx:&mut TxContext
    ){
        assert!(table::contains(&hohcource.studentlist,githubid) &&
            table::borrow_mut(&mut hohcource.studentlist,githubid) == ctx.sender(),0);
        let coin_balance = gaspool.coin.split(200000000);
        let coin = from_balance(coin_balance, ctx);
        transfer::public_transfer(coin,ctx.sender());
    }

    //==============================================================================================
    // Helper Functions
    //==============================================================================================
    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
}
