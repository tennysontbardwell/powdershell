Notes from Design Meeting 11/14/16
==================================

lambda term! how to use it? what features does it have?

Tennyson showed Taylor how the gameloop works using Figure 2 of the design doc

Dependency diagram is a bit weird, updater depends on main and GUI depends on main

JK not that - main is sort of like a REPL and there is just a flow of data from data to main

GUI is the only thing that interfaces with Lambda term

Why are save.json and rules.json different?
- could have them separate or the same

To expand it we can make rules.json more robust right now

Maybe have the particle types be a variant?
- but actually no cus rules.json

Keep dependencies low 
- reduce the responsibility of main and keep it in GUI and updater
- runtime flow of info looks good (more like MVC)
- why hashtable? make sure you abstract it behind a module