void io_hlt(void);
void io_cli(void);
void io_out8(int port, int data);
int io_load_eflags(void);
int io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void box_fill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);

#define COL8_000000 0      /* 0x00,0x00,0x00, 0, black           */
#define COL8_FF0000 1      /* 0xff,0x00,0x00, 1, red             */
#define COL8_00FF00 2      /* 0x00,0xff,0x00, 2, green           */
#define COL8_FFFF00 3      /* 0xff,0xff,0x00, 3, yellow          */
#define COL8_0000FF 4      /* 0x00,0x00,0xff, 4, blue            */
#define COL8_FF00FF 5      /* 0xff,0x00,0xff, 5, purple          */
#define COL8_00FFFF 6      /* 0x00,0xff,0xff, 6, light cyan      */
#define COL8_FFFFFF 7      /* 0xff,0xff,0xff, 7, white           */
#define COL8_C6C6C6 8      /* 0xc6,0xc6,0xc6, 8, light gray      */
#define COL8_840000 9      /* 0x84,0x00,0x00, 9, dark red        */
#define COL8_008400 10     /* 0x00,0x84,0x00, 10,dark green      */
#define COL8_848400 11     /* 0x84,0x84,0x00, 11,dark yellow     */
#define COL8_000084 12     /* 0x00,0x00,0x84, 12,dark blue       */
#define COL8_840084 13     /* 0x84,0x00,0x84, 13,dark purple     */
#define COL8_008484 14     /* 0x00,0x84,0x84, 14,dark cyan       */
#define COL8_848484 15     /* 0x84,0x84,0x84, 15,dark gray       */

typedef struct {
  char cyls, leds, vmode, reserve;
  short scrnx, scrny;
  char *vram;
} BootInfo;

void OSMain(void)
{
  char *vram;
  int xsize, ysize;
  BootInfo *binfo;

  init_palette();

  binfo = (BootInfo *)0x0FF0;
  xsize = binfo->scrnx;
  ysize = binfo->scrny;
  vram = binfo->vram;

  box_fill8(vram, xsize, COL8_008484,     0, 0,         xsize-1, ysize-29);
  box_fill8(vram, xsize, COL8_C6C6C6,     0, ysize-28,  xsize-1, ysize-28);
  box_fill8(vram, xsize, COL8_FFFFFF,     0, ysize-27,  xsize-1, ysize-27);
  box_fill8(vram, xsize, COL8_C6C6C6,     0, ysize-26,  xsize-1, ysize-1);

  box_fill8(vram, xsize, COL8_FFFFFF,     3, ysize-24, 59, ysize-24);
  box_fill8(vram, xsize, COL8_FFFFFF,     2, ysize-24, 2,  ysize-4);
  box_fill8(vram, xsize, COL8_848484,     3, ysize-4,  59, ysize-4);
  box_fill8(vram, xsize, COL8_848484,    59, ysize-23, 59, ysize-5);
  box_fill8(vram, xsize, COL8_000000,     2, ysize-3,  59, ysize-3);
  box_fill8(vram, xsize, COL8_000000,    60, ysize-24, 60, ysize-3);

  box_fill8(vram, xsize, COL8_000000,   xsize-47, ysize-24, xsize-4, ysize-24);
  box_fill8(vram, xsize, COL8_000000,   xsize-47, ysize-23, xsize-47, ysize-4);
  box_fill8(vram, xsize, COL8_FFFFFF,   xsize-47, ysize-3,  xsize-4, ysize-3);
  box_fill8(vram, xsize, COL8_FFFFFF,   xsize-3,  ysize-24, xsize-3, ysize-3);

  for(;;)
  {
    io_hlt();
  }
}


void init_palette(void)
{
  static unsigned char table_rgb[16 * 3] =
  {
    0x00,0x00,0x00, // 0, black
    0xff,0x00,0x00, // 1, red
    0x00,0xff,0x00, // 2, green
    0xff,0xff,0x00, // 3, yellow
    0x00,0x00,0xff, // 4, blue
    0xff,0x00,0xff, // 5, purple
    0x00,0xff,0xff, // 6, light cyan
    0xff,0xff,0xff, // 7, white
    0xc6,0xc6,0xc6, // 8, light gray
    0x84,0x00,0x00, // 9, dark red
    0x00,0x84,0x00, // 10,dark green
    0x84,0x84,0x00, // 11,dark yellow
    0x00,0x00,0x84, // 12,dark blue
    0x84,0x00,0x84, // 13,dark purple
    0x00,0x84,0x84, // 14,dark cyan
    0x84,0x84,0x84, // 15,dark gray
  };
  set_palette(0, 15, table_rgb);
  return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
  int i, eflags;
  eflags = io_load_eflags();
  io_cli();
  io_out8(0x03c8, start);
  for(i=start; i<=end; i++)
  {
    io_out8(0x03c9, rgb[0]/4);
    io_out8(0x03c9, rgb[1]/4);
    io_out8(0x03c9, rgb[2]/4);
    rgb += 3;
  }
  io_store_eflags(eflags);
  return;
}

void box_fill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
  int x, y;
  for(y = y0; y <= y1; y++)
  {
    for(x = x0; x <= x1; x++)
    {
      vram[y * xsize + x] = c;
    }
  }
  return;
}
