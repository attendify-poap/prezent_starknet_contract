use starknet::ContractAddress;

const IERC721_ID: u32 = 0x80ac58cd_u32;
const IERC721_METADATA_ID: u32 = 0x5b5e139f_u32;
const IERC721_RECEIVER_ID: u32 = 0x150b7a02_u32;

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

///////////////////////
// IERC721Receiver interfcae
//////////////////////

#[abi]
trait IERC721Receiver {
    fn on_erc721_received(
        operator: ContractAddress, from: ContractAddress, token_id: u256, data: Span<felt252>
    ) -> u32;
}

/////////////////
// supports_interface_id
////////////////
#[abi]
trait IERC165{
fn supports_interface(interface_id:u32)-> bool;
}