data modify storage triangles:temp Pos set from entity @s Pos
execute store result storage triangles:temp pos0.x float 0.01 run scoreboard players operation player.x triangles.temp = @s triangles.player.x
execute store result storage triangles:temp pos0.z float 0.01 run scoreboard players operation player.z triangles.temp = @s triangles.player.z
execute store result storage triangles:temp pos1.x float 0.01 run execute store result score @s triangles.player.x run data get storage triangles:temp Pos[0] 100
execute store result storage triangles:temp pos1.z float 0.01 run execute store result score @s triangles.player.z run data get storage triangles:temp Pos[2] 100

# vel.xz = pos1.xz - pos0.xz
data modify storage triangles:temp vel.x set compute default float {type:sub,left:{type:storage,storage:"triangles:temp",path:"pos1.x"},right:{type:storage,storage:"triangles:temp",path:"pos0.x"}}
data modify storage triangles:temp vel.z set compute default float {type:sub,left:{type:storage,storage:"triangles:temp",path:"pos1.z"},right:{type:storage,storage:"triangles:temp",path:"pos0.z"}}

# speed = length(vel.xz) / length([vel.x/sqrt(3), vel.z])
data modify storage triangles:temp speed set compute default float {type:sub,right:1,left:{type:div,left:{type:"length",inputs:[\
    {type:storage,storage:"triangles:temp",path:"vel.x"},\
    {type:storage,storage:"triangles:temp",path:"vel.z"},\
]},\
    right:{type:"length",inputs:[\
    {type:mul,inputs:[{type:storage,storage:"triangles:temp",path:"vel.x"},0.5773502691896257]},\
    {type:storage,storage:"triangles:temp",path:"vel.z"},\
]}\
}}

function triangles:apply_speed with storage triangles:temp

data modify storage triangles:temp rot set from entity @s Rotation

data modify storage triangles:temp rot_factor set compute default float {type:sub,right:1,left:{type:div,left:1,right:{type:length,inputs:[\
    {type:mul,inputs:[\
        0.5773502691896257,\
        {type:sin,input:{type:mul,inputs:[\
            0.017453292519943295,{type:storage,storage:"triangles:temp",path:"rot[0]"}\
        ]}},\
        {type:cos,input:{type:mul,inputs:[0.017453292519943295,{type:storage,storage:"triangles:temp",path:"rot[1]"}]}}\
    ]},\
    {type:sin,input:{type:mul,inputs:[\
        0.017453292519943295,{type:storage,storage:"triangles:temp",path:"rot[1]"}\
    ]}},\
    {type:mul,inputs:[\
        {type:cos,input:{type:mul,inputs:[\
            0.017453292519943295,{type:storage,storage:"triangles:temp",path:"rot[0]"}\
        ]}},\
        {type:cos,input:{type:mul,inputs:[0.017453292519943295,{type:storage,storage:"triangles:temp",path:"rot[1]"}]}}\
    ]}\
]}}}

function triangles:apply_rot_factor with storage triangles:temp
