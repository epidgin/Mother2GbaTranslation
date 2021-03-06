//==============================================================================
// int get_tile_number(int x, int y)
//    In:
//        r0: x
//        r1: y
//    Out:
//        r0: tile number
//==============================================================================

get_tile_number:

push    {r1-r5,lr}
ldr     r4,=m2_coord_table
sub     r0,r0,1
sub     r1,r1,1
lsl     r2,r1,0x1F
lsr     r2,r2,0x1F
lsr     r1,r1,1
lsl     r5,r1,4
sub     r5,r5,r1
sub     r5,r5,r1
lsl     r5,r5,2
lsl     r0,r0,1
add     r4,r4,r0
add     r4,r4,r5
ldrh    r0,[r4,0]
lsl     r2,r2,5
add     r0,r0,r2
pop     {r1-r5,pc}
.pool


//==============================================================================
// void weld_entry(WINDOW* window, byte* chr)
//    In:
//        r0: address of window data
//        r1: address of char to print
//==============================================================================

//--------------------------------
weld_entry:
push    {r0-r5,lr}

// Check for valid character value
mov     r4,r0
ldrb    r0,[r1,0]
sub     r0,0x50
bpl     @@next
mov     r0,0x1F
b       @@valid

@@next:
cmp     r0,0x60
bcc     @@valid
cmp     r0,0x64
bcc     @@invalid
cmp     r0,0x6D
bcs     @@invalid
b       @@valid

@@invalid:
mov     r0,0x1F

@@valid:

// Calculate X coord
ldrh    r1,[r4,0x22]  // window_X
mov     r5,r1
ldrh    r2,[r4,0x2A]  // text_X
add     r1,r1,r2
lsl     r1,r1,3
ldrh    r2,[r4,2]     // pixel_X
add     r1,r1,r2      // screen pixel X

// Calculate Y coord
ldrh    r2,[r4,0x24]  // window_Y
ldrh    r3,[r4,0x2C]  // text_Y
add     r2,r2,r3
lsl     r2,r2,3

// Print
mov     r3,0          // font
bl      print_character

// Store new X coords
add     r0,r0,r1      // new screen pixel_X
lsr     r1,r0,3
sub     r1,r1,r5      // new text_X
strh    r1,[r4,0x2A]
lsl     r0,r0,29
lsr     r0,r0,29      // new pixel_X
strh    r0,[r4,2]

pop     {r0-r5,pc}


//=============================================================================
// void print_string(char* str, int x, int y)
// In:
//    r0: address of string to print
//    r1: x (pixel)
//    r2: y (pixel)
// Out:
//    r0: number of characters printed
//    r1: number of pixels printed
//=============================================================================

print_string:
push    {r2-r6,lr}

mov     r3,0
mov     r5,r3
mov     r6,r1
mov     r4,r0
@@prev:
ldrb    r0,[r4,1]
cmp     r0,0xFF
beq     @@end
ldrb    r0,[r4,0]
sub     r0,0x50
bl      print_character
add     r1,r0,r1
add     r4,1
add     r5,1
b       @@prev

@@end:
mov     r0,r5
sub     r1,r1,r6
pop     {r2-r6,pc}


//=============================================================================
// void print_string_hlight_pixels(WINDOW* window, char* str, int x,
//                                       int y, bool highlight)
// In:
//    r0: window
//    r1: address of string to print
//    r2: x (pixel)
//    r3: y (pixel)
//    sp: highlight
// Out:
//    r0: number of characters printed
//    r1: number of pixels printed
//=============================================================================

