type clock_t = {
    wait : float;
    speed : float; 
    hist : float Queue.t;
    startt : float;
    endt : float;
}

let new_clk : clock_t = 
    {
        wait = 0.0;
        speed = 0.05; 
        hist = Queue.create (); 
        startt = Unix.gettimeofday(); 
        endt = Unix.gettimeofday();
    }

let set_start clk = {clk with startt = Unix.gettimeofday()}

let constrain a l h = if a < l then l else if a > h then h else a

let end_calc oclk = 
    if Queue.length oclk.hist > 9 then ignore (Queue.pop oclk.hist);
    let clk = {oclk with endt = Unix.gettimeofday()} in
    let t_diff = clk.endt -. clk.startt in
    Queue.push t_diff oclk.hist;
    let avg_clk = (Queue.fold (fun a x -> x +. a) 0. clk.hist 
        +. t_diff) /. 11. in
    let hist_gt = Queue.fold (fun a x -> if x > clk.speed then a +. 0.02 else a) 
        0. clk.hist in
    if t_diff <= clk.speed && clk.speed >= 0.05 then
        let avg = (t_diff +. clk.speed) /. 2. in
        let nspeed = if avg < 0.05 then 0.05 else avg in
        let nspeed = (constrain nspeed 0.05 5.) in
        {clk with speed = nspeed; wait = (nspeed)}
    else 
        let nspeed = t_diff +. (hist_gt *. (avg_clk -. clk.speed)) in
        let nspeed = (constrain nspeed 0.05 5.) in
        {clk with speed = nspeed; wait = (nspeed)}

let get_block clk = clk.wait

let get_start clk = clk.startt