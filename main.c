#include "xparameters.h"
#include "xil_io.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_cache.h"
#include "ff.h"
#include "shapefill.h"
#include "sleep.h"

#define MM2S_VDMACR 		0x00
#define MM2S_VDMASR 		0x04
#define S2MM_VDMACR 		0x30
#define S2MM_VDMASR 		0x34
#define MM2S_VSIZE 			0x50
#define MM2S_HSIZE 			0x54
#define MM2S_FRMDLY_STRIDE 	0x58
#define S2MM_VSIZE			0xA0
#define S2MM_HSIZE			0xA4
#define S2MM_FRMDLY_STRIDE	0xA8

#define DISPLAY_WIDTH 1280
#define DISPLAY_HEIGHT 720
#define PIXEL_SIZE 4

unsigned char frame_buffer[DISPLAY_WIDTH*DISPLAY_HEIGHT*PIXEL_SIZE];

// SD Card parameters
static FATFS fatFS;			// File System instance
static FIL imageFile;		// File instance
TCHAR *Path = "0:/";		// String pointer to the logical drive number
FSIZE_t fileSize;			// Size of file
FRESULT result;				// FRESULT variable
UINT bytesRd;				// Bytes read
static const char *imageFileName = "pic5.bin";

volatile u8 shapefill_isr_done = 0;

int initIntrController(XScuGic*); // interrupt controller initialization
void shapefill_isr(void*);	// ISR if the shape filling operation is done
void enable_mm2s(); // enables VDMA MM2S operations
void enable_s2mm(); // enables VDMA S2MM operations
void disable_mm2s(); // disables VDMA MM2S operations
void disable_mm2s(); // disables VDMA S2MM operations
void configure_mm2s(void*, unsigned int, unsigned int); // configures VDMA MM2S operations
void configure_s2mm(void*, unsigned int, unsigned int); // configures VDMA S2MM operations

int Status;

/**************************************************/
// Main function
/**************************************************/
int main() {
	// Configure interrupts
	XScuGic Intc;
	initIntrController(&Intc);

	// Access the image file from SD card
	result = f_mount(&fatFS, Path, 1);
	if (result == FR_OK) {
		result = f_open(&imageFile, imageFileName, FA_READ); // open the file
		fileSize = f_size(&imageFile); // query the file size
		result = f_read(&imageFile, frame_buffer, fileSize, &bytesRd); // read the file into frame buffer
		result = f_close(&imageFile); // close the file
	}

	// Enable and configure the MM2S DMA (Memory to Video Out)
	enable_mm2s();
	configure_mm2s((void *) frame_buffer, DISPLAY_WIDTH, DISPLAY_HEIGHT);

	// Send the base address of the framebuffer to the shapefill IP
	SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG1_OFFSET, frame_buffer);

//	 int x = 360, y = 8; // set initial top-left box coordinates
	// int dx = 20, dy = 20; // coordinate increments per iteration
	// int color, cidx = 0; // fill color and index

	// This loop will draw a new box every second
	while(1) {
		shapefill_isr_done = 0; // reset the interrupt indicator

		// Write the fill color
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG2_OFFSET, 0xFF0000FF);

		// Send the top-left coordinates (upper 16-bits is the x0, lower 16-bits is the y0)
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG3_OFFSET, (360 << 16) | 8);

		// Send the bottom-right coordinates (upper 16-bits is the x1, lower 16-bits is the y1)
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG4_OFFSET, (1008 << 16) | 472);

		// Send the bottom-right coordinates (upper 16-bits is the x2, lower 16-bits is the y2)
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG5_OFFSET, (128 << 16) | 328);


		// Send the bottom-right coordinates (upper 16-bits is the x2, lower 16-bits is the y2)
