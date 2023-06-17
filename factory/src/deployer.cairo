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
use array::SpanTrait;
use serde::Serde;
use serde::serialize_array_helper;
use serde::deserialize_array_helper;


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

impl SpanSerde<T, impl TSerde: Serde<T>, impl TDrop: Drop<T>> of Serde<Span<T>> {
    fn serialize(self: @Span<T>, ref output: Array<felt252>) {
        (*self).len().serialize(ref output);
        serialize_array_helper(*self, ref output)
    }

    fn deserialize(ref serialized: Span<felt252>) -> Option<Span<T>> {
        let length = *serialized.pop_front()?;
        let mut arr = ArrayTrait::new();
        Option::Some(deserialize_array_helper(ref serialized, arr, length)?.span())
    }
}

}