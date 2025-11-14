
#include <string.h>


#define BUFFER_SIZE 256


static void send_nonce(char *output) {

}

static char get_challenge(void) {
}

static void send_mac(char *message, char *key) {

}

static char get_mac(void) {

}

static void send_cipher(char *output) {

}

static char get_cipher(void) {

}

// Encryption and Decryption functions
static void senc(char *val1, char *val2, char *val3, char *val4, char *val5) {

}

static int sdec(char *val1, char *val2, char *val3, char *val4, char *val5) {

}

// MAC function
static char mac(char *message, char *key) {

}

static int compare_mac(char *msg1, char *msg2) {

}

static int compare_nonces(char *n1, char *n2) {

}

// random function
static char get_nonce(void) {
    
}


// Passport Role
int passport(char *k_e, char *k_m) {
    char received_x[BUFFER_SIZE];
    char generated_n_t[BUFFER_SIZE];
    char encrypted_message[BUFFER_SIZE];
    char mac_input[BUFFER_SIZE];
    char calculated_mac[BUFFER_SIZE];
    char xn_r[BUFFER_SIZE];
    char xn_t[BUFFER_SIZE];
    char xk_r[BUFFER_SIZE];
    char k_t[BUFFER_SIZE];
    char response_message[BUFFER_SIZE];
    char response_mac[BUFFER_SIZE];

    // Step 1: Receive the challenge
    *received_x = get_challenge();

    if (strcmp(received_x, "GET_CHALLENGE") == 0) {
        
	// Step 2: Generate n_t
        *generated_n_t = get_nonce();
        send_nonce(generated_n_t);

        // Step 3: Receive encrypted message and MAC
        
        *encrypted_message = get_cipher(); 
        *mac_input = get_mac();      

        // Step 4: Verify the MAC
	
   		*calculated_mac = mac(encrypted_message, k_m);
        	
		if (compare_mac(calculated_mac, mac_input) == 0) {

				if (sdec(encrypted_message, k_e, xn_r, xn_t, xk_r)) {

					if (compare_nonces(xn_t, generated_n_t) == 0) {
					    // Step 7: Generate k_t and send response
					    *k_t = get_nonce();
					    senc(generated_n_t, xn_r, k_t, k_e, response_message);
					    send_mac(response_message, k_m);
					} else {
						return 0;
						} 
			    } else {
				return 0;
				} 
			
		} else {
			return 0;
			} 
	
    }
}



int main() {
    char k_e[BUFFER_SIZE];
    char k_m[BUFFER_SIZE];

    passport(k_e, k_m);

    return 0;
}

