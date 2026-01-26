## Flush + Flush

For the proof-of-concept attack implementation targeting the WhatsApp Desktop application, we modified the Prime+Probe attack technique, originally provided by Flush+Flush, to function effectively on macOS. 
Our experiments were conducted on a 2019 MacBook Pro equipped with an Intel Core i7-9750H processor (6 cores, 2.6 GHz) and 16 GB of RAM, running macOS Sonoma Version 14.1.2.
We adjusted the Prime+Probe attack in the <a href="flush_flush/sc/pp">sc/pp</a> directory to monitor the function that generates a new secure session from a shared library named `session_builder_process_pre_key_bundle`.
The code is expected to know the appropriate addresses: one for starting a secure session (session_builder) and another for the instruction triggered when using a one-time pre-key to create the master secret key for that session (OTPK_exists).


### Attack description

The code works for **Prime+Probe Cache Timing Attack** as follows:

1. **Primes:** The attacker accesses specific addresses (session_builder, OTPK_exists) repeatedly, populating those cache sets.
2. **Waits** briefly (via usleep()).
3. **Probes:** The attacker re-accesses the same addresses and measures the response time.
    - If **slow**, they were evicted (i.e., the victim accessed an overlapping set).
    - If **fast**, the cache lines are untouched.

For example, for the following output:

```
[session_builder] Δt =    244: 
[OTPK_exists]     Δt =     98: 

[session_builder] Δt =    345: #
[OTPK_exists]     Δt =    151: 

[session_builder] Δt =    385: #
[OTPK_exists]     Δt =    146: 

[session_builder] Δt =    247: 
[OTPK_exists]     Δt =  21626: ##################################################
```

The OTPK_exists suddenly takes much longer, which suggests that it got evicted, and the victim accessed memory mapping to the same cache set as OTPK_exists.

The steps the attacker performs are as follows:

1. Attacker `mmaps` the application with shared libraries.
2. Chooses addresses that map to known cache sets, in our case `session_builder_process_pre_key_bundle` (session_builder), and the specific branch (OTPK_exists) we are interested in.
3. Fills those sets via repeated access (prime).
4. Waits for the victim to potentially run.
5. Re-measures access latency (probe).
6. Logs and interprets results.


### How to run

Run the <a href="flush_flush/sc/pp/spy.c">spy script</a> like this:

```
cd sc/pp
make
./spy /Applications/WhatsApp.app/Contents/MacOS/WhatsApp 0x1ddeb4b 0x1ddec64 # Adjust with suitable addresses
```

This script exports timing data to a CSV file (timing_log.csv).
 You can then use the Python script <a href="flush_flush/sc/pp/show_result.py">show_result.py</a> to generate a plotted chart with:
- **x-axis**: Time (in microseconds)
- **y-axis**: Measured access latency (Δt)
