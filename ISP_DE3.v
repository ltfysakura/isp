
module ISP_DE3(

		////////// CLOCK //////////
		output				CLK_OUT,
		input					EXT_CLK,
		input					OSC1_50,
		input					OSC2_50,
		input					OSC_BA,
		input					OSC_BB,
		input					OSC_BC,
		input					OSC_BD,

		////////// LED //////////
		output	[7:0]		LEDB,
		output	[7:0]		LEDG,
		output	[7:0]		LEDR,

		////////// SEG7 //////////
		output	[6:0]		HEX0,
		output				HEX0_DP,
		output	[6:0]		HEX1,
		output				HEX1_DP,

		////////// BUTTON //////////
		input		[3:0]		Button,

		////////// SW (SLIDE SWITCH) //////////
		input		[3:0]		SW,

		////////// DIP_SW (DIP SWITCH) //////////
		input		[7:0]		DIP_SW,

		////////// MAX1619 (TEMPERATURE SENSOR) //////////
		output				TEMP_CLK,
		inout					TEMP_DATA,
		input					TEMP_INTn,

		////////// USB //////////
		output	[17:1]	OTG_A,
		output				OTG_CS_n,
		inout		[31:0]	OTG_D,
		output				OTG_DC_DACK,
		input					OTG_DC_DREQ,
		input					OTG_DC_IRQ,
		output				OTG_HC_DACK,
		input					OTG_HC_DREQ,
		input					OTG_HC_IRQ,
		output				OTG_OE_n,
		output				OTG_RESET_n,
		output				OTG_WE_n,

		////////// SDCARD //////////
		output				SD_CLK,
		inout					SD_CMD,
		inout					SD_DAT,
		input					SD_WPn,

		////////// GPIO1 (J14, GPIO 1), connect to D5M(D5M Board) //////////
		input		[11:0]	GPIO1_D,
		input					GPIO1_FVAL,
		input					GPIO1_LVAL,
		input					GPIO1_PIXLCLK,
		output				GPIO1_RESETn,
		output				GPIO1_SCLK,
		inout					GPIO1_SDATA,
		input					GPIO1_STROBE,
		output				GPIO1_TRIGGER,
		input					GPIO1_XCLKIN,

		////////// mem (J9, DDR2 SO-DIMM), connect to DDR2_SODIMM(DDR2_SODIMM Board) //////////
//		output	[1:0]		mem_SA,
//		output				mem_SCL,
//		inout					mem_SDA,
//		output	[15:0]	mem_addr,
//		output	[2:0]		mem_ba,
//		output				mem_cas_n,
//		output	[1:0]		mem_cke,
//		inout		[1:0]		mem_clk,
//		inout		[1:0]		mem_clk_n,
//		output	[1:0]		mem_cs_n,
//		output	[7:0]		mem_dm,
//		inout		[63:0]	mem_dq,
//		inout		[7:0]		mem_dqs,
//		inout		[7:0]		mem_dqsn,
//		output	[1:0]		mem_odt,
//		output				mem_ras_n,
//		output				mem_we_n,
//		
//		input					rdn,
//		input					rup,
//		output				mem_ck,
//		output				mem_ck_n,
		

		////////// HSTCC (J5 HSTC-C TOP/J6, HSTC-C BOTTOM), connect to DVI(DVI TX/RX Board) //////////
		input					HSTCC_DVI_RX_CLK,
		input		[3:1]		HSTCC_DVI_RX_CTL,
		input		[23:0]	HSTCC_DVI_RX_D,
		inout					HSTCC_DVI_RX_DDCSCL,
		inout					HSTCC_DVI_RX_DDCSDA,
		input					HSTCC_DVI_RX_DE,
		input					HSTCC_DVI_RX_HS,
		input 				HSTCC_DVI_RX_SCDT,
		input					HSTCC_DVI_RX_VS,
		output				HSTCC_DVI_TX_CLK,
		output	[3:1]		HSTCC_DVI_TX_CTL,
		output	[23:0]	HSTCC_DVI_TX_D,
		inout					HSTCC_DVI_TX_DDCSCL,
		inout					HSTCC_DVI_TX_DDCSDA,
		output				HSTCC_DVI_TX_DE,
		output				HSTCC_DVI_TX_DKEN,
		output				HSTCC_DVI_TX_HS,
		output				HSTCC_DVI_TX_HTPLG,
		output				HSTCC_DVI_TX_ISEL,
		output				HSTCC_DVI_TX_MSEN,
		output				HSTCC_DVI_TX_SCL,
		inout					HSTCC_DVI_TX_SDA,
		output				HSTCC_DVI_TX_VS,
		output				HSTCC_EDID_WP,
		output				HSTCC_HSMC_SCL,
		inout					HSTCC_HSMC_SDA,
		output				HSTCC_TX_PD_N,

		////////// REGULATOR //////////
		output				JVC_CLK,
		output				JVC_CS,
		input					JVC_DATAIN,
		output				JVC_DATAOUT

	);

