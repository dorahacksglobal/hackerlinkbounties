//! DaoBounty Contract
//! Author: noodles@dorahacks.com
//! Version: 0.1.0
//! License: Apache-2.0

use cosmwasm_std::{
    coins, Addr, BankMsg, Empty, Event, Order, Response, StdError,
    StdResult, Uint128,
};
use cw_storage_plus::{Item, Map};

use serde::{Deserialize, Serialize};
use sylvia::contract;
use sylvia::schemars;
use sylvia::types::{ExecCtx, InstantiateCtx, QueryCtx};

#[cfg(not(feature = "library"))]
use sylvia::entry_points;

use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum ContractError {
    // Look at https://docs.rs/thiserror/1.0.21/thiserror/ for details.
    #[error("{0}")]
    Std(#[from] StdError),

    #[error("{sender} is not a contract admin")]
    Unauthorized { sender: Addr },

    #[error("{address} is already an admin")]
    NoDupAddress { address: Addr },

    #[error("Bounty {bounty_id} has already been paid out")]
    BountyHasPaidOut { bounty_id: u64 },

    #[error("expected {expected} but got {actual}")]
    InvalidAmount { expected: u128, actual: u128 },
}

#[derive(Serialize, Deserialize, Clone, PartialEq, Eq, schemars::JsonSchema, Debug, Default)]
pub struct AdminListResp {
    pub admins: Vec<String>,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, schemars::JsonSchema)]
pub struct Bounty {
    pub issuer: Addr,
    pub donation_denom: String,
    pub balance: Uint128,
    pub paid_out: bool,
}

pub struct DBContract<'a> {
    pub(crate) admins: Map<'a, &'a Addr, Empty>,
    pub(crate) bounties: Map<'a, &'a str, Bounty>,
    pub(crate) bounty_count: Item<'a, u64>,
    pub(crate) contributions: Map<'a, (&'a str, &'a Addr), Uint128>,
    pub(crate) fulfillments: Map<'a, (&'a str, &'a Addr), Uint128>,
}