print_string_hlight_pixels:
// Copied from C96F0
// Basically it's the exact same subroutine, only in pixels instead of tiles
push    {r4-r7,lr}
mov     r7,r8
push    {r7}
mov     r6,r1
ldr     r1,[sp,0x18]
lsl     r1,r1,0x10
mov     r7,0
ldr     r5,=0x3005228
ldrh    r4,[r5,0]
lsl     r4,r4,0x10
asr     r4,r4,0x1C
mov     r8,r4
lsr     r4,r1,0x10
mov     r12,r4
asr     r1,r1,0x10
add     r1,r8
lsl     r1,r1,0xC
strh    r1,[r5,0]
ldrh    r1,[r0,0x22]
lsl     r1,r1,3
add     r1,r1,r2
ldrh    r2,[r0,0x24]
lsl     r2,r2,3
add     r2,r2,r3
mov     r0,r6
bl      print_string
mov     r7,r0
ldrh    r0,[r5,0]
lsl     r0,r0,0x10
asr     r0,r0,0x1C
mov     r4,r12
lsl     r3,r4,0x10
asr     r3,r3,0x10
sub     r0,r0,r3
lsl     r0,r0,0xC
strh    r0,[r5,0]
lsl     r0,r7,0x10
asr     r0,r0,0x10
pop     {r3}
mov     r8,r3
pop     {r4-r7}
pop     {r2}
bx      r2
.pool


//=============================================================================
// void print_character(int x, int y, int chr, int font)
// In:
//    r0: character
//    r1: x (pixel)
//    r2: y (pixel)
//    r3: font
//        0: main
//        1: saturn
//        2: tiny
// Out:
//    r0: virtual width
//=============================================================================

print_character:

push    {r1-r7,lr}
mov     r4,r8
mov     r5,r9
mov     r6,r10
mov     r7,r11
push    {r4-r7}
mov     r4,r12
push    {r4}
add     sp,-24

mov     r10,r1
mov     r11,r2
mov     r12,r0
mov     r5,r3

//----------------------------------------
ldr     r3,=0x30051EC
ldrh    r4,[r3,0]           // Tile offset
add     r3,0x3C
ldrh    r6,[r3,0]           // Palette mask
add     r3,0x48
ldr     r7,[r3,0]           // Tilemap address
lsr     r1,r1,3
lsr     r2,r2,3
lsl     r2,r2,5
add     r1,r1,r2
lsl     r1,r1,1
add     r7,r7,r1            // Local tilemap address
mov     r8,r4

//----------------------------------------
// Check for "YOU WON!" graphics
cmp     r0,0x64
bcc     @@next2
cmp     r0,0x6D
bcs     @@next2

// Copy pixel data from the fixed YOU WON! graphic in VRAM
add     r0,0xF0              // tile number
add     r0,r0,r4             // tile number with offset
ldr     r3,=0x6000000
lsl     r0,r0,5
add     r2,r0,r3             // VRAM address of YOU WON! graphic
mov     r0,r10
mov     r1,r11
lsr     r0,r0,3
lsr     r1,r1,3
bl      get_tile_number      // get dest tile number
add     r0,r0,r4
orr     r6,r0
strh    r6,[r7]              // update tilemap
add     r6,0x20
add     r7,0x40
strh    r6,[r7]
lsl     r0,r0,5
add     r1,r0,r3             // dest VRAM address
mov     r0,r2
mov     r2,8
mov     r4,r0
mov     r5,r1
swi     0xC
ldr     r3,=0x3E0
add     r0,r0,r3
add     r1,r1,r3
swi     0xC

// End (return 8 as the width)
mov     r0,8
mov     r9,r0
b       @@end

@@next2:
//----------------------------------------
ldr     r0,=m2_widths_table
lsl     r1,r5,2             // Font number * 4
ldr     r0,[r0,r1]
mov     r3,r12               // Character
lsl     r2,r3,1
ldrb    r1,[r0,r2]           // Virtual width
mov     r9,r1
add     r2,r2,1
ldrb    r0,[r0,r2]           // Render width
cmp     r0,0
beq     @@end                    // Don't bother rendering a zero-width character
ldr     r2,=m2_height_table
ldrb    r2,[r2,r5]
str     r2,[sp,16]          // No more registers, gotta store this on the stack
mov     r3,sp
strb    r0,[r3,9]
strb    r2,[r3,12]
mov     r1,r10
lsl     r1,r1,29
lsr     r1,r1,29
strb    r1,[r3,8]
mov     r1,4
strb    r1,[r3,10]
mov     r1,0xF
strb    r1,[r3,11]

