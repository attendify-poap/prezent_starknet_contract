use prezent_contract_starknet::contracts::erc721::ERC721;
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;
use starknet::contract_address_const;


const name:felt252 = 'Web3Lagos';
const symbol:felt252 = 'W3B';
const event_uri:felt252 = 'web3bridge';
const prezent_mint_limit:felt252 = 5;


    fn set_up() -> felt252{
    // declare an array to pass in constructor data
    let mut constructor_calldata = ArrayTrait::new();
    let account = contract_address_const::<1>();
    set_caller_address(account);
    // append constructor data
    constructor_calldata.append(name);
    constructor_calldata.append(symbol);
    constructor_calldata.append(event_uri);
    constructor_calldata.append(account);
    constructor_calldata.append(prezent_mint_limit);
    // declare contract
    let class_hash = declare('ERC721');
    // prepare contract
    let prepared = prepare(class_hash, @constructor_calldata).unwrap();
    // deploy contract
    let deployed_contract_address = deploy(prepared).unwrap();
    // return address
    return deployed_contract_address;
    }


    #[test]

    fn test_name(){
    let deployed_contract_address = set_up();

    let retdata = call(deployed_contract_address, 'name', @ArrayTrait::new()).unwrap();

    assert(*retdata.at(0_u32) == 'Web3Lagos', 'incorrect name');
    }