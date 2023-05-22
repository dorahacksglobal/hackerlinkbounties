module dao_bounty::bounty {

    use std::bcs;
    use std::error;
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_std::event;
    use aptos_std::type_info;
    use aptos_std::table::{Self, Table};
    use aptos_framework::account;
    use aptos_framework::coin;

    const ERR_ONLY_ISSUER: u64 = 1000;
    const ERR_HAS_PAID_OUT: u64 = 1001;
    const ERR_INDEX_VALIDATION_FAILED: u64 = 1002;
    const ERR_OWNER_ONLY: u64 = 1003;
    const ERR_HAS_INITIALIZED: u64 = 1004;
    const ERR_AMOUNT_GREATER_THAN_ZERO: u64 = 1005;
    const ERR_COIN_TYPE_MISMATCH: u64 = 1006;
    const ERR_FULFILLERS_AMOUNTS_MISMATCH: u64 = 1007;
    const ERR_BALANCE_NOT_ENOUGH: u64 = 1008;

    struct Data has key {
        admin: address,
        bounty_numbers: u64,
        bounties: Table<u64, Bounty>,
        bounty_events: event::EventHandle<BountyEvent>,
        contribution_events: event::EventHandle<ContributionEvent>,
        fulfillment_events: event::EventHandle<FulfillmentEvent>,
    }

    struct Bounty has store, drop {
        issuer: address,
        balance: u64,
        has_paid_out: bool,
        contributions: vector<Record>,
        fulfillers: vector<Record>,
        escrow_address: address,
        coin_type: string::String,
    }

    struct Record has store, drop {
        account: address,
        amount: u64,
    }

    struct Escrow<phantom CoinType> has key {
        coin: coin::Coin<CoinType>,
    }

    // start of events
    struct BountyEvent has store, drop {
        bounty_id: u64,
        issuer: address,
    }

    struct ContributionEvent has store, drop {
        bounty_id: u64,
        contribution_id: u64,
        contributor: address,
        amount: u64,
    }

    struct FulfillmentEvent has store, drop {
        bounty_id: u64,
        fulfillers: vector<address>,
        amounts: vector<u64>,
    }
    // end of events

    // start of check functions
    public fun only_issuer(sender: &signer, bounty_id: u64) acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let sender_address = signer::address_of(sender);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        
        assert!(
            sender_address == bounty.issuer,
            error::permission_denied(ERR_ONLY_ISSUER),
        );
    }

    public fun has_not_paid_out(bounty_id: u64) acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        assert!(
            !bounty.has_paid_out,
            error::permission_denied(ERR_HAS_PAID_OUT),
        );
    }

    public fun validate_bounty_array_index(index: u64) acquires Data {
        let numbers = get_bounties_number();
        assert!(
            index < numbers,
            error::permission_denied(ERR_INDEX_VALIDATION_FAILED),
        );
    }
    // end of check functions

    // start of normal functions
    fun merge_coin<CoinType>(
        resource: address,
        coin: coin::Coin<CoinType>
    ) acquires Escrow {
        let escrow = borrow_global_mut<Escrow<CoinType>>(resource);
        coin::merge(&mut escrow.coin, coin);
    }

    public fun get_bounties_number(): u64 acquires Data {
        *&borrow_global<Data>(@dao_bounty).bounty_numbers
    }

    #[test_only]
    public fun get_admin_address(): address acquires Data {
        *&borrow_global<Data>(@dao_bounty).admin
    }

    #[test_only]
    public fun get_bounty_issuer(bounty_id: u64): address acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        *&bounty.issuer
    }

    #[test_only]
    public fun get_contributors_number(bounty_id: u64): u64 acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        vector::length(&bounty.contributions)
    }

    #[test_only]
    public fun get_bounty_balance<CoinType>(bounty_id: u64): u64 acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        bounty.balance
    }
    // end of normal functions

    // start of entry functions
    public entry fun initialize(owner: &signer, admin: address) {
        let owner_addr = signer::address_of(owner);
        assert!(
            @dao_bounty == owner_addr,
            error::permission_denied(ERR_OWNER_ONLY),
        );
        assert!(
            !exists<Data>(@dao_bounty), 
            error::already_exists(ERR_HAS_INITIALIZED),
        );
        move_to(
            owner,
            Data {
                admin,
                bounty_numbers: 0,
                bounties: table::new(),
                bounty_events: account::new_event_handle<BountyEvent>(owner),
                contribution_events: account::new_event_handle<ContributionEvent>(owner),
                fulfillment_events: account::new_event_handle<FulfillmentEvent>(owner),
            }
        );
    }

    public entry fun issue_bounty<CoinType>(issuer: &signer) acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty_id = data.bounty_numbers;
        let issuer_address = signer::address_of(issuer);
        data.bounty_numbers = data.bounty_numbers + 1;
        let coin_type = type_info::type_name<CoinType>();
        let seed = *string::bytes(&coin_type);
        vector::append(&mut seed, bcs::to_bytes(&bounty_id));
        let (resource, _signer_cap) = account::create_resource_account(issuer, seed);

        move_to(
            &resource,
            Escrow<CoinType> {
                coin: coin::zero<CoinType>()
            }
        );
        table::upsert(&mut data.bounties, bounty_id, Bounty {
            issuer: issuer_address,
            balance: 0,
            has_paid_out: false,
            contributions: vector::empty(),
            fulfillers: vector::empty(),
            escrow_address: signer::address_of(&resource),
            coin_type,
        });
        event::emit_event(&mut data.bounty_events, BountyEvent {
            bounty_id,
            issuer: issuer_address,
        });
    }

    public entry fun contribute<CoinType>(
        issuer: &signer,
        bounty_id: u64,
        deposit_amount: u64
    ) acquires Data, Escrow {
        assert!(
            deposit_amount > 0,
            error::permission_denied(ERR_AMOUNT_GREATER_THAN_ZERO),
        );

        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        let coin_type = type_info::type_name<CoinType>();
        assert!(
            bounty.coin_type == coin_type,
            error::permission_denied(ERR_COIN_TYPE_MISMATCH),
        );

        let escrow_coin = coin::withdraw<CoinType>(issuer, deposit_amount);
        merge_coin<CoinType>(bounty.escrow_address, escrow_coin);
        let record = Record {
            account: signer::address_of(issuer),
            amount: deposit_amount,
        };
        vector::push_back(&mut bounty.contributions, record);
        bounty.balance = bounty.balance + deposit_amount;
        let length = vector::length(&bounty.contributions);
        event::emit_event(&mut data.contribution_events, ContributionEvent {
            bounty_id,
            contribution_id: length - 1,
            contributor: signer::address_of(issuer),
            amount: deposit_amount,
        });
    }

    public entry fun issue_and_contribute<CoinType>(
        issuer: &signer,
        deposit_amount: u64
    ) acquires Data, Escrow {
        issue_bounty<CoinType>(issuer);
        let bounty_id = get_bounties_number() - 1;
        contribute<CoinType>(issuer, bounty_id, deposit_amount);
    }

    public entry fun accept_fulfillment<CoinType>(
        issuer: &signer,
        bounty_id: u64,
        fulfillers: vector<address>,
        amounts: vector<u64>
    ) acquires Data, Escrow {
        validate_bounty_array_index(bounty_id);
        only_issuer(issuer, bounty_id);
        assert!(
            vector::length(&fulfillers) == vector::length(&amounts),
            error::permission_denied(ERR_FULFILLERS_AMOUNTS_MISMATCH),
        );

        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty = table::borrow_mut(&mut data.bounties, bounty_id);
        let coin_type = type_info::type_name<CoinType>();
        assert!(
            bounty.coin_type == coin_type,
            error::permission_denied(ERR_COIN_TYPE_MISMATCH),
        );

        let escrow_coin = borrow_global_mut<Escrow<CoinType>>(bounty.escrow_address);
        let length = vector::length(&fulfillers);
        let i = 0;
        while (i < length){
            let fulfiller = *vector::borrow(&fulfillers, i);
            let amount = *vector::borrow(&amounts, i);

            assert!(amount > 0, error::permission_denied(ERR_AMOUNT_GREATER_THAN_ZERO));
            assert!(bounty.balance >= amount, error::permission_denied(ERR_BALANCE_NOT_ENOUGH));

            bounty.balance = bounty.balance - amount;
            let coin = coin::extract<CoinType>(&mut escrow_coin.coin, amount);
            coin::deposit<CoinType>(fulfiller, coin);
            vector::push_back(
                &mut bounty.fulfillers,
                Record {
                    account: fulfiller,
                    amount,
                });
            i = i + 1;
        };
        if (bounty.balance == 0) {
            bounty.has_paid_out = true;
        };

        event::emit_event(&mut data.fulfillment_events, FulfillmentEvent {
            bounty_id,
            fulfillers,
            amounts,
        });
    }
    // end of entry functions
}
