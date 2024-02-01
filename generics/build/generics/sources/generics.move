module generics::generics {
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    struct Box<T: store> has key, store {
        id: UID,
        value: T
    }

    struct SimpleBox has key, store {
        id: UID,
        value: u8
    }

    struct PhantomBox<phantom T: drop> has key {
        id: UID,
    }

    public fun create_box<T: store>(value: T,  ctx: &mut TxContext){
        transfer::transfer(Box<T> {id: object::new(ctx), value }, tx_context::sender(ctx))
    }

    public fun create_simple_box(value: u8,  ctx: &mut TxContext){
        transfer::transfer(SimpleBox {id: object::new(ctx), value }, tx_context::sender(ctx))
    }

    public fun create_phantom_box<T: drop >(_value: T,  ctx: &mut TxContext){
        transfer::transfer(PhantomBox<T> {id: object::new(ctx)}, tx_context::sender(ctx))
    }

    public fun transfer_value<T: key + store>(box: Box<T>, ctx: &mut TxContext) {
        let Box{
            id,
            value
        }= box;
        transfer::public_transfer<T>(value, tx_context::sender(ctx));
        object::delete(id)
    }

}