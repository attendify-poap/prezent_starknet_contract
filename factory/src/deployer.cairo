#[contract]


mod PrezentFactory{

use starknet::syscalls::deploy_syscall;
use starknet::contract_address::ContractAddress;
use array::ArrayTrait;
use starknet::get_caller_address;
use starknet::class_hash::ClassHash;
use starknet::class_hash:: class_hash_to_felt252;
use core::hash::LegacyHashFelt252;
use starknet::contract_address::contract_address_to_felt252;
use core::result::Result;



// define class Hash as a constant i.e const class_hash = 0x4fe....
#[external]
fn deploy_factory(class_hash:ClassHash, calldata:Span<felt252>)-> ContractAddress{
let deployer = get_caller_address();
// create a func to generate salt using deployer and class_hash
let salt = LegacyHashFelt252::hash(contract_address_to_felt252(deployer),  class_hash_to_felt252(class_hash));
// return deployed contract address
let result = deploy_syscall(class_hash, salt, calldata,true);

    match result {
    Result::Ok((contract_address, _)) => contract_address,
    Result::Err(err) => panic_with_felt252('failed_to_deploy'),
    }
}

}