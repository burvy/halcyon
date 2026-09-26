# HALCYON
Picked some random word that sounded cool for this fun project

# DESIGN
Try to keep the design concise and sectioned-off. By that, try 
not to have huge blocks of logic, compose functions inside of 
the other functions with descriptive names telling the reader 
what that little block of code does.  

For example, look at the `_physics_process` in [player.gd](scripts/player.gd). 
It just has a bunch of functions that tell you what they handle, like 
`handle_gravity`, `handle_jump`, `handle_motion`, they tell you that every tick, 
this `_physics_process` method handles gravity, jumping, and motion. It also 
becomes quite easy to reach into those functions and tweak logic without getting 
distracted by the other functionality

# NOTES
`_unhandled_input` handles inputs after the normal `_input`, which 
allows these inputs to be stopped prematurely if `_input` needs them 
more. For example, menu interactions. You wouldn't want player camera 
looking to work on the pause menu.

[PLAYER SCRIPT](docs/PLAYER.md)
[ARMS SCRIPT](docs/ARMS.md)
