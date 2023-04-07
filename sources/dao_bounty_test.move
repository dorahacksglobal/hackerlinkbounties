#[test_only]
module dao_bounty::bounty_tests {

    use std::signer;
    use aptos_framework::aptos_account;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin;
    use dao_bounty::bounty;

    const INIT_BALANCE: u64 = 10000;

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x123,
    )]
    fun test_initialize(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
    ) {
        if (!coin::is_coin_initialized<AptosCoin>()) {
            let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(&aptos_framework);
            coin::destroy_mint_cap<AptosCoin>(mint_cap);
            coin::destroy_burn_cap<AptosCoin>(burn_cap);
        };

        let admin_address = signer::address_of(admin);
        let owner_address = signer::address_of(owner);
        aptos_account::create_account(owner_address);
        bounty::initialize(owner, admin_address);
        assert!(bounty::get_bounty_numbers() == 0, 1);
        assert!(bounty::get_admin_address() == admin_address, 1);
        aptos_coin::mint(&aptos_framework, owner_address, INIT_BALANCE);
    }

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x234,
    )]
    fun test_issue_bounty(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
    ) {
        test_initialize(aptos_framework, owner, admin);
        bounty::issue_bounty(owner);
        assert!(bounty::get_bounty_numbers() == 1, 1);
        bounty::issue_bounty(owner);
        assert!(bounty::get_bounty_numbers() == 2, 1);
        assert!(bounty::get_bounty_issuer(0) == signer::address_of(owner), 1);
        assert!(bounty::get_bounty_issuer(1) == signer::address_of(owner), 1);
    }

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x234,
    )]
    fun test_contribute(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
    ) {
        test_initialize(aptos_framework, owner, admin);
        bounty::issue_bounty(owner);
    }
}