#[cfg_attr(not(feature = "library"), entry_points)]
#[contract]
#[error(ContractError)]
impl DBContract<'_> {
    pub const fn new() -> Self {
        Self {
            admins: Map::new("admins"),
            bounties: Map::new("bounties"),
            bounty_count: Item::new("bounty_count"),
            contributions: Map::new("contributions"),
            fulfillments: Map::new("fulfillments"),
        }
    }

    // ============= Init ============= //
    #[msg(instantiate)]
    pub fn instantiate(&self, ctx: InstantiateCtx, admins: Vec<String>) -> StdResult<Response> {
        let deps = ctx.deps;

        for admin in admins {
            let admin = deps.api.addr_validate(&admin)?;
            self.admins.save(deps.storage, &admin, &Empty {})?;
        }
        self.bounty_count.save(deps.storage, &0)?;
        Ok(Response::new())
    }

    // ============= Query ============= //
    #[msg(query)]
    pub fn get_admin_list(&self, ctx: QueryCtx) -> StdResult<AdminListResp> {
        let deps = ctx.deps;

        let admins: Result<_, _> = self
            .admins
            .keys(deps.storage, None, None, Order::Ascending)
            .map(|addr| addr.map(String::from))
            .collect();

        Ok(AdminListResp { admins: admins? })
    }

    #[msg(query)]
    pub fn get_bounty(&self, ctx: QueryCtx, bounty_id: u64) -> StdResult<Bounty> {
        let deps = ctx.deps;

        let bounty = self
            .bounties
            .may_load(deps.storage, &bounty_id.to_string())?;

        match bounty {
            Some(bounty) => Ok(bounty),
            None => Err(StdError::generic_err("Bounty not found")),
        }
    }

    // ============= Execute ============= //
    #[msg(exec)]
    pub fn add_member(&self, ctx: ExecCtx, admin: String) -> Result<Response, ContractError> {
        let ExecCtx { deps, env: _, info } = ctx;
        if !self.admins.has(deps.storage, &info.sender) {
            return Err(ContractError::Unauthorized {
                sender: info.sender,
            });
        }

        let admin = deps.api.addr_validate(&admin)?;
        if self.admins.has(deps.storage, &admin) {
            return Err(ContractError::NoDupAddress { address: admin });
        }

        self.admins.save(deps.storage, &admin, &Empty {})?;

        let resp = Response::new()
            .add_attribute("action", "add_member")
            .add_event(Event::new("admin_added").add_attribute("addr", admin));
        Ok(resp)
    }

    #[msg(exec)]
    pub fn issue_bounty(
        &self,
        ctx: ExecCtx,
        donation_denom: String,
    ) -> Result<Response, ContractError> {
        let ExecCtx { deps, env: _, info } = ctx;
        let count = self
            .bounty_count
            .may_load(deps.storage)?
            .unwrap_or_default();
        self.bounty_count.save(deps.storage, &(count + 1))?;

        let bounty = Bounty {
            issuer: info.sender,
            donation_denom,
            balance: Uint128::zero(),
            paid_out: false,
        };

        self.bounties
            .save(deps.storage, &count.to_string(), &bounty)?;

        let resp = Response::new()
            .add_attribute("action", "issue_bounty")
            .add_event(Event::new("issue_bounty").add_attribute("id", count.to_string()));
        Ok(resp)
    }

    #[msg(exec)]
    pub fn contribute(
        &self,
        ctx: ExecCtx,
        bounty_id: u64,
        amount: Uint128,
    ) -> Result<Response, ContractError> {
        let ExecCtx { deps, env: _, info } = ctx;
        let mut bounty = self.bounties.load(deps.storage, &bounty_id.to_string())?;

        let denom = bounty.donation_denom.clone();
        let transfer = cw_utils::must_pay(&info, &denom)
            .map_err(|err| StdError::generic_err(err.to_string()))?
            .u128();
        if transfer != amount.u128() {
            return Err(ContractError::InvalidAmount {
                expected: amount.u128(),
                actual: transfer,
            });
        }
        bounty.balance += amount;

        let contribution = self
            .contributions
            .may_load(deps.storage, (&bounty_id.to_string(), &info.sender))
            .unwrap()
            .unwrap_or(Uint128::zero());

        self.contributions
            .save(
                deps.storage,
                (&bounty_id.to_string(), &info.sender),
                &(amount.checked_add(contribution).unwrap()),
            )
            .unwrap();

        self.bounties
            .save(deps.storage, &bounty_id.to_string(), &bounty)?;

        Ok(Response::new()
            .add_attribute("action", "contribute")
            .add_event(
                Event::new("contribute")
                    .add_attribute("id", bounty_id.to_string())
                    .add_attribute("address", info.sender.to_string())
                    .add_attribute("amount", amount.to_string()),
            ))
    }

    #[msg(exec)]
    pub fn issue_and_contribute(
        &self,
        ctx: ExecCtx,
        donation_denom: String,
        amount: Uint128,
    ) -> Result<Response, ContractError> {
        let ExecCtx {
            mut deps,
            env,
            info,
        } = ctx;
        let result1 = self
            .issue_bounty(
                ExecCtx {
                    deps: deps.branch(),
                    env: env.clone(),
                    info: info.clone(),
                },
                donation_denom,
            )
            .unwrap();
        let count = self
            .bounty_count
            .may_load(deps.storage)?
            .unwrap_or_default();

        let result2 = self
            .contribute(
                ExecCtx {
                    deps: deps.branch(),
                    env: env.clone(),
                    info: info.clone(),
                },
                count - 1,
                amount,
            )
            .unwrap();
        Ok(Response::new()
            .add_attributes(result1.attributes)
            .add_events(result1.events)
            .add_attributes(result2.attributes)
            .add_events(result2.events))
    }

    #[msg(exec)]
    pub fn accept_fulfillment(
        &self,
        ctx: ExecCtx,
        bounty_id: u64,
        fulfillers: Vec<Addr>,
        amounts: Vec<Uint128>,
    ) -> Result<Response, ContractError> {
        let ExecCtx { deps, env: _, info } = ctx;
        let mut bounty = self.bounties.load(deps.storage, &bounty_id.to_string())?;

        if bounty.issuer != info.sender {
            return Err(ContractError::Unauthorized {
                sender: info.sender,
            });
        }

        let mut msgs = vec![];
        for (fulfiller, amount) in fulfillers.iter().zip(&amounts) {
            let message = BankMsg::Send {
                to_address: fulfiller.to_string(),
                amount: coins(amount.u128(), &bounty.donation_denom),
            };
            msgs.push(message);

            let fulfillment = self
                .fulfillments
                .may_load(deps.storage, (&bounty_id.to_string(), &fulfiller))
                .unwrap()
                .unwrap_or(Uint128::zero());

            self.fulfillments
                .save(
                    deps.storage,
                    (&bounty_id.to_string(), &fulfiller),
                    &(amount.checked_add(fulfillment).unwrap()),
                )
                .unwrap();

            bounty.balance = bounty.balance - amount;
        }

        if bounty.balance.is_zero() {
            bounty.paid_out = true;
        }

        self.bounties
            .save(deps.storage, &bounty_id.to_string(), &bounty)?;

        Ok(Response::new()
            .add_messages(msgs)
            .add_attribute("action", "accept_fulfillment")
            .add_event(
                Event::new("accept_fulfillment")
                    .add_attribute("id", bounty_id.to_string())
                    .add_attribute(
                        "fulfillers",
                        format!(
                            "{:?}",
                            fulfillers.iter().map(|x| x.to_string()).collect::<String>()
                        ),
                    )
                    .add_attribute(
                        "amounts",
                        format!(
                            "{:?}",
                            amounts.iter().map(|x| x.to_string()).collect::<String>()
                        ),
                    ),
            ))
    }
}

