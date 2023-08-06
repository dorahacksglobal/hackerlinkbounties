use cosmwasm_std::{Addr, StdResult};
use cw_multi_test::{App, AppResponse, Executor};

use crate::contract::{
    AdminListResp, ContractError, DBContract, ExecMsg, InstantiateMsg, QueryMsg,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct DBContractCodeId(u64);

impl DBContractCodeId {
    pub fn store_code(app: &mut App) -> Self {
        let code_id = app.store_code(Box::new(DBContract::new()));
        Self(code_id)
    }

    #[track_caller]
    pub fn instantiate(
        self,
        app: &mut App,
        sender: &Addr,
        admins: Vec<String>,
        label: &str,
        admin: Option<String>,
    ) -> StdResult<DBContractProxy> {
        let msg = InstantiateMsg { admins };

        app.instantiate_contract(self.0, sender.clone(), &msg, &[], label, admin)
            .map_err(|err| err.downcast().unwrap())
            .map(DBContractProxy)
    }
}

#[derive(Debug)]
pub struct DBContractProxy(Addr);

impl DBContractProxy {
    // pub fn addr(&self) -> &Addr {
    //     &self.0
    // }

    #[track_caller]
    pub fn admin_list(&self, app: &App) -> StdResult<AdminListResp> {
        let msg = QueryMsg::GetAdminList {};

        app.wrap().query_wasm_smart(self.0.clone(), &msg)
    }

    #[track_caller]
    pub fn add_member(
        &self,
        app: &mut App,
        sender: &Addr,
        admin: String,
    ) -> Result<AppResponse, ContractError> {
        let msg = ExecMsg::AddMember { admin };

        app.execute_contract(sender.clone(), self.0.clone(), &msg, &[])
            .map_err(|err| err.downcast().unwrap())
    }
}
