#[test_only]
module dao_bounty::bounty_tests {

    use std::signer;
    use std::vector;
    use aptos_framework::aptos_account;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin;
    use dao_bounty::bounty;

    fun setup_aptos(
        aptos_framework: &signer,
        accounts: vector<address>,
        balances: vector<u64>
    ) {
        if (!coin::is_coin_initialized<AptosCoin>()) {
            let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
            coin::destroy_mint_cap<AptosCoin>(mint_cap);
            coin::destroy_burn_cap<AptosCoin>(burn_cap);
        };

        assert!(vector::length(&accounts) == vector::length(&balances), 1);

        while (!vector::is_empty(&accounts)) {
            let account = vector::pop_back(&mut accounts);
            let balance = vector::pop_back(&mut balances);
            aptos_account::create_account(account);
            aptos_coin::mint(aptos_framework, account, balance);
        };
    }

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
        let admin_address = signer::address_of(admin);
        let owner_address = signer::address_of(owner);
        setup_aptos(
            &aptos_framework,
            vector<address>[admin_address, owner_address],
            vector<u64>[0, 0]
        );
        bounty::initialize(owner, admin_address);
        assert!(bounty::get_bounties_number() == 0, 1);
        assert!(bounty::get_admin_address() == admin_address, 1);
    }

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x123,
        issuer = @0x234,
    )]
    fun test_issue_bounty(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
        issuer: &signer,
    ) {
        let owner_address = signer::address_of(owner);
        let admin_address = signer::address_of(admin);
        let issuer_address = signer::address_of(issuer);
        setup_aptos(
            &aptos_framework,
            vector<address>[owner_address, admin_address, issuer_address],
            vector<u64>[0, 0, 0]
        );

        bounty::initialize(owner, admin_address);
        bounty::issue_bounty<AptosCoin>(issuer);
        assert!(bounty::get_bounties_number() == 1, 1);
        bounty::issue_bounty<AptosCoin>(issuer);
        assert!(bounty::get_bounties_number() == 2, 1);
        assert!(bounty::get_bounty_issuer(0) == signer::address_of(issuer), 1);
        assert!(bounty::get_bounty_issuer(1) == signer::address_of(issuer), 1);
    }

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x123,
        issuer = @0x234,
    )]
    fun test_contribute(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
        issuer: &signer,
    ) {
        let owner_address = signer::address_of(owner);
        let admin_address = signer::address_of(admin);
        let issuer_address = signer::address_of(issuer);
        setup_aptos(
            &aptos_framework,
            vector<address>[owner_address, admin_address, issuer_address],
            vector<u64>[0, 0, 20000]
        );

        bounty::initialize(owner, admin_address);
        bounty::issue_bounty<AptosCoin>(issuer);
        let bounties_number = bounty::get_bounties_number();
        assert!(bounties_number == 1, 1);
        let bounty_id = bounties_number - 1;
        bounty::contribute<AptosCoin>(issuer, bounty_id, 10000);
        let contributor_numbers = bounty::get_contributors_number(bounty_id);
        assert!(contributor_numbers == 1, 1);
        let balance = coin::balance<AptosCoin>(issuer_address);
        assert!(balance == 10000, 1);
        let bounty_balance = bounty::get_bounty_balance<AptosCoin>(bounty_id);
        assert!(bounty_balance == 10000, 1);
    }

    #[test(
        aptos_framework = @aptos_framework,
        owner = @dao_bounty,
        admin = @0x123,
        issuer = @0x234,
        fulfiller1 = @0x345,
        fulfiller2 = @0x456,
    )]
    fun test_accept_fulfillment(
        aptos_framework: signer,
        owner: &signer,
        admin: &signer,
        issuer: &signer,
        fulfiller1: &signer,
        fulfiller2: &signer,
    ) {
        let owner_address = signer::address_of(owner);
        let admin_address = signer::address_of(admin);
        let issuer_address = signer::address_of(issuer);
        let fulfiller1_address = signer::address_of(fulfiller1);
        let fulfiller2_address = signer::address_of(fulfiller2);
        setup_aptos(
            &aptos_framework,
            vector<address>[owner_address, admin_address, issuer_address],
            vector<u64>[0, 0, 20000]
        );

        bounty::initialize(owner, admin_address);
        bounty::issue_bounty<AptosCoin>(issuer);
        let bounties_number = bounty::get_bounties_number();
        assert!(bounties_number == 1, 1);
        let bounty_id = bounties_number - 1;
        bounty::contribute<AptosCoin>(issuer, bounty_id, 10000);
        let contributor_numbers = bounty::get_contributors_number(bounty_id);
        assert!(contributor_numbers == 1, 1);
        let balance = coin::balance<AptosCoin>(issuer_address);
        assert!(balance == 10000, 1);
        let bounty_balance = bounty::get_bounty_balance<AptosCoin>(bounty_id);
        assert!(bounty_balance == 10000, 1);

        let fulfillers = vector<address>[fulfiller1_address, fulfiller2_address];
        let amounts = vector<u64>[3000, 7000];
        bounty::accept_fulfillment<AptosCoin>(issuer, bounty_id, fulfillers, amounts);
        let fulfiller1_balance = coin::balance<AptosCoin>(fulfiller1_address);
        let fulfiller2_balance = coin::balance<AptosCoin>(fulfiller2_address);
        assert!(fulfiller1_balance == 3000, 1);
        assert!(fulfiller2_balance == 7000, 1);
        bounty_balance = bounty::get_bounty_balance<AptosCoin>(bounty_id);
        assert!(bounty_balance == 0, 1);
    }
}