//		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG5_OFFSET, (0 << 16) | 0);

		// Start the operation
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG0_OFFSET, 1);

		while(!shapefill_isr_done); // wait for the done signal
		sleep(1); // wait for 1 second

		/*
		shapefill_isr_done = 0; // reset the interrupt indicator

		// decide the fill color (color is in ABGR format)
		if (cidx == 0) color = 0xFF0000FF; // red
		else if (cidx == 1) color = 0xFF00FF00; // green
		else if (cidx == 2) color = 0xFFFF0000; // blue
		cidx = (cidx + 1) %  3; // change fill color for next iteration

		// Write the fill color
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG2_OFFSET, color);

		// Send the top-left coordinates (upper 16-bits is the x0, lower 16-bits is the y0)
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG3_OFFSET, (x << 16) | y);

		// Send the bottom-right coordinates (upper 16-bits is the x1, lower 16-bits is the y1) to create a 100x100 box
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG4_OFFSET, ((x + 100) << 16) | (y + 100));

		// Start the operation
		SHAPEFILL_mWriteReg(XPAR_SHAPEFILL_0_S00_AXI_BASEADDR, SHAPEFILL_S00_AXI_SLV_REG0_OFFSET, 1);

		// Update the x-coordinates
		x += dx;
		if (x <= 0 || x + 100 >= DISPLAY_WIDTH) // check for boundary conditions
			dx *= -1;

		// Update the y-coordinates
		y += dy;
		if (y <= 0 || y + 100 >= DISPLAY_HEIGHT) // check for boundary conditions
			dy *= -1;

		while(!shapefill_isr_done); // wait for the done signal
		sleep(1); // wait for 1 second
		*/
	}

	return 0;

}
/**************************************************/
// Utility functions
/**************************************************/
int initIntrController(XScuGic *IntcInstancePtr) {
	int Status;
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	Status =  XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
	if(Status != XST_SUCCESS){
		xil_printf("Interrupt controller initialization failed..");
		return Status;
	}

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, (void *) IntcInstancePtr);
	Xil_ExceptionEnable();

	Status = XScuGic_Connect(IntcInstancePtr, XPAR_FABRIC_SHAPEFILL_0_VEC_ID,
			(Xil_ExceptionHandler)shapefill_isr, (void *) &shapefill_isr_done);
	if (Status != XST_SUCCESS){
		return Status;
	}
	XScuGic_SetPriorityTriggerType(IntcInstancePtr, XPAR_FABRIC_SHAPEFILL_0_VEC_ID, 10 << 3, 0x03);
	XScuGic_Enable(IntcInstancePtr, XPAR_FABRIC_SHAPEFILL_0_VEC_ID);

	return XST_SUCCESS;
}
/**************************************************/
void enable_mm2s() {
	// Write to the MM2S_VDMACR (MM2S control register)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_VDMACR, 0x8B);

	// Clear all the status flags
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_VDMASR, 0xFFFFFFFF);
}
/**************************************************/
void enable_s2mm() {
	// Write to the MM2S_VDMACR (MM2S control register)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_VDMACR, 0x8B);

	// Clear all the status flags
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_VDMASR, 0xFFFFFFFF);
}
/**************************************************/
void disable_mm2s() {
	// Write to the MM2S_VDMACR (MM2S control register)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_VDMACR, 0x00);

	// Clear all the status flags
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_VDMASR, 0xFFFFFFFF);
}
/**************************************************/
void disable_s2mm() {
	// Write to the MM2S_VDMACR (MM2S control register)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_VDMACR, 0x00);

	// Clear all the status flags
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_VDMASR, 0xFFFFFFFF);
}
/**************************************************/
void configure_mm2s(void *mem_base_addr, unsigned int width, unsigned int height) {
	// Assign the frame buffer address
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0x5C, (u32) mem_base_addr);

	// Define the size of the frame
	// This assumes that the data is in RGB 8-bit format
	// It also assumes that the stride is equal to the frame width
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_FRMDLY_STRIDE, width * PIXEL_SIZE); // Stride (in bytes)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_HSIZE, width * PIXEL_SIZE); // Width (in bytes)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + MM2S_VSIZE, height); // Height
}
/**************************************************/
void configure_s2mm(void *mem_base_addr, unsigned int width, unsigned int height) {
	// Assign the frame buffer address
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0xAC, (u32) mem_base_addr);

	// Define the size of the frame
	// This assumes that the data is in RGB 8-bit format
	// It also assumes that the stride is equal to the frame width
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_FRMDLY_STRIDE, width * PIXEL_SIZE); // Stride (in bytes)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_HSIZE, width * PIXEL_SIZE); // Width (in bytes)
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + S2MM_VSIZE, height); // Height
}
/**************************************************/
// Interrupt Service Routine
/**************************************************/
void shapefill_isr(void *callback_ref) {
	shapefill_isr_done = 1; // Signal that the shape filler is done
}
/**************************************************/