#[cfg(test)]
mod tests {
    use crate::contract::entry_points::{execute, instantiate, query};
    use cosmwasm_std::testing::{mock_dependencies, mock_env, mock_info};
    use cosmwasm_std::{from_binary, Coin, Uint128};

    use super::*;

    #[test]
    fn admin_list_query() {
        let mut deps = mock_dependencies();
        let env = mock_env();

        instantiate(
            deps.as_mut(),
            env.clone(),
            mock_info("sender", &[]),
            InstantiateMsg {
                admins: vec!["admin1".to_owned(), "admin2".to_owned()],
            },
        )
        .unwrap();

        let msg = QueryMsg::GetAdminList {};
        let resp = query(deps.as_ref(), env, ContractQueryMsg::DBContract(msg)).unwrap();
        let resp: AdminListResp = from_binary(&resp).unwrap();
        assert_eq!(
            resp,
            AdminListResp {
                admins: vec!["admin1".to_owned(), "admin2".to_owned()],
            }
        );
    }

    #[test]
    fn add_member() {
        let mut deps = mock_dependencies();
        let env = mock_env();

        instantiate(
            deps.as_mut(),
            env.clone(),
            mock_info("sender", &[]),
            InstantiateMsg {
                admins: vec!["admin1".to_owned(), "admin2".to_owned()],
            },
        )
        .unwrap();

        let info = mock_info("admin1", &[]);
        let msg = ExecMsg::AddMember {
            admin: "admin3".to_owned(),
        };
        execute(
            deps.as_mut(),
            env.clone(),
            info,
            ContractExecMsg::DBContract(msg),
        )
        .unwrap();

        let msg = QueryMsg::GetAdminList {};
        let resp = query(deps.as_ref(), env, ContractQueryMsg::DBContract(msg)).unwrap();
        let resp: AdminListResp = from_binary(&resp).unwrap();
        assert_eq!(
            resp,
            AdminListResp {
                admins: vec![
                    "admin1".to_owned(),
                    "admin2".to_owned(),
                    "admin3".to_owned()
                ],
            }
        );
    }

    #[test]
    fn test_all() {
        let mut deps = mock_dependencies();
        let env = mock_env();

        // Instantiate
        instantiate(
            deps.as_mut(),
            env.clone(),
            mock_info("sender", &[]),
            InstantiateMsg {
                admins: vec!["admin1".to_owned(), "admin2".to_owned()],
            },
        )
        .unwrap();

        // Issue Bounty
        let info = mock_info(
            "user1",
            &[Coin {
                denom: "uDORA".to_string(),
                amount: Uint128::from(160000u128),
            }],
        );

        let sender = info.sender.clone();
        let msg = ExecMsg::IssueAndContribute {
            donation_denom: "uDORA".to_string(),
            amount: Uint128::from(160000u128),
        };
        execute(
            deps.as_mut(),
            env.clone(),
            info.clone(),
            ContractExecMsg::DBContract(msg),
        )
        .unwrap();

        let resp = query(
            deps.as_ref(),
            env.clone(),
            ContractQueryMsg::DBContract(QueryMsg::GetBounty { bounty_id: 0 }),
        )
        .unwrap();
        let resp: Bounty = from_binary(&resp).unwrap();
        assert_eq!(
            resp,
            Bounty {
                issuer: info.sender,
                donation_denom: "uDORA".to_owned(),
                balance: Uint128::from(160000u128),
                paid_out: false,
            }
        );

        // Fulfill Bounty
        let info = mock_info("user1", &[]);
        let msg = ExecMsg::AcceptFulfillment {
            bounty_id: 0,
            fulfillers: vec![info.sender.clone()],
            amounts: vec![Uint128::from(160000u128)],
        };
        execute(
            deps.as_mut(),
            env.clone(),
            info.clone(),
            ContractExecMsg::DBContract(msg),
        )
        .unwrap();
        let resp = query(
            deps.as_ref(),
            env.clone(),
            ContractQueryMsg::DBContract(QueryMsg::GetBounty { bounty_id: 0 }),
        )
        .unwrap();
        let resp: Bounty = from_binary(&resp).unwrap();
        assert_eq!(
            resp,
            Bounty {
                issuer: sender.clone(),
                donation_denom: "uDORA".to_owned(),
                balance: Uint128::from(0u128),
                paid_out: true,
            }
        );
    }
}
