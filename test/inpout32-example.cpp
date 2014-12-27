BOOL isDriverOn = false;
#define LEFT 0x4B 
#define RIGHT 0x4D 

void setup() {
        isDriverOn = IsInpOutDriverOpen();
}

//void  _stdcall Out32(short PortAddress, short data);
//short _stdcall Inp32(short PortAddress);
void DD_PS2command(short comm, short value) {
        if(!isDriverOn) {
            printf("PS/2 Keyboard port driver is not opened\n");
            return;
        }
        //keyboard wait.
        int kb_wait_cycle_counter = 1000;
        while((Inp32(0x64) & 0x02) && kb_wait_cycle_counter--) //wait to get communication.
            Sleep(1);
			
        if(kb_wait_cycle_counter) { //if it didn't timeout.
            Out32(0x64, comm); //send command
            kb_wait_cycle_counter = 1000;
            while((Inp32(0x64) & 0x02) && kb_wait_cycle_counter--) //wait to get communication.
                Sleep(1);
            if(!kb_wait_cycle_counter) {
                printf("failed to get communication in cycle counter timeout), who knows what will happen now\n");
                //return false;
            }
            Out32(0x60, value); //send data as short
            Sleep(1);
            //return true;
        } else {
            printf("failed to get communication in counter timeout, busy)\n");
            //return false;
        }
}

void DD_Button(short btn, bool release = false, int delay = 0)
{
  //;0xE0, 0x4B      {Left}
  //;0xE0, 0x4D      {Rght}
  //  return scode | (release? 0x80: 0x00)
  short scan_code = 0;
  bool good = false;
  switch(btn) {
    case LEFT:
    case RIGHT:
        scan_code = btn;
        //send extended byte first (grey code)
        good = DD_PS2command(0xD2, 0xE0);
        break;
  }
  printf("good = %d\n", good);
  scan_code |= (release ? 0x80 : 0x00);

  if(delay)  
    Sleep(delay);
  //0xD2 - Write keyboard output buffer
  good = DD_PS2command(0xD2, scan_code);
  printf("2 good = %d\n", good);
}