//----------------------------------------
mov     r0,r10
mov     r1,r11
lsr     r0,r0,3
lsr     r1,r1,3
bl      get_tile_number
add     r4,r0,r4
lsl     r0,r4,5
mov     r1,6
lsl     r1,r1,0x18
add     r0,r0,r1             // VRAM address
str     r0,[sp,0]

//----------------------------------------
ldr     r0,=m2_font_table
lsl     r1,r5,2
ldr     r0,[r0,r1]
mov     r1,r12
lsl     r1,r1,5
add     r0,r0,r1             // Glyph address
str     r0,[sp,4]

//----------------------------------------
// Render left portion
mov     r0,sp
bl      print_left

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
@@prev2:
strh    r4,[r1,0]
add     r4,0x20
add     r1,0x40
sub     r2,r2,1
bne     @@prev2
add     r7,r7,2

//----------------------------------------
// Now we've rendered the left portion;
// we need to determine whether or not to render the right portion
ldrb    r1,[r0,8]           // VRAM x offset
str     r1,[sp,20]          // No more registers, gotta store this on the stack
ldrb    r2,[r0,9]           // Render width
add     r2,r1,r2
cmp     r2,8
bls     @@end

// We still have more to render; figure out how much we already rendered
mov     r3,8
sub     r3,r3,r1
strb    r3,[r0,8]

// Allocate a new tile
mov     r0,r10
mov     r1,r11
lsr     r0,r0,3
add     r0,r0,1
lsr     r1,r1,3
bl      get_tile_number
add     r0,r8
mov     r4,r0
lsl     r0,r0,5
mov     r1,6
lsl     r1,r1,0x18
add     r0,r0,r1
str     r0,[sp,0]
mov     r0,sp
bl      print_right

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
ldr     r2,[sp,16]
@@prev3:
strh    r4,[r1,0]
add     r4,0x20
add     r1,0x40
sub     r2,r2,1
bne     @@prev3
add     r7,r7,2

//----------------------------------------
// Now we've rendered the left and right portions;
// we need to determin whether or not to do a final
// right portion for super wide characters
ldr     r1,[sp,20]          // Original pixel X offset
ldrb    r2,[r0,9]           // Render width
add     r2,r1,r2             // Right side of glyph
cmp     r2,16
bls     @@end

// We have one more chunk to render; figure out how much we already rendered
mov     r3,16
sub     r3,r3,r1
strb    r3,[r0,8]

// Allocate a new tile
mov     r0,r10
mov     r1,r11
lsr     r0,r0,3
add     r0,r0,2
lsr     r1,r1,3
bl      get_tile_number
add     r0,r8
mov     r4,r0
lsl     r0,r0,5
mov     r1,6
lsl     r1,r1,0x18
add     r0,r0,r1
str     r0,[sp,0]
mov     r0,sp
bl      print_right

//----------------------------------------
// Update the map
orr     r4,r6
mov     r1,r7
ldr     r2,[sp,16]
@@prev4:
strh    r4,[r1,0]
add     r4,0x20
add     r1,0x40
sub     r2,r2,1
bne     @@prev4
add     r7,r7,2

//----------------------------------------
@@end:
mov     r0,r9
add     sp,24
pop     {r4}
mov     r12,r4
pop     {r4-r7}
mov     r8,r4
mov     r9,r5
mov     r10,r6
mov     r11,r7
pop     {r1-r7,pc}
.pool


//=============================================================================
// void print_left(void* structPointer)
//=============================================================================

