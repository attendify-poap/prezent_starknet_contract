use starknet::ContractAddress;


////////////////////////
// IERC721 interface
///////////////////////
#[abi]
trait IERC721{
fn name() -> felt252;
fn symbol() -> felt252;
fn token_uri(token_id:u256) -> felt252;
fn balance_of(account:ContractAddress) ->u256;
fn owner_of(token_id:u256) -> ContractAddress;

}
