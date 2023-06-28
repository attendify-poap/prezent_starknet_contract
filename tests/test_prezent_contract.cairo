use erc721::contracts::token;
use factory::deployer::PrezentFactory;
use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;
use starknet::contract_address_const;
use traits::Into;

const name:felt252 = 'WEB3';
const symbol:felt252 = 'W3C';
const event_uri:felt252 = 'hello';

const account:felt252 = 1113455678;
const user:felt252 = 11111145;
const user2:felt252 = 11112234;

////////////////
// Factory parameter 
///////////////
const name_deploy:felt252 = 'WEB2';
const symbol_deploy:felt252 = 'W2C';
const event_uri_deploy:felt252 = 'hello_word';
const user3:felt252 = 11112236;
///////////////////////////////

fn __set__up() -> felt252{
let mut calldata = ArrayTrait::new();
let mint_limit = u256 {low: 5, high: 0};
calldata.append(name);
calldata.append(symbol);
calldata.append(event_uri);
calldata.append(account);
calldata.append(mint_limit.high.into());
calldata.append(mint_limit.low.into());
// return deploy address
let address = deploy_contract('token', @calldata).unwrap();

address
}



#[test]
    fn test_constructor_value(){
    let deployed_contract_address = __set__up();
    let retdata_name = call(deployed_contract_address, 'name', @ArrayTrait::new()).unwrap();
    let retdata_symbol = call(deployed_contract_address, 'symbol', @ArrayTrait::new()).unwrap();
    let retdata_event_uri = call(deployed_contract_address, 'eventUri', @ArrayTrait::new()).unwrap();
    let retdata_creator = call(deployed_contract_address, 'creator', @ArrayTrait::new()).unwrap();
    let retdata_prezent_limit = call(deployed_contract_address, 'get_prezent_limit', @ArrayTrait::new()).unwrap();
    assert(*retdata_name.at(0_u32) == 'WEB3', 'incorrect name');
    assert(*retdata_symbol.at(0_u32) == 'W3C', 'incorrect symbol');
    assert(*retdata_event_uri.at(0_u32) == 'hello', 'incorrect uri');
    // assert(*retdata_prezent_limit.at(0_u32) == 5.into(), 'incorrect prezent_limit');
    
    }

    #[test]
    fn test_mint(){
    //bring set_up into scope
    let deployed_contract_address = __set__up();

    //declare two variable (mint, account)
    // call mint_func
    let mut mint = ArrayTrait::new();
    // call balance_of func
    let mut balance = ArrayTrait::new();

    mint.append(user);
    balance.append(user);
    invoke(deployed_contract_address, 'claimPrezent', @mint).unwrap();
    let retdata_balance = call(deployed_contract_address, 'balance_of', @balance).unwrap();
    assert(*retdata_balance.at(0_u32) == 1, 'invalid_balance');

    let mut mint2 = ArrayTrait::new();
    // call balance_of func
    let mut balance2 = ArrayTrait::new();


    mint2.append(user2);
    balance2.append(user2);
    invoke(deployed_contract_address, 'claimPrezent', @mint2).unwrap();
    let retdata_balance2 = call(deployed_contract_address, 'balance_of', @balance2).unwrap();
    assert(*retdata_balance2.at(0_u32) == 1, 'invalid_balance');

    let retdata = call(deployed_contract_address, 'get_prezent_amount', @ArrayTrait::new()).unwrap();
    assert(*retdata.at(0_u32) == 2, 'invalid prezent amount');
    }


fn setup_declare() -> felt252{
let class_hash = declare('deployer').unwrap();
 class_hash
}

#[test]
fn test_factory_deploy() {
let class_hash = setup_declare();
let mut calldata = ArrayTrait::new();
let mint_limit = u256 {high: 5, low: 0};
calldata.append(name_deploy);
calldata.append(symbol_deploy);
calldata.append(event_uri_deploy);
calldata.append(user3);
calldata.append(mint_limit.high.into());
calldata.append(mint_limit.low.into());


let prepare_contract = prepare(class_hash, @calldata).unwrap();

assert(prepare_contract.contract_address !=0, 'prepared contract_address != 0');

let deployed_contract_address = deploy(prepare_contract).unwrap();

assert(deployed_contract_address != 0, 'failed to deploy');

}