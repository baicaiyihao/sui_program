module satoshi_flip::counter_nft {
    use std::vector;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{Self};
    use sui::bcs::{Self};

    struct Counter has key {
        id: UID,
        count: u64,
    }

    entry fun burn(self: Counter) {
        let Counter { id, count: _ } = self;
        object::delete(id);
    }

    public fun mint(ctx: &mut TxContext): Counter {
        Counter {
            id: object::new(ctx),
            count: 0
        }
    }

    public fun transfer_to_sender(counter: Counter, ctx: &mut TxContext) {
        transfer::transfer(counter, tx_context::sender(ctx));
    }

    public fun get_vrf_input_and_increment(self: &mut Counter): vector<u8> {
        let vrf_input = object::id_bytes(self);
        let count_to_bytes = bcs::to_bytes(&count(self));
        vector::append(&mut vrf_input, count_to_bytes);
        increment(self);
        vrf_input
    }

    public fun count(self: &Counter): u64 {
        self.count
    }

    fun increment(self: &mut Counter) {
        self.count = self.count + 1;
    }

    #[test_only]
    public fun burn_for_testing(self: Counter) {
        burn(self);
    }
}