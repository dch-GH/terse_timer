package main

import     "core:fmt"
import     "core:os"
import     "core:strconv"
import     "core:time"
import str "core:strings"

TERSE_FORMATS :: "dhms"

Timer :: struct {
    seconds: f64,
    format: rune,
}

main :: proc() {
    args := os.args[1:]
    arg_c := len(args)

    if arg_c <= 0 {
        fmt.eprintln("ERROR! : Expected a duration!")
            fmt.println("Examples:")
            fmt.println("\"timer.exe 10s\"  == 10 seconds")
            fmt.println("\"timer.exe 30m\"  == 30 minutes")
            fmt.println("\"timer.exe 1:20\" == 1 minute and 20 seconds")
            fmt.println("\"timer.exe 2:30h\" == 2 and a half hours")
            fmt.println("Formats: h=hour, m=minute, s=second.")
        return
    }

    input_duration := args[0]
    if str.contains(input_duration, ":") {
        could_parse := parse_timer_verbose(input_duration)
        if !could_parse {
            fmt.eprintln("Could not parse timer duration in minutes!\nInput should look like: 1:30 or 1.5m")
            return
        }
    }
    else {
        timer_maybe := create_duration_terse(input_duration)
        timer, ok := timer_maybe.?
        if !ok {
            fmt.eprintln("Could not parse terse timer duration. Input should look like \"60s\", \"1m\"")
            return
        }
        do_timer(timer)
    }
}

create_duration_terse :: proc(user_input : string) -> Maybe(Timer) {
    if !str.contains_any(user_input, TERSE_FORMATS) {
        return nil
    }

    start := user_input[0]
    end := str.index_any(user_input, TERSE_FORMATS)

    duration_multiplier, parse_success := strconv.parse_f64(str.cut(s=user_input, rune_length=end ))
    if !parse_success {
        fmt.eprintln("Error parsing terse timer duration!")
        return nil
    }

    // If the user tried more than one (for some reason)
    // we just take the first one anyway.
    terse_duration_format := rune(user_input[end])
    fmt.println(duration_multiplier, terse_duration_format)
    total_duration_seconds : f64
    
    switch terse_duration_format {
        case 'd': 
            total_duration_seconds = time.duration_seconds(time.Hour * 24) * duration_multiplier
        case 'h':
            total_duration_seconds = time.duration_seconds(time.Hour) * duration_multiplier
        case 'm':
            total_duration_seconds = time.duration_seconds(time.Minute) * duration_multiplier
        case 's':
            total_duration_seconds = time.duration_seconds(time.Second) * duration_multiplier
    }

    fmt.printf("created duration : %v\n", total_duration_seconds)
    t : Timer
    t.seconds = total_duration_seconds
    t.format = terse_duration_format
    return t
}

parse_timer_verbose :: proc(user_input: string) -> bool {
    if len(user_input) > 4 {
        return false
    }
    return true
}

do_timer :: proc (timer: Timer) {
    using timer
    fmt.printf("Setting timer for {:v} {:v}\n", seconds, format)
    time_left := seconds
    formatted_time : string
    for {
        fmt.printf("%v %v\n", time_left, format)
        time.sleep(time.Second)
        time_left -= 1
        if time_left < 0 {
           break 
        }
    }

    fmt.printf("\a")
    fmt.println("Time's up!")
}
