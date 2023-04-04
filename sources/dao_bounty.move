module dao_bounty::bounty {

    use std::error;
    use std::signer;
    use std::vector;
    use aptos_std::event;
    use aptos_std::table::{Self, Table};
    use aptos_framework::account;

    const ERR_PERMISSION_DENIED: u64 = 3000;
    const ERR_HAS_PUBLISHED: u64 = 3001;

    struct Data has key {
        admin: address,
        bounty_numbers: u64,
        bounties: Table<u256, Bounty>,
        started: bool,
        events: event::EventHandle<BountyEvent>,
    }

    struct Bounty has store, drop {
        issuer: address,
        balance: u256,
        has_paid_out: bool,
        contributions: vector<Record>,
        fulfillers: vector<Record>,
    }

    struct Record has store, drop {
        account: address,
        amount: u256,
    }

    struct BountyEvent has store, drop {
        bounty_id: u64,
    }

    public fun get_bounty_numbers(): u64 acquires Data {
        *&borrow_global<Data>(@dao_bounty).bounty_numbers
    }

    public entry fun initialize(owner: &signer, admin: address) {
        let owner_addr = signer::address_of(owner);
        assert!(
            @dao_bounty == owner_addr,
            error::permission_denied(ERR_PERMISSION_DENIED),
        );
        assert!(
            !exists<Data>(@dao_bounty), 
            error::already_exists(ERR_HAS_PUBLISHED));
        move_to(
            owner,
            Data {
                admin,
                bounty_numbers: 0,
                bounties: table::new(),
                started: false,
                events: account::new_event_handle<BountyEvent>(owner),
            }
        );
    }

    public entry fun issue_bounty(issuer: &signer) acquires Data {
        let data = borrow_global_mut<Data>(@dao_bounty);
        let bounty_id = data.bounty_numbers;
        let issuer_address = signer::address_of(issuer);
        let _new_bounty = Bounty {
            issuer: issuer_address,
            balance: 0,
            has_paid_out: false,
            contributions: vector::empty<Record>(),
            fulfillers: vector::empty<Record>(),
        };
        event::emit_event(&mut data.events, BountyEvent {
            bounty_id,
        });
    }
}