//=======================================================
//  PARAMETER declarations
//=======================================================

//=======================================================
//  REG/WIRE declarations
//=======================================================
//	D5M
//wire	[15:0]	Read_DATA1;
//wire	[15:0]	Read_DATA2;
wire	[31:0]	Read_DATA;
wire				VGA_CTRL_CLK;
wire	[11:0]	mCCD_DATA;
wire				mCCD_DVAL;
wire				mCCD_DVAL_d;
wire	[15:0]	X_Cont;
wire	[15:0]	Y_Cont;
wire	[9:0]		X_ADDR;
wire	[31:0]	Frame_Cont;
wire				DLY_RST_0;
wire				DLY_RST_1;
wire				DLY_RST_2;
wire				DLY_RST_3;
wire				DLY_RST_4;
wire				Read;
reg	[11:0]	rCCD_DATA;
reg				rCCD_LVAL;
reg				rCCD_FVAL;
wire	[11:0]	sCCD_R;
wire	[11:0]	sCCD_G;
wire	[11:0]	sCCD_B;
wire				sCCD_DVAL;
wire	[9:0]		oVGA_R;   				//	VGA Red[9:0]
wire	[9:0]		oVGA_G;	 				//	VGA Green[9:0]
wire	[9:0]		oVGA_B;   				//	VGA Blue[9:0]
reg	[1:0]		rClk;

wire				auto_start;
wire				reset_n;

