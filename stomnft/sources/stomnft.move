module stomnft::stomnft{
    use sui::tx_context::{sender, TxContext};
    use std::string::{utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::package;
    use sui::display;

    struct StomNFT has key, store {
        id: UID,
        name:String,
        description:String,
        image_url:String,
        tokenId: u64
    }

    struct STOMNFT has drop {}

    struct State has key {
        id: UID,
        count: u64
    }

    #[allow(unused_function)]
    fun init(witness: STOMNFT, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
        ];

        let values = vector[
            utf8(b"{name}"),
            utf8(b"{image_url}"),
            utf8(b"{description}"),
        ];

        let publisher = package::claim(witness, ctx);

        let display = display::new_with_fields<StomNFT>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
        
        transfer::share_object(State{
            id: object::new(ctx),
            count: 0
        });
    
    }


    #[lint_allow(self_transfer)]
    public entry fun mint(state: &mut State,name:String,description:String,image_url:String, ctx: &mut TxContext){
        state.count = state.count + 1;
        let nft = StomNFT { 
            id:object::new(ctx),
            name:name,
            description:description,
            image_url:image_url,
            tokenId:state.count
        };
        transfer::public_transfer(nft,sender(ctx));
    }
}