// In:
// r0: struct pointer
// [r0+0]: VRAM address
// [r0+4]: glyph address
// [r0+8]: VRAM x offset (byte)
// [r0+9]: render width (byte)
// [r0+10]: background index (byte)
// [r0+11]: foreground index (byte)
// [r0+12]: height in tiles (byte)
// [r0+13]: <unused> (3 bytes)

print_left:

push    {r0-r7,lr}
mov     r7,r0

//----------------------------------------
ldr     r6,[r7,0]           // VRAM address
ldr     r3,[r7,4]           // Glyph address
ldrb    r4,[r7,12]          // Height in tiles

@@loop:
mov     r5,8
@@prev:
ldr     r0,[r6,0]           // 4BPP VRAM row
ldrb    r1,[r7,11]          // Foreground index
bl      reduce_bit_depth    // Returns r0 = 1BPP VRAM row
ldrb    r1,[r7,9]           // Glyph render width
mov     r2,32
sub     r2,r2,r1
ldrb    r1,[r3,0]           // Glyph row
lsl     r1,r2                // Cut off the pixels we don't want to render
lsr     r1,r2
ldrb    r2,[r7,8]           // X offset
lsl     r1,r2
lsl     r1,r1,0x18
lsr     r1,r1,0x18
orr     r0,r1
ldrb    r1,[r7,10]
ldrb    r2,[r7,11]
bl      expand_bit_depth
str     r0,[r6,0]
add     r6,r6,4
add     r3,r3,1
sub     r5,r5,1
bne     @@prev
mov     r0,0x1F
lsl     r0,r0,5
add     r6,r0,r6
add     r3,8
sub     r4,r4,1
bne     @@loop

//----------------------------------------
pop     {r0-r7,pc}


//=============================================================================
// void print_right(void* structPointer)
//=============================================================================

// In:
// r0: struct pointer
// [r0+0]: VRAM address
// [r0+4]: glyph address
// [r0+8]: glyph x offset (byte)
// [r0+9]: render width (byte)
// [r0+10]: background index (byte)
// [r0+11]: foreground index (byte)
// [r0+12]: height in tiles (byte)
// [r0+13]: <unused> (3 bytes)

print_right:

push    {r0-r7,lr}
mov     r7,r0

//----------------------------------------
ldr     r6,[r7,0]           // VRAM address
ldr     r3,[r7,4]           // Glyph address
ldrb    r4,[r7,12]          // Height in tiles

@@loop:
mov     r5,8
@@prev:
ldr     r0,[r6,0]           // 4BPP VRAM row
ldrb    r1,[r7,11]          // Foreground index
bl      reduce_bit_depth    // Returns r0 = 1BPP VRAM row
ldrb    r1,[r7,9]           // Glyph render width
mov     r2,32
sub     r2,r2,r1
ldrb    r1,[r3,0]           // Glyph row
lsl     r1,r2                // Cut off the pixels we don't want to render
lsr     r1,r2
ldrb    r2,[r7,8]           // X offset
lsr     r1,r2
lsl     r1,r1,0x18
lsr     r1,r1,0x18
orr     r0,r1
ldrb    r1,[r7,10]
ldrb    r2,[r7,11]
bl      expand_bit_depth
str     r0,[r6,0]
add     r6,r6,4
add     r3,r3,1
sub     r5,r5,1
bne     @@prev
mov     r0,0x1F
lsl     r0,r0,5
add     r6,r0,r6
add     r3,8
sub     r4,r4,1
bne     @@loop

//----------------------------------------
pop     {r0-r7,pc}


//==============================================================================
// byte reduce_bit_depth(int pixels)
// In:
//    r0: row of 4BPP pixels
//    r1: foreground index
// Out:
//    r0: row of 1BPP pixels
//==============================================================================

