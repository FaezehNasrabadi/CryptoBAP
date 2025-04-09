signature bir_symbexec_PreprocessLib =
sig
    include Abbrev
    
    val fun_address_dict: bir_cfgLib.cfg_node -> term * string
    val fun_addresses_dict:
       (term, term) Redblackmap.dict -> term list -> (term, string) Redblackmap.dict
end