//	Auto start when power on
assign 			auto_start	= ((Button[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
assign			reset_n 		= Button[0];


//	DDR2
wire				ip_init_done;
wire				wrt_full_port0;
wire				wrt_full_port1;

//	DVI
wire 				reset_n_dvi;
wire 				pll_100M;
wire 				pll_100K;

wire 				gen_sck;
wire				gen_i2s;
wire				gen_ws;



//=======================================================
//  External PLL Configuration
//=======================================================

//  Signal declarations
wire	[3:0]		clk1_set_wr, clk2_set_wr, clk3_set_wr;
wire				rstn;
wire				conf_ready;
wire				counter_max;
wire	[7:0]		counter_inc;
reg	[7:0]		auto_set_counter;
reg				conf_wr;

//  Structural coding
assign clk1_set_wr = 4'd4; //100 MHZ
assign clk2_set_wr = 4'd4; //100 MHZ
assign clk3_set_wr = 4'd4; //100 MHZ

assign rstn = Button[0];
assign counter_max = &auto_set_counter;
assign counter_inc = auto_set_counter + 1'b1;

always @(posedge OSC_50_BANK2 or negedge rstn)
	if(!rstn)
	begin
		auto_set_counter <= 0;
		conf_wr <= 0;
	end 
	else if (counter_max)
		conf_wr <= 1;
	else
		auto_set_counter <= counter_inc;


ext_pll_ctrl ext_pll_ctrl_Inst(
	.osc_50(OSC_50_BANK2), //50MHZ
	.rstn(rstn),

	// device 1 (HSMA_REFCLK)
	.clk1_set_wr(clk1_set_wr),
	.clk1_set_rd(),

	// device 2 (HSMB_REFCLK)
	.clk2_set_wr(clk2_set_wr),
	.clk2_set_rd(),

	// device 3 (PLL_CLKIN/SATA_REFCLK)
	.clk3_set_wr(clk3_set_wr),
	.clk3_set_rd(),

	// setting trigger
	.conf_wr(conf_wr), // 1T 50MHz 
	.conf_rd(), // 1T 50MHz

	// status 
	.conf_ready(conf_ready),

	// 2-wire interface 
	.max_sclk(MAX_I2C_SCLK),
	.max_sdat(MAX_I2C_SDAT)

);


//=======================================================
//  Structural coding
//=======================================================
//D5M
assign	GPIO1_TRIGGER	=	1'b1;  // tRIGGER
assign	GPIO1_RESETn	=	DLY_RST_1;

//	D5M read 
always@(posedge GPIO1_PIXLCLK)
begin
	rCCD_DATA	<=	GPIO1_D;
	rCCD_LVAL	<=	GPIO1_LVAL;
	rCCD_FVAL	<=	GPIO1_FVAL;
end

//	Reset module
Reset_Delay	u2(	
	.iCLK(OSC2_50),
	.iRST(Button[0]),
	.oRST_0(DLY_RST_0),
	.oRST_1(DLY_RST_1),
	.oRST_2(DLY_RST_2),
	.oRST_3(DLY_RST_3),
	.oRST_4(DLY_RST_4)
);

//	D5M image capture
CCD_Capture	u3(
	.oDATA(mCCD_DATA),
	.oDVAL(mCCD_DVAL),
	.oX_Cont(X_Cont),
	.oY_Cont(Y_Cont),
	.oFrame_Cont(Frame_Cont),
	.iDATA(rCCD_DATA),
	.iFVAL(rCCD_FVAL),
	.iLVAL(rCCD_LVAL),
	.iSTART(!Button[3]|auto_start),
	.iEND(!Button[2]),
	.iCLK(~GPIO1_PIXLCLK),
	.iRST(DLY_RST_2)
);

//D5M raw date convert to RGB data
//`ifdef SXGA_1280x1024p60
//RAW2RGB				u4	(	.iCLK(D5M_PIXLCLK),
//							.iRST_n(DLY_RST_1),
//							.iData(mCCD_DATA),
//							.iDval(mCCD_DVAL),
//							.oRed(sCCD_R),
//							.oGreen(sCCD_G),
//							.oBlue(sCCD_B),
//							.oDval(sCCD_DVAL),
//							.iZoom(SLIDE_SW[3:2]),
//							.iX_Cont(X_Cont),
//							.iY_Cont(Y_Cont)
//						);
//`else

RAW2RGB	u4(
	.iCLK(GPIO1_PIXLCLK),
	.iRST(DLY_RST_1),
	.iDATA(mCCD_DATA),
	.iDVAL(mCCD_DVAL),
	.oRed(sCCD_R),
	.oGreen(sCCD_G),
	.oBlue(sCCD_B),
	.oDVAL(sCCD_DVAL),
	.iX_Cont(X_Cont),
	.iY_Cont(Y_Cont)
);
//`endif			


//Frame count display
Frame_Display u5(
	.iDig(Frame_Cont[7:0]),
	.oHEX0(HEX0),
	.oHEX1(HEX1)
);

// DDR2
// BLAH BLAH BLAH BLAH OH~~~~~~
//ddr2_multi_port   u8    (
//                         // global signals
//						   .clk_50(OSC2_50),
//						   .reset_n(reset_n),
//
//						 // the_Read_Port0   
//						   .iCLK_F_to_the_Read_Port0(vpg_pclk),
//						   .iIP_INIT_DONE_to_the_Read_Port0(ip_init_done),
//						   .iREAD_ACK_F_to_the_Read_Port0(vpg_de),
//						   .iRST_n_F_to_the_Read_Port0(read_rstn),
//						   .oEMPTY_F_from_the_Read_Port0(),
//						   .oPORT_READY_F_from_the_Read_Port0(),
//						   .oREAD_DATA_F_from_the_Read_Port0({Read_DATA1,Read_DATA2}),
//						   
//						 // the_Write_Port0     
//						   .iCLK_F_to_the_Write_Port0(~D5M_PIXLCLK),
//						   .iFLUSH_REQ_F_to_the_Write_Port0(),
//						   .iIP_INIT_DONE_to_the_Write_Port0(ip_init_done),
//						   .iRST_n_F_to_the_Write_Port0(BUTTON[0]),
//						   .iWRITE_DATA_F_to_the_Write_Port0({1'b0,sCCD_G[11:7],sCCD_B[11:2],1'b0,sCCD_G[6:2],sCCD_R[11:2]}), 
//						   .iWRITE_F_to_the_Write_Port0(sCCD_DVAL),
//						   .oBURST_COUNT_from_the_Write_Port0(),
//						   .oFLUSH_BUSY_F_from_the_Write_Port0(),
//						   .oFULL_F_from_the_Write_Port0(wrt_full_port0),
//						  						  
//						  // the_ddr2   
//						   .global_reset_n_to_the_ddr2(reset_n),
//						   .local_init_done_from_the_ddr2(ip_init_done),
//						   .mem_addr_from_the_ddr2(M1_DDR2_addr),
//						   .mem_ba_from_the_ddr2(M1_DDR2_ba),
//						   .mem_cas_n_from_the_ddr2(M1_DDR2_cas_n),
//						   .mem_cke_from_the_ddr2(M1_DDR2_cke),
//						   .mem_clk_n_to_and_from_the_ddr2(M1_DDR2_clk_n),
//						   .mem_clk_to_and_from_the_ddr2(M1_DDR2_clk),
//						   .mem_cs_n_from_the_ddr2(M1_DDR2_cs_n),
//						   .mem_dm_from_the_ddr2(M1_DDR2_dm),
//						   .mem_dq_to_and_from_the_ddr2(M1_DDR2_dq),
//						   .mem_dqs_to_and_from_the_ddr2(M1_DDR2_dqs),
//						   .mem_dqsn_to_and_from_the_ddr2(M1_DDR2_dqsn),
//						   .mem_odt_from_the_ddr2(M1_DDR2_odt),
//						   .mem_ras_n_from_the_ddr2(M1_DDR2_ras_n),
//						   .mem_we_n_from_the_ddr2(M1_DDR2_we_n),
//                        
//                         );

// CRITICAL SECTION FOR DDR2 STARTS
// =========================================================

//	Prevent from read at starting because of none data in the ddr2
reg	[15:0]write_cnt;
always@(posedge ~GPIO1_PIXLCLK)
	if (~reset_n)
		write_cnt <= 0;
	else if ( (sCCD_DVAL) & (write_cnt != 65536) )
		write_cnt <= write_cnt + 1;
			                  
reg	read_rstn;
always@(posedge ~GPIO1_PIXLCLK)
	begin
		if (~reset_n)
			read_rstn <= 0;
		else if (write_cnt == 512)
			read_rstn <= 1;
end


reg			wr_new_frame;
reg	[1:0]	frame_wr_state;
reg			pre_rCCD_FVAL;
reg			pre_sCCD_DVAL;

always @(posedge GPIO1_PIXLCLK) begin
	if (~reset_n) begin
		wr_new_frame	<= 0;
		frame_wr_state		<= 'b0;
		pre_rCCD_FVAL	<= 0;
	end
	else begin
		pre_rCCD_FVAL	<= rCCD_FVAL;
		pre_sCCD_DVAL	<= sCCD_DVAL;
		
		case (frame_wr_state)
			2'b00: begin
				// Initial, wait for FVAL to go high
				if (		(pre_rCCD_FVAL == 0)
						&&	(rCCD_FVAL == 1))
				begin
					frame_wr_state	<= 2'b01;
				end
				else begin
					frame_wr_state	<= 2'b00;
				end
			end
			2'b10: begin
				// A new frame is started, wait for DVAL to go high
				if (		(pre_sCCD_DVAL == 0)
						&&	(sCCD_DVAL == 1))
				begin
					frame_wr_state	<= 2'b10;
					wr_new_frame	<= 1;
				end
				else begin
					frame_wr_state	<= 2'b01;
				end
			end
			2'b10: begin
				// Deassert the wr_new_frame signal
				wr_new_frame	<= 0;
				frame_wr_state	<= 2'b00;
			end
			default: begin
				wr_new_frame	<= 0;
				frame_wr_state	<= 2'b00;
			end
		endcase
	end
end

// A soft reset, mostly used to count number of pixels
// to generate the frame_done signal
reg			rd_new_frame;
reg	[1:0]	frame_rd_state;
reg			pre_vpg_de;
wire			frame_read_done;

always @(posedge vpg_pclk) begin
	if (~reset_n) begin
		rd_new_frame	<= 0;
		pre_vpg_de		<= 0;
		frame_rd_state	<= 'b0;
	end
	else begin
		pre_vpg_de	<= vpg_de;
		
		case (frame_rd_state)
			2'b00: begin
				// Initial state, wait for the first vpg_de to be high
				if (		(pre_vpg_de == 0)
						&&	(vpg_de	== 1))
				begin
					rd_new_frame	<= 1;
					frame_rd_state	<= 2'b01;
				end
				else begin
					// Wait
					frame_rd_state	<= 2'b00;
				end
			end
			2'b01: begin
				// Deassert rd_new_frame, wait for frame_read_done
				rd_new_frame	<= 0;
				frame_rd_state	<= 2'b10;
			end
			2'b10: begin
				if (frame_read_done == 1) begin
					frame_rd_state	<= 2'b00;
				end
				else begin
					frame_rd_state	<= 2'b10;
				end
			end
			default: begin
				rd_new_frame	<= 0;
				frame_rd_state	<= 2'b00;
			end
		endcase
	end
end

parameter frameSize = 640*320;

ddr2_buffer  #(.frameSize(frameSize))
u8
(
	.d5m_clk(~GPIO1_PIXLCLK),
	.ctrl_clk(OSC2_50),//use 50MHz for now, should use a faster one
	.dvi_clk(vpg_pclk),
	
	.reset_n(reset_n),
	.wr_new_frame(wr_new_frame),
	.rd_new_frame(rd_new_frame),
	
	
	// Write side
	.iData({2'b0,sCCD_R[11:2], sCCD_G[11:2], sCCD_B[11:2]}),
	//.iData(iData),
	.iValid(sCCD_DVAL),
		
	.read_init(vpg_de),
	//.read_init(read_init),
	.read_rstn(read_rstn),
	.oData(Read_DATA),
	.frame_read_done(frame_read_done),
	
	// Debug
	.read_empty_rdfifo(read_empty_rdfifo),
	.write_full_rdfifo(write_full_rdfifo),
	.read_empty_wrfifo(read_empty_wrfifo),
	.write_full_wrfifo(write_full_wrfifo),
	
	.write_fifo_wrusedw(write_fifo_wrusedw),
	.write_fifo_rdusedw(write_fifo_rdusedw),
	.read_fifo_wrusedw(read_fifo_wrusedw),
	.read_fifo_rdusedw(read_fifo_rdusedw)
);


// CRITICAL SECTION FOR DDR2 ENDS
// =========================================================

								 
								 
//D5M I2C control
I2C_CCD_Config u10(
	//	Host Side
	.iCLK(OSC2_50),
	.iRST_N(DLY_RST_2),
	.iZOOM_MODE_SW(SW[1]),
	.iEXPOSURE_ADJ(Button[1]),
	.iEXPOSURE_DEC_p(SW[0]),							
	
	//	I2C Side
	.I2C_SCLK(GPIO1_SCLK),
	.I2C_SDAT(GPIO1_SDATA)
);



//	System  generate
sys_pll sys_pll_inst(
	.areset(1'b0),
	.inclk0(OSC2_50),
	.c0(pll_100M),
	.c1(pll_100K),
	.c2(GPIO1_XCLKIN),//25M 
	.locked(reset_n_dvi)
	);

//---------------------------------------------------//
//				DVI Mode Change Button Monitor 			 //
//---------------------------------------------------//
wire		[3:0]	vpg_mode;	
/*`ifdef SXGA_1280x1024p60
	assign vpg_mode = `MODE_1280x1024;
`else
*/
    assign vpg_mode = `VGA_640x480p60;
//`endif


// Note: only for DVI testing purpose
//----------------------------------------------//
// 			 Video Pattern Generator	  	   	//
//----------------------------------------------//
wire [3:0]	vpg_disp_mode;
wire [1:0]	vpg_disp_color;

wire vpg_pclk;
wire vpg_de;
wire vpg_hs;
wire vpg_vs;
wire [23:0]	vpg_data;

vpg	vpg_inst(
	.clk_100(pll_100M),
	.reset_n(read_rstn & reset_n_dvi),//
	//.reset_n(reset_n_dvi),
	.mode(vpg_mode),
	.mode_change(1'b0),
	.disp_color(`COLOR_RGB444),       
	.vpg_pclk(vpg_pclk),
	.vpg_de(vpg_de),
	.vpg_hs(vpg_hs),
	.vpg_vs(vpg_vs),
	.vpg_r(vpg_data[23:16]), //
	.vpg_g(vpg_data[15:8]), //
	.vpg_b(vpg_data[7:0]) //
);


//----------------------------------------------//
// 			 DVI TX                 	  	   	//
//----------------------------------------------//
//=============== DVI TX CONFIG ==================
assign HSTCC_DVI_TX_ISEL 	= 1'b0; 	// disable i2c
assign HSTCC_DVI_TX_SCL 	= 1'b1; 	// BSEL=0, 12-bit, dual-edge input
assign HSTCC_DVI_TX_HTPLG 	= 1'b1; 	// Note. *** EDGE=1, primary latch to occur on the rising edge of the input clock IDCK+
assign HSTCC_DVI_TX_SDA 	= 1'b1;  	// DSEL=X (VREF=3.3V)
assign HSTCC_TX_PD_N 		= 1;


//DVI Signal
assign HSTCC_DVI_TX_DE = vpg_de;
assign HSTCC_DVI_TX_HS = vpg_hs;
assign HSTCC_DVI_TX_VS = vpg_vs;
assign HSTCC_DVI_TX_CLK = vpg_pclk;

//DVI data source selection via SW[0], vpg_data = {R,G,B}
//assign HSTCC_DVI_TX_D = SW[0] ? {Read_DATA2[9:2],Read_DATA1[14:10],Read_DATA2[14:12],Read_DATA1[9:2]} : vpg_data;

// Note: only testing switch with unbuffered RGB values from the sensor
//assign HSTCC_DVI_TX_D = SW[0] ? {sCCD_R[11:4], sCCD_G[11:4], sCCD_B[11:4]} : vpg_data;
assign HSTCC_DVI_TX_D = SW[0] ? {Read_DATA[29:22], Read_DATA[19:12], Read_DATA[9:2]} : vpg_data;

// Note: only testing video pattern
//assign HSTCC_DVI_TX_D = vpg_data;



//=======================================================
//  IO Group Voltage Configuration (Do not modify it)
//=======================================================
IOV_A3V3_B1V8_C3V3_D3V3 IOV_Instance(
	.iCLK(OSC2_50),
	.iRST_n(1'b1),
	.iENABLE(1'b0),
	.oREADY(),
	.oERR(),
	.oERRCODE(),
	.oJVC_CLK(JVC_CLK),
	.oJVC_CS(JVC_CS),
	.oJVC_DATAOUT(JVC_DATAOUT),
	.iJVC_DATAIN(JVC_DATAIN)
);


endmodule
