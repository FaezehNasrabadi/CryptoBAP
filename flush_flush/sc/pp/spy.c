#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <mach/mach_time.h>
#include <string.h>
#include <sched.h>
#include <time.h>

FILE* logfile = NULL;

uint64_t rdtsc() {
    return mach_absolute_time();
}

#define maccess(p) (*(volatile unsigned char *)(p))

uint64_t timed_read(volatile void* addr) {
    uint64_t start = rdtsc();
    maccess(addr);
    return rdtsc() - start;
}

// Global time counter (samples since start)
uint64_t sample_index = 0;
uint64_t start_time = 0;

// Get time in microseconds since start
uint64_t current_us() {
    return (mach_absolute_time() - start_time) / 1000;
}

void print_csv(uint64_t delta, const char* label) {
    if (logfile) {
        fprintf(logfile, "%llu,%s,%llu,%llu\n", sample_index, label, current_us(), delta);
        fflush(logfile); // ensure it writes immediately
    }
}

int main(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <file> <offset1_hex> <offset2_hex>\n", argv[0]);
        return 1;
    }

    const char* filename = argv[1];
    unsigned int offset1 = 0, offset2 = 0;
    sscanf(argv[2], "%x", &offset1);
    sscanf(argv[3], "%x", &offset2);

    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("open");
        return 2;
    }

    unsigned char* base = mmap(NULL, 64 * 1024 * 1024,
                               PROT_READ | PROT_WRITE,
                               MAP_PRIVATE | MAP_ANON, -1, 0);
    if (base == MAP_FAILED) {
        perror("mmap");
        return 3;
    }

    volatile unsigned char* addr1 = base + offset1;
    volatile unsigned char* addr2 = base + offset2;

    // Warm-up access
    maccess(addr1);
    maccess(addr2);

    printf("Monitoring offset 0x%x and 0x%x...\n", offset1, offset2);
    printf("Press Ctrl+C to stop.\n\n");
    
    start_time = mach_absolute_time();
    logfile = fopen("timing_log.csv", "w");
    if (!logfile) {
        perror("fopen");
        return 4;
    }
    // Write CSV header
    fprintf(logfile, "sample,label,timestamp_us,delta\n");

    while (1) {
        uint64_t delta1 = timed_read(addr1);
        uint64_t delta2 = timed_read(addr2);

        print_csv(delta1, "session_builder");
        print_csv(delta2, "OTPK_exists");
        sample_index++;
        
        sched_yield(); // yield to reduce CPU pressure
        usleep(10000); // 10ms pause between samples
    }

    fclose(logfile);

    return 0;
}

