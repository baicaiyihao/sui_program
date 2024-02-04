module sicbogame::sicbogame{
    use std::vector;
    use sui::event;
    use sui::tx_context::{ TxContext};
    use std::string;
    use sicbogame::random;

    const ERROR_INPUT_NUM :u64 = 1;

    struct Result has copy,drop {
        msg: string::String
    }


    public entry fun create_game(input_num: u64, ctx: &mut TxContext){

        assert!((input_num != 1 || input_num !=0), ERROR_INPUT_NUM);

        let dice1 = random::rand_u64_range(1, 6, ctx);
        let dice2 = random::rand_u64_range(1, 6, ctx);
        let dice3 = random::rand_u64_range(1, 6, ctx);
        let dice = dice1 + dice2 + dice3;

        let resp;

        if (input_num == 0) {
            if (dice >= 4 && dice <= 10) {
                resp = b"You Win :)";
            } else {
                resp = b"You Lose :(";
            }
        }
        else if (input_num == 1) {
            if (dice >= 11 && dice <= 17) {
                resp = b"You Win :)";
            } else {
                resp = b"You Lose :(";
            }
        } else {
            resp = b"Invalid input number";
        };
 
        event::emit(Result{msg: string::utf8(resp)});
    }


    #[test_only]
    public fun test_game(ctx: &mut TxContext) {
        let input_num = 0;
        create_game(input_num,ctx);
    }

}