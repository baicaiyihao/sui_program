/*
#[test_only]
module faucetsui::faucetsui_tests;
// uncomment this line to import the module
// use faucetsui::faucetsui;

const ENotImplemented: u64 = 0;

#[test]
fun test_faucetsui() {
    // pass
}

#[test, expected_failure(abort_code = ::faucetsui::faucetsui_tests::ENotImplemented)]
fun test_faucetsui_fail() {
    abort ENotImplemented
}
*/
#[test_only]
module faucetsui::faucetsui_tests{
    use faucetsui::faucetsui::{Self, AdminCap, Gaspool, HoHCourse} ;
    use sui::test_scenario::{Self};
    use std::string;
    use sui::sui::SUI;

    #[test]
    fun test_add_gas_create_hohcourse_wrap_coin() {
        let user = @0xa;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;

        faucetsui::init_for_testing(test_scenario::ctx(scenario));

        test_scenario::next_tx(scenario, user);

        let name = string::utf8(b"hoh");
        let desc = string::utf8(b"hoh cource");
        let githubid = string::utf8(b"test");
        let studentname = vector[string::utf8(b"test")];
        let studentaddress = vector[user];

        {
            let gaspool = test_scenario::take_shared<Gaspool>(scenario);
            let coin = sui::coin::mint_for_testing<SUI>(
                10000000,
                test_scenario::ctx(scenario)
            );
            faucetsui::addgas(
                coin,
                &mut gaspool,
                test_scenario::ctx(scenario)
            );
            test_scenario::return_shared(gaspool);
        };

        test_scenario::next_tx(scenario, user);
        {
            let admincap = test_scenario::take_from_sender<AdminCap>(scenario);
            faucetsui::createHOHCource(
                &admincap,
                name,
                desc,
                studentaddress,
                studentname,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario,admincap);
        };



        test_scenario::next_tx(scenario,user);
        {
            let gaspool = test_scenario::take_shared<Gaspool>(scenario);
            let hoHCourse = test_scenario::take_shared<HoHCourse>(scenario);
            faucetsui::faucetgas{
                githubid,
                gaspool,
                hoHCourse,
                test_scenario::ctx(scenario)
            };
            test_scenario::return_shared(gaspool);
            test_scenario::return_shared(hoHCourse);
        };

        test_scenario::end(scenario_val);
    }

}
