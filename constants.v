// game object constants
parameter pig_size = 50;    // Piggy's width and length...Poor Piggy is a square!
parameter snack_size = 60;
parameter vegetable_size = 60;
parameter trail_width = 50; //initial trail width and length
parameter move = 50; //consider making this 32 along with trail_width
parameter growth = 8;
parameter shrink = 32;
parameter trail_points = 30;//number of possible points stored in a trail array
parameter array_size = 120; ///always 10*trail_points
parameter bit_width = 4;

// boundary constraint
parameter edge_length = 5;  // the amount of pixels we need to move the top left corner inward
parameter minX = edge_length;   // the farthest left an obj can go
parameter minY = edge_length;   // the farthest up an obj can go
parameter maxX = 639;           // the farthest right an obj can go
parameter maxY = 479;           // the farthest down an obj can go

// initial values
parameter startX = 300; //used to be 235
parameter startY = 250; //used to be 315
parameter startX_trail = 6;
parameter startY_trail = 5;