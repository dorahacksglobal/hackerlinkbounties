use cosmwasm_std::Addr;
use cw_multi_test::App;

use crate::{
    contract::ContractError, multitest::proxy::DBContractCodeId, contract::AdminListResp,
};

#[test]
fn basic() {
    let mut app = App::default();

    let owner = Addr::unchecked("addr0001");
    let admins = vec![
        "admin1".to_owned(),
        "admin2".to_owned(),
        "admin3".to_owned(),
    ];

    let code_id = DBContractCodeId::store_code(&mut app);

    let contract = code_id
        .instantiate(
            &mut app, 
            &owner, 
            admins.clone(), 
            "Quadratic grant contract", 
            None)
        .unwrap();

    let resp = contract.admin_list(&app).unwrap();

    assert_eq!(resp, AdminListResp { admins });
}

#[test]
fn unathorized() {
    let mut app = App::default();

    let owner = Addr::unchecked("addr0001");
    let admin1 = Addr::unchecked("admin1");
    let admin2 = Addr::unchecked("admin2");
    let admin3 = Addr::unchecked("admin3");

    let code_id = DBContractCodeId::store_code(&mut app);

    let contract = code_id
        .instantiate(
            &mut app,
            &owner,
            vec![admin1.to_string(), admin2.to_string()],
            "Quadratic grant contract", 
            None,
        )
        .unwrap();

    let resp = contract.admin_list(&app).unwrap();

    assert_eq!(
        resp,
        AdminListResp {
            admins: vec![admin1.to_string(), admin2.to_string()]
        }
    );

    let err = contract
        .add_member(&mut app, &admin3, admin3.to_string())
        .unwrap_err();

    assert_eq!(err, ContractError::Unauthorized { sender: admin3 });

    let resp = contract.admin_list(&app).unwrap();

    assert_eq!(
        resp,
        AdminListResp {
            admins: vec![admin1.to_string(), admin2.to_string()]
        }
    );
}

#[test]
fn no_dup() {
    let mut app = App::default();

    let owner = Addr::unchecked("addr0001");
    let admin1 = Addr::unchecked("admin1");
    let admin2 = Addr::unchecked("admin2");

    let code_id = DBContractCodeId::store_code(&mut app);

    let contract = code_id
        .instantiate(
            &mut app,
            &owner,
            vec![admin1.to_string(), admin2.to_string()],
            "Quadratic grant contract", 
            None,
        )
        .unwrap();

    let resp = contract.admin_list(&app).unwrap();

    assert_eq!(
        resp,
        AdminListResp {
            admins: vec![admin1.to_string(), admin2.to_string()]
        }
    );

    let err = contract
        .add_member(&mut app, &admin1, admin1.to_string())
        .unwrap_err();

    assert_eq!(err, ContractError::NoDupAddress { address: admin1.to_owned() });

    let resp = contract.admin_list(&app).unwrap();

    assert_eq!(
        resp,
        AdminListResp {
            admins: vec![admin1.to_string(), admin2.to_string()]
        }
    );
}
