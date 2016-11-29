type clock_t = {
    speed : float; 
    hist : float Queue.t;
    startt : float;
    endt : float;
}

let (new_clk : clock_t) = 
    {
        speed = 0.05; 
        hist = Queue.create (); 
        startt = Unix.time (); 
        endt = Unix.time ();
    }

let set_start clk = {clk with startt = Unix.time ()}

let end_calc oclk = 
    Queue.push oclk.speed oclk.hist;
    if Queue.length oclk.hist > 5 then ignore (Queue.pop oclk.hist);
    let clk = {oclk with endt = Unix.time ()} in
    let t_diff = clk.endt -. clk.startt in
    if t_diff <= clk.speed && clk.speed >= 0.05 then
        {clk with speed = (if t_diff < 0.05 then 0.05 else t_diff)}
    else let avg_clk = (Queue.fold (fun a x -> x +. a) 0. clk.hist +. t_diff) /. 6. in
        let hist_gt = Queue.fold (fun a x -> if x > clk.speed then a +. 1. else a)
                      0. clk.hist in
        {clk with speed = (clk.speed +. ((sqrt hist_gt) *. (t_diff -. clk.speed)))}
(* (clk.speed +. ((sqrt hist_gt) *. (avg_clk -. clk.speed))) *)
let get_speed clk = clk.speed