// Some notes:
// - the goal is to reduce the 4BPP row of pixels in r0 to a 1BPP row according
//   to the foreground index in r1
// - this is achieved quickly using a lookup
// - first step is to set all foreground pixels (each pixel is a nybble in r0) to 0,
//   and all background pixels to non-zero
// - this is done by XOR-ing r0 with a row of foreground pixels, where a row of
//   foreground pixels is just r1*0x11111111
// - when we index into the lookup table using the resulting XOR-ed value, we'll get
//   a 1BPP value where each corresponding 0-nybble (a foreground pixel) is a 1
//   and any corresponding non-zero-nybble is a 0
// - to keep the lookup table at a reasonable size we'll go 4 pixels at a time:
//   there are thus 16^4 = 65536 possible index values and the lookup table will be 64KB
// - this uses 63 cycles while the previous method used 273 cycles

reduce_bit_depth:
push    {r1-r3,lr}

ldr     r3,=0x11111111
mul     r1,r3
ldr     r2,=m2_nybbles_to_bits
eor     r0,r1

lsl     r1,r0,16
lsr     r1,r1,16
lsr     r0,r0,16
ldrb    r3,[r2,r0]
ldrb    r0,[r2,r1]
lsl     r3,r3,4
orr     r0,r3

pop     {r1-r3,pc}
.pool



//==============================================================================
// int expand_bit_depth(byte pixels)
// In:
//    r0: row of 1BPP pixels
//    r1: background index
//    r2: foreground index
// Out:
//    r0: row of 4BPP pixels
//==============================================================================

// - similar to reduce_bit_depth, we go fast using a lookup table
// - there are really 16 lookup tables, one for each possible value of r1/r2
// - we simply look up the word at (table + (r0*4) + (r1*1024)) to get the 4BPP
//   expanded version of r0 using colour index r1 (or r2)
// - do it once for foreground, then invert r0 and do it again for background
// - XOR the two values together to get the final 4BPP row of pixels
// - this uses 61 cycles while the previous method used 287 cycles

expand_bit_depth:
push    {r1-r6,lr}
ldr     r6,=m2_bits_to_nybbles

// Foreground
lsl     r4,r2,10
lsl     r3,r0,2
add     r5,r4,r6
ldr     r2,[r5,r3]

// Background
lsl     r4,r1,10
add     r5,r4,r6
mov     r4,0xFF
eor     r0,r4
lsl     r3,r0,2
ldr     r1,[r5,r3]

orr     r2,r1
mov     r0,r2

pop     {r1-r6,pc}
.pool



//==============================================================================
// void clear_window(WINDOW* window, int bgIndex)
// In:
//    r0: window pointer
//    r1: background index
//==============================================================================

// - clears all VWF-ified tiles in a window
clear_window:
push    {r0-r3,lr}
add     sp,-16
mov     r3,r0
mov     r0,sp
ldr     r2,=0x30051EC
ldrh    r2,[r2,0] // tile offset
strh    r2,[r0,8]
ldr     r2,=0x11111111
mul     r1,r2
str     r1,[r0,4] // empty row of pixels

ldrh    r1,[r3,0x22] // window X
strh    r1,[r0,0]
ldrh    r1,[r3,0x24] // window Y
strh    r1,[r0,2]
ldrh    r1,[r3,0x26] // window width
strh    r1,[r0,0xC]
ldrh    r1,[r3,0x28] // window height
strh    r1,[r0,0xE]

bl      clear_rect

add     sp,16
pop     {r0-r3,pc}
.pool


//==============================================================================
// void clear_rect(CLEAR_RECT_STRUCT* data)
// In:
//    r0: data pointer
//       [r0+0x00]: x
//       [r0+0x02]: y
//       [r0+0x04]: empty row of pixels
//       [r0+0x08]: tile offset
//       [r0+0x0C]: width
//       [r0+0x0E]: height
//==============================================================================

// - clears a rectangle

clear_rect:
push    {r0-r6,lr}

