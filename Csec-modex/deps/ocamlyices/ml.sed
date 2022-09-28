/^and yicesl\?_\(log_file_\|output_file_\)\?error/ d
/^and srec_p/ d
/^and\s\+yices_type_ptr = yices_type$/ d
s/yices_type_ptr/yices_type/g 
s/ yices_type/ typ/g
s/srec_p/string/g
s/\([ (.]\)yicesl\?_/\1/g
