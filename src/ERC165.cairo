const IERC165_ID: u32 = 0x01ffc9a7_u32;
const INVALID_ID: u32 = 0xffffffff_u32;

#[contract]
mod ERC165{

    /////////////////////
    // import supports_interface
    ////////////////////
    use prezent_contract_starknet::interface::IERC165;

    ///////////////
    // storage variable
    //////////////
    struct Storage{
    supported_interfaces: LegacyMap::<u32,bool>,
    }


/////////////////////
// implementation of ERC165
////////////////////
impl ERC165Impl of IERC165{
    
        fn supports_interface(interface_id:u32) -> bool{
        
        if interface_id == super::IERC165_ID {
        return true;
        }
        supported_interfaces::read(interface_id)
        }
        
        }

    #[view]
    fn supports_interface(interface_id: u32) -> bool {
        ERC165Impl::supports_interface(interface_id)
    }

    #[internal]
    fn register_interface(interface_id: u32) {
        assert(interface_id != super::INVALID_ID, 'Invalid id');
        supported_interfaces::write(interface_id, true);
    }

    #[internal]
    fn deregister_interface(interface_id: u32) {
        assert(interface_id != super::IERC165_ID, 'Invalid id');
        supported_interfaces::write(interface_id, false);
    }

}