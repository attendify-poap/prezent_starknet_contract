const IERC165_ID: u32 = 0x01ffc9a7_u32;
const INVALID_ID: u32 = 0xffffffff_u32;
const IERC721_ID: u32 = 0x80ac58cd_u32;
const IERC721_METADATA_ID: u32 = 0x5b5e139f_u32;


// note: contract did not implement some functionalities such as transfer, approve as token is meant to be soulbound.

#[contract]
mod ERC721{


    /////////////////////
    // Module Imports
    ///////////////////
    use prezent_contract_starknet::interface::IERC721;

    ////////////////////
    // Others
    ///////////////////
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use zeroable::Zeroable;
    use option::OptionTrait;
    use array::SpanTrait;
    use traits::Into;

    ////////////////////
    // state variables
    //////////////////
    struct Storage{
    _name:felt252,
    _symbol:felt252,
    _creator:ContractAddress,
    _event_uri: felt252,
    _owners: LegacyMap::<u256, ContractAddress>,
    _balances: LegacyMap::<ContractAddress, u256>,
    _tokenId:u256,
    _hasClaimed:LegacyMap::<ContractAddress, bool>,
    _token_uri: LegacyMap::<u256, felt252>,
    _current_prezent_amount:u256,
    _prezent_mint_limit:u256,
    _supported_interfaces:LegacyMap<u32,bool>,
    }

   #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {}

    /////////////////////
    // IERC721 implementation
    ////////////////////
    impl ERC721Impl of IERC721{
        fn name() -> felt252{
        return _name::read();
        }

        fn symbol() -> felt252{
        return _symbol::read();
        }

        fn token_uri(token_id:u256) -> felt252{
        assert(_exists(token_id), 'ERC721:invalid token ID');
        return _token_uri::read(token_id);
        }
        
        fn balance_of(account:ContractAddress) -> u256{
        assert(!account.is_zero(), 'ERC721:invalid account');
       return _balances::read(account);
        }

         fn owner_of(token_id: u256) -> ContractAddress {
         return   _owner_of(token_id);
        }


    }


    ////////////////
    // initialize contract state
    //////////////
     #[constructor]
    fn constructor(name: felt252, symbol: felt252, event_uri:felt252, creator:ContractAddress, _prezent_mint_limit:u256) {
        initializer(name, symbol, event_uri, creator, _prezent_mint_limit);
    }


    ////////////////////
    // view functions
    ///////////////////

    #[view]
    fn eventUri() -> felt252{
   return  _event_uri::read();
    }

    #[view]

    fn creator() -> ContractAddress{
    return _creator::read();
    }

    #[view]
    fn get_prezent_amount() -> u256{
    return  _current_prezent_amount::read();
    }

    #[view]

    fn get_prezent_limit() -> u256{
    return _prezent_mint_limit::read();
    }

    #[view]

    fn supports_interface(interface_id:u32) -> bool{
    return _supported_interfaces::read(interface_id);
    }

    #[view]
    fn name() -> felt252 {
    return    ERC721Impl::name();
    }

    #[view]
    fn symbol() -> felt252 {
    return    ERC721Impl::symbol();
    }

    
    #[view]
    fn token_uri(token_id: u256) -> felt252 {
      return  ERC721Impl::token_uri(token_id);
    }

    

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
      return  ERC721Impl::balance_of(account);
    }

    

    #[view]
    fn owner_of(token_id: u256) -> ContractAddress {
     return   ERC721Impl::owner_of(token_id);
    }

    ////////////////////////
    //internal function
    ///////////////////////
    #[internal]
    fn _exists(token_id: u256) -> bool {
     !_owners::read(token_id).is_zero()
     }

     #[internal]
    fn initializer(name_: felt252, symbol_: felt252, event_uri_:felt252,creator_:ContractAddress, prezent_mint_limit:u256) {
        let caller = get_caller_address();
        _name::write(name_);
        _symbol::write(symbol_);
        _event_uri::write(event_uri_);
        _creator::write(caller);
        _prezent_mint_limit::write(prezent_mint_limit);
        register_interface(super::IERC721_ID);
        register_interface(super::IERC721_METADATA_ID);
    }

     #[internal]
    fn _owner_of(token_id: u256) -> ContractAddress {
        let owner = _owners::read(token_id);
        match owner.is_zero() {
            bool::False(()) => owner,
            bool::True(()) => panic_with_felt252('ERC721: invalid token ID')
        }
    }

    #[internal]
    fn _mint(to: ContractAddress, token_id: u256) {
        assert(!to.is_zero(), 'ERC721: invalid receiver');
        assert(!_exists(token_id), 'ERC721: token already minted');

        // Update balances
        _balances::write(to, _balances::read(to) + 1.into());

        // Update token_id owner
        _owners::write(token_id, to);

        // Emit event
        Transfer(Zeroable::zero(), to, token_id);
    }

    #[internal]
    fn _safe_mint(to: ContractAddress, token_id:u256) {
        _mint(to, token_id);
    }

    #[internal]
    fn _set_token_uri(token_id: u256, token_uri: felt252) {
        assert(_exists(token_id), 'ERC721: invalid token ID');
        _token_uri::write(token_id, token_uri)
    }

    #[internal]
    fn register_interface(interface_id: u32) {
        assert(interface_id != super::INVALID_ID, 'Invalid id');
        _supported_interfaces::write(interface_id, true);
    }

    #[internal]
    fn deregister_interface(interface_id: u32) {
        assert(interface_id != super::IERC165_ID, 'Invalid id');
        _supported_interfaces::write(interface_id, false);
    }

    #[external]
    fn safemint(to: ContractAddress) {
    assert(_current_prezent_amount::read() <= _prezent_mint_limit::read(), 'ERC721: Mint limit reached');
    let prev_prezent_amount:u256 = _current_prezent_amount::read();
    let prevTokenId:u256 = _tokenId::read();
    let token_id:u256 = prevTokenId + 1.into();
    let token_uri = _token_uri::read(token_id);
    let latest_prezent_amount:u256 = prev_prezent_amount + 1.into();
        _safe_mint(to, token_id);
        _set_token_uri(token_id, token_uri);
        _tokenId::write(token_id);
        _current_prezent_amount::write(latest_prezent_amount);
    }

    #[external]
    fn claimPrezent(){
    let msgSender = get_caller_address();
    assert(!msgSender.is_zero(), 'CALLER_ZERO_ADDRESS');
    assert(_hasClaimed::read(msgSender) == false, 'ALREADY CLAIM');
    safemint(msgSender);
    _hasClaimed::write(msgSender, true);
    }





}