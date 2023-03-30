package main

import     "core:fmt"
import     "core:os"
import     "core:strconv"
import     "core:time"
import str "core:strings"

TERSE_FORMATS :: "hms"

main :: proc() {
    args := os.args[1:]
    arg_c := len(args)

    if arg_c <= 0 {
        fmt.eprintln("ERROR! : Expected a duration!")
            fmt.println("Examples:")
            fmt.println("5 == minutes")
            fmt.println("10s == 10 seconds")
            fmt.println("30m or 0.5h == 30 minutes")
            fmt.println("1.5m == 1 minute and 30 seconds")
            fmt.println("Formats: h=hour, m=minute, s=second.")
        return
    }

    input_duration := args[0]
    duration_seconds, ok:= create_duration_terse(input_duration)
    if !ok {
        fmt.eprintln("Could not parse terse timer duration. Input should look like \"60s\", \"1m\"")
        return
    }
    do_timer(duration_seconds)
}

create_duration_terse :: proc(user_input : string) -> (time.Duration, bool) {
    // Default to minutes
    terse_duration_format: rune = 'm'
    duration_multiplier: f64 = 0

    if str.contains_any(user_input, TERSE_FORMATS) {
        // If the user tried more than one (for some reason)
        // we just take the first one anyway.
        start := user_input[0]
        end := str.index_any(user_input, TERSE_FORMATS)

        terse_duration_format = rune(user_input[end])
        parsed, parse_success := strconv.parse_f64(str.cut(s=user_input, rune_length=end ))
        if !parse_success {
            fmt.eprintln("Error parsing timer duration!")
            return 0, false
        }

        duration_multiplier = parsed
    }
    else {
        duration_multiplier, _ = strconv.parse_f64(user_input)
    }

    total_duration_seconds : time.Duration

    switch terse_duration_format {
        case 'h':
            total_duration_seconds = time.Duration(time.duration_seconds(time.Hour) * duration_multiplier)
        case 'm':
            total_duration_seconds = time.Duration(time.duration_seconds(time.Minute) * duration_multiplier)
        case 's':
            total_duration_seconds = time.Duration(time.duration_seconds(time.Second) * duration_multiplier)
    }

    return total_duration_seconds, true
}

do_timer :: proc (duration: time.Duration) {
    time_left: u64 = u64(duration)
    h,m,s := time.clock_from_seconds(time_left)
    fmt.println()
    fmt.printf("Setting timer: %vh, %vm, %vs\n", h, m, s)
    fmt.printf("Timer starting @ current time: %v\n", time.now())

    for {
        if time_left <= 0 {
           break 
        }
        h,m,s = time.clock_from_seconds(time_left)    
        fmt.printf("%vh %vm %vs left\r", h, m, s )
        time.sleep(time.Second)
        time_left -= 1
    }

    fmt.println("=====================================")
    fmt.printf("\a")
    fmt.printf("Time's up! @ current time: %v\n", time.now())
    fmt.println()
}