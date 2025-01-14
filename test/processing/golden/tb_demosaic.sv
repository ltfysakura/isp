`timescale 1ns/1ns

localparam	width				= 320;
localparam	height			= 240;
localparam	totalPixels		= width * height;
localparam	totalInFilter	= (width + 2) * (height + 2);

// TODO: add pading bytes if need be, not necessary for 240p

module tb();

// Input/output of the ISP
logic 						clk;
logic 						reset;
logic							iValid;
logic	unsigned [7:0]		iData;

// Demosaic
logic	unsigned [7:0]		oR, oG, oB;
logic							oValidDemosaic;
logic							oDoneDemosaic;

// Filter
logic	unsigned	[23:0]	oDataFilter;
logic							oValidFilter;
logic							oDoneFilter;

// rgb2ycc
logic	signed	[17:0]	y, cb, cr;
logic							oValidYcc;
logic							oDoneYcc;

// Input/output array from file
// Use filter data size to test filter only!
logic unsigned	[7:0]		rOrig [totalInFilter - 1:0];
logic unsigned	[7:0]		gOrig [totalInFilter - 1:0];
logic unsigned	[7:0]		bOrig [totalInFilter - 1:0];
// This is RAW data
logic unsigned	[7:0]		raw	[totalInFilter - 1:0];

logic unsigned	[7:0]		rDemosaic [totalPixels-1:0];
logic unsigned	[7:0]		gDemosaic [totalPixels-1:0];
logic unsigned	[7:0]		bDemosaic [totalPixels-1:0];

logic unsigned	[7:0]		rFilter [totalPixels-1:0];
logic unsigned	[7:0]		gFilter [totalPixels-1:0];
logic unsigned	[7:0]		bFilter [totalPixels-1:0];

logic unsigned	[17:0]	yMatrix [totalPixels-1:0];
logic unsigned	[17:0]	cbMatrix [totalPixels-1:0];
logic unsigned	[17:0]	crMatrix [totalPixels-1:0];

processing #(.width(width),	.height(height))
dut ( .* );

initial clk = '1;
always #2.5 clk = ~clk;  // 200 MHz clock

logic unsigned	[7:0]		iR;
logic unsigned	[7:0]		iG;
logic unsigned	[7:0]		iB;

// Producer
initial begin
	integer r_inFile;
	integer g_inFile;
	integer b_inFile;
	
	r_inFile = $fopen("rOrig", "r");
	g_inFile = $fopen("gOrig", "r");
	b_inFile = $fopen("bOrig", "r");

	for (int i = 0; i < totalPixels; i++) begin
		integer in1, in2, in3;
		
		// Read from file
		in1 = $fscanf(r_inFile, "%d", rOrig[i]);
		in2 = $fscanf(g_inFile, "%d", gOrig[i]);
		in3 = $fscanf(b_inFile, "%d", bOrig[i]);
	end
	
	for (int i = 0; i < totalPixels; i++) begin
		if ((i / width) % 2 == 0) begin
			// Even row, G B G B ......
			if ((i % width) % 2 == 0) begin
				// Even col
				raw[i] = gOrig[i];
			end
			else begin
				raw[i] = bOrig[i];
			end
		end
		else begin
			// Debug
			if (i == totalPixels-1)begin
				i = totalPixels-1;
			end
			
			// Odd row, R G R G ......
			if ((i % width) % 2 == 0) begin
				// Even col
				raw[i] = rOrig[i];
			end
			else begin
				raw[i] = gOrig[i];
			end
			
			// Debug
//			if (i > totalPixels - 3) begin
//				$display("i = %d, gOrig[i] = %d, raw[i] = %d", i, gOrig[i], raw[i]);
//			end			
		end
	end
		
//	// Feeding filter
//	for (int i = 0; i < totalInFilter; i++) begin
//		integer in1, in2, in3;
//		if (		(i < width + 2)
//			 ||	(i > totalInFilter - width - 2)
//			 ||	((i % (width + 2)) == 0)
//			 ||	((i % (width + 2)) == (width + 1)))
//		begin
//			rOrig[i] = 8'b0;
//			gOrig[i] = 8'b0;
//			bOrig[i] = 8'b0;
//		end
//		else begin
//			// Read from file
//			in1 = $fscanf(r_inFile, "%d", rOrig[i]);
//			in2 = $fscanf(g_inFile, "%d", gOrig[i]);
//			in3 = $fscanf(b_inFile, "%d", bOrig[i]);
//			
//			// Debug
////			if (i > 76000) begin
////				$display("in1 = %d, data[%d] = %d, in2 = %d, data[%d] = %d, in3 = %d, data[%d] = %d",
////							in1, i, rOrig[i], in2, i, gOrig[i], in3, i, bOrig[i]);
////			end
//		end
//	end
	
	$fclose(r_inFile);
	$fclose(g_inFile);
	$fclose(b_inFile);
	
	iValid = 1'b0;
	iData = 'd0;
	
	reset = 1'b1;
	@(negedge clk);
	@(negedge clk);
	reset = 1'b0;	
	@(negedge clk);
	
	// RGB
	for (int i = 0; i < totalPixels; i++) begin
		//iData	= {rOrig[i], gOrig[i], bOrig[i]};
		iData = raw[i];
		
		iR	= rOrig[i];
		iG	= gOrig[i];
		iB	= bOrig[i];
		iValid	= 1'b1;
		@(negedge clk);
	end
	
	iData = 'b0;
	
	// Need iValid to be high to keep the pipeline moving
	while(1) begin
		@(negedge clk);
		if (oDoneDemosaic == 0) begin
			iValid	= 1'b1;
		end
		else begin
			// Image done, should be automatically reset
			// .(reset|yccDone)
			iValid	= 1'b0;
			break;
		end
	end
	
	@(negedge clk);
	reset = 1'b0;
	
	@(negedge clk);
	reset = 1'b0;
end

logic unsigned	[7:0]		g_demosaic_r, g_demosaic_g, g_demosaic_b;

// Demosaic Consumer
initial begin
	integer r_outFile;
	integer g_outFile;
	integer b_outFile;
	
	integer failed = 0;
	
	r_outFile = $fopen("demosaicROut", "r");
	g_outFile = $fopen("demosaicGOut", "r");
	b_outFile = $fopen("demosaicBOut", "r");
	
	for (int i = 0; i < totalPixels; i++) begin
		integer out1, out2, out3;
		out1 = $fscanf(r_outFile, "%d", rDemosaic[i]);
		out2 = $fscanf(g_outFile, "%d", gDemosaic[i]);
		out3 = $fscanf(b_outFile, "%d", bDemosaic[i]);
		//$display("d = %d, data[%d] = %d", d, i, o_data_arr[i]);
	end
	$fclose(r_outFile);
	$fclose(g_outFile);
	$fclose(b_outFile);
	
	for (int i = 0; i < totalPixels; i++) begin
		real rDiff;
		real gDiff;
		real bDiff;
		
		// Wait for a valid output
		@(negedge clk);
		while (!oValidDemosaic) begin
			@(negedge clk);
		end
		
		g_demosaic_r 	= rDemosaic[i];
		g_demosaic_g	= gDemosaic[i];
		g_demosaic_b	= bDemosaic[i];
		
		rDiff = (oR - g_demosaic_r);
		gDiff = (oG - g_demosaic_g);
		bDiff = (oB - g_demosaic_b);
		
		if ((rDiff != 0) || (gDiff != 0) || (bDiff != 0)) begin
			$display("<Demosaic> r: %f, r_golden: %f; g: %f, g_golden: %f; b: %f, b_golden: %f, at time: ",
						oR, g_demosaic_r, oG, g_demosaic_g, oB, g_demosaic_b, $time);
			failed = 1;
		end
	end
	
	if (failed == 1) begin
		$display("Demosaic is wrong");
	end
	else begin
		$display("Demosaic great success!!");
	end
	
	for (int i = 0; i < 10; i++) begin
		@(negedge clk);
	end
	
	$stop(0);
end


//logic unsigned	[23:0]	o_golden_filter;
//logic unsigned	[7:0]		filter_r, filter_g, filter_b;
//logic unsigned	[7:0]		g_filter_r, g_filter_g, g_filter_b;
//
//// Filter Consumer
//initial begin
//	static real rms = 0.0;
//	static integer tmp = 0;
//	
//	integer r_outFile;
//	integer g_outFile;
//	integer b_outFile;
//	
//	r_outFile = $fopen("sharpenROut", "r");
//	g_outFile = $fopen("sharpenGOut", "r");
//	b_outFile = $fopen("sharpenBOut", "r");
//	
//	for (int i = 0; i < totalPixels; i++) begin
//		integer out1, out2, out3;
//		out1 = $fscanf(r_outFile, "%d", rFilter[i]);
//		out2 = $fscanf(g_outFile, "%d", gFilter[i]);
//		out3 = $fscanf(b_outFile, "%d", bFilter[i]);
//		//$display("d = %d, data[%d] = %d", d, i, o_data_arr[i]);
//	end
//	$fclose(r_outFile);
//	$fclose(g_outFile);
//	$fclose(b_outFile);
//	
//	o_golden_filter = 'b0;
//	
//	// RGB
//	for (int i = 0; i < totalPixels; i++) begin
//		real v1;
//		real v2;
//		real diff;
//		
//		// Wait for a valid output
//		@(negedge clk);
//		while (!oValidFilter) begin
//			@(negedge clk);
//		end
//		
//		//@(negedge clk);  // Give time for o_out to be updated.
//		v1 = real'(oDataFilter);
//		o_golden_filter = {rFilter[i], gFilter[i], bFilter[i]};
//		
//		filter_r		= oDataFilter[23:16];
//		filter_g		= oDataFilter[15:8];
//		filter_b		= oDataFilter[7:0];
//
//		g_filter_r	= rFilter[i];
//		g_filter_g	= gFilter[i];
//		g_filter_b	= bFilter[i];
//		
//		v2 = real'(o_golden_filter);
//		diff = (v1 - v2);
//		
//		rms += diff*diff;
//		if (diff != 0) begin
//			$display("<Filter> diff: %f, rms: %f, o_out: %f, golden: %f, at time: ", diff, rms, v1, v2, $time);
//		end
//	end
//	
//	rms /= totalPixels;
//	rms = rms ** (0.5);
//	
//	$display("<Filter> RMS Error: %f", rms);
//	if (rms > 10) begin
//		$display("<Filter> Average RMS Error is above 10 units - something is probably wrong");
//	end
//	else begin
//		$display("<Filter> Error is within 10 units - great success!!");
//	end
//	
//	for (int i = 0; i < 10; i++) begin
//		@(negedge clk);
//	end
//	
//	rms = 0;
//	$stop(0);
//end
//
//logic unsigned	[53:0]	o_golden_ycc;
//logic signed	[17:0]	g_ycc_y, g_ycc_cb, g_ycc_cr;
//
//// YCC Consumer
//initial begin
//	static real rms = 0.0;
//	static integer tmp = 0;
//	
//	integer r_outFile;
//	integer g_outFile;
//	integer b_outFile;
//	
//	r_outFile = $fopen("yOut", "r");
//	g_outFile = $fopen("cbOut", "r");
//	b_outFile = $fopen("crOut", "r");
//	
//	for (int i = 0; i < totalPixels; i++) begin
//		integer out1, out2, out3;
//		out1 = $fscanf(r_outFile, "%d", yMatrix[i]);
//		out2 = $fscanf(g_outFile, "%d", cbMatrix[i]);
//		out3 = $fscanf(b_outFile, "%d", crMatrix[i]);
//		//$display("d = %d, data[%d] = %d", d, i, o_data_arr[i]);
//	end
//	$fclose(r_outFile);
//	$fclose(g_outFile);
//	$fclose(b_outFile);
//	
//	o_golden_ycc = 'b0;
//	
//	// YCC
//	for (int i = 0; i < totalPixels; i++) begin
//		real v1;
//		real v2;
//		real diff;
//		
//		// Wait for a valid output
//		@(negedge clk);
//		while (!oValidYcc) begin
//			@(negedge clk);
//		end
//		
//		//@(negedge clk);  // Give time for o_out to be updated.
//		v1 = real'({y, cb, cr});
//		o_golden_ycc = {yMatrix[i], cbMatrix[i], crMatrix[i]};		
//		
//		g_ycc_y 	= yMatrix[i];
//		g_ycc_cb	= cbMatrix[i];
//		g_ycc_cr	= crMatrix[i];
//		
//		v2 = real'(o_golden_ycc);
//		diff = (v1 - v2);
//		
//		rms += diff*diff;
//		if (diff != 0) begin
//			$display("<YCC> diff: %f, rms: %f, o_out: %f, golden: %f, at time: ", diff, rms, v1, v2, $time);
//		end
//	end
//	
//	rms /= totalPixels;
//	rms = rms ** (0.5);
//	
//	$display("<YCC> RMS Error: %f", rms);
//	if (rms > 10) begin
//		$display("<YCC> Average RMS Error is above 10 units - something is probably wrong");
//	end
//	else begin
//		$display("<YCC> Error is within 10 units - great success!!");
//	end
//	
//	for (int i = 0; i < 10; i++) begin
//		@(negedge clk);
//	end
//	
//	rms = 0;
//	
//	$stop(0);
//end







endmodule
