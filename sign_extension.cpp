int twos_comp_to_int(word x, unsigned int n_bits) {
	/* convert the number x, given in its two's complement representation, into its value */
 	int sign = (x>>(n_bits-1));
 	if (sign == 0) {
 		// x was positive => equals to its 2comp value
 		return x;
 	} else {
 		return (x - (1<<n_bits));
 	}
}


word int_to_twos_comp(word x, unsigned int n_bits) {
    /* converts x into its two's complement representation on n bits */
    if (x>0) {
        return x;
    } else {
    	return (1<<n_bits) + x;
    }
}


word sign_extension_twos_comp(word x, int n_bits, int n_extend) {
	/*given an integer x in two's complement representation on n_bits, 
	extends its representation to an n_extend bits one */
	word y = twos_comp_to_int(x,n_bits);
    return int_to_twos_comp(y,n_extend);
}



word value_function_of_bit11(word bit11, word j, word * reg) {
    /* returns j or r[j] in function of bit value */
        if (bit11 == 0) {
            return reg[j];
        } else {
            return j;
        }
}