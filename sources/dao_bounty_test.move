#[test_only]
module dao_bounty::bounty_tests {

    use std::signer;
    use aptos_framework::aptos_account;

    use dao_bounty::bounty;

    #[test(
        owner = @dao_bounty,
        operator = @0x123,
    )]
    fun initialize_should_work(
        owner: &signer,
        operator: &signer,
    ) {
        let operator_addr = signer::address_of(operator);
        let owner_address = signer::address_of(owner);
        aptos_account::create_account(owner_address);
        bounty::initialize(owner, operator_addr);
    }
}