ldrh    r1,[r0,0xC] // width
ldrh    r2,[r0,0xE] // height
ldrh    r6,[r0,0]   // initial X
mov     r3,0 // current row
@@outer_start:
cmp     r3,r2
bge     @@end
mov     r4,0 // current col
@@prev:
cmp     r4,r1
bge     @@inner_end
bl      clear_tile_internal
ldrh    r5,[r0,0]
add     r5,r5,1
strh    r5,[r0,0]
add     r4,r4,1
b       @@prev
@@inner_end:
ldrh    r5,[r0,2]
add     r5,r5,1
strh    r5,[r0,2]
mov     r5,r6
strh    r5,[r0,0]
add     r3,r3,1
b       @@outer_start

@@end:
pop     {r0-r6,pc}


//==============================================================================
// void clear_tile_internal(CLEAR_STRUCT* data)
// In:
//    r0: data pointer
//       [r0+0x00]: x
//       [r0+0x02]: y
//       [r0+0x04]: empty row of pixels
//       [r0+0x08]: tile offset
//==============================================================================

// - clears a VWF tile at (x,y)

clear_tile_internal:
push    {r0-r3,lr}

mov     r3,r0
ldrh    r0,[r3,0]
ldrh    r1,[r3,2]
bl      get_tile_number
ldrh    r1,[r3,8]
add     r0,r0,r1
lsl     r1,r0,5
mov     r0,6
lsl     r0,r0,24
add     r1,r0,r1 // VRAM dest address
add     r0,r3,4 // source address
ldr     r2,=0x1000008 // set the fixed source address flag + copy 8 words
swi     0xC // CpuFastSet

pop     {r0-r3,pc}
.pool


//==============================================================================
// void print_blankstr(int x, int y, int width)
// In:
//    r0: x (tile)
//    r1: y (tile)
//    r2: width (tile)
//==============================================================================

// - prints a blank string at (x,y) of width tiles
print_blankstr:
push    {r0-r5,lr}
add     sp,-16
mov     r4,r0
mov     r0,sp

strh    r4,[r0,0]
strh    r1,[r0,2]
ldr     r1,=0x44444444
str     r1,[r0,4]
ldr     r1,=0x30051EC
ldrh    r1,[r1,0]
str     r1,[r0,8]
strh    r2,[r0,0xC]
mov     r2,2
strh    r2,[r0,0xE]
bl      clear_rect

add     sp,16
pop     {r0-r5,pc}
.pool


//==============================================================================
// void print_space(WINDOW* window)
// In:
//    r0: window pointer
//==============================================================================

// - prints a space character to window
print_space:
push    {r0-r1,lr}
add     sp,-4
mov     r1,0x50
str     r1,[sp,0]
mov     r1,sp
bl      weld_entry
add     sp,4
pop     {r0-r1,pc}


//==============================================================================
// void copy_tile(int x1, int y1, int x2, int y2)
// In:
//    r0,r1: x1,y1
//    r2,r3: x2,y2
//==============================================================================

// - copies a tile from (x1,y1) to (x2,y2)
copy_tile:
push    {r0-r4,lr}

// Get the source and dest tile numbers @@next offset
bl      get_tile_number
mov     r4,r0
mov     r0,r2
mov     r1,r3
bl      get_tile_number
mov     r3,r0
ldr     r0,=0x30051EC
ldrh    r1,[r0,0]
add     r0,r1,r4 // source tile
add     r1,r1,r3 // dest tile

// Get VRAM addresses
mov     r2,6
lsl     r2,r2,0x18 // VRAM tile base
lsl     r0,r0,5
lsl     r1,r1,5
add     r0,r0,r2 // VRAM source address
add     r1,r1,r2 // VRAM dest address

// Copy
mov     r2,8
swi     0xC

pop     {r0-r4,pc}
.pool


//==============================================================================
// void copy_tile_up(int x, int y)
// In:
//    r0,r1: x,y
//==============================================================================

// - copies a tile upward by one line (16 pixels)
copy_tile_up:
push    {r2-r3,lr}
sub     r3,r1,2
mov     r2,r0
bl      copy_tile
pop     {r2-r3,pc}
