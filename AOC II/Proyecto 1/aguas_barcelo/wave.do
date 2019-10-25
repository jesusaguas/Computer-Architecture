onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/uut/clk
add wave -noupdate /testbench/uut/reset
add wave -noupdate /testbench/uut/load_PC
add wave -noupdate /testbench/uut/PCSrc
add wave -noupdate /testbench/uut/RegWrite_ID
add wave -noupdate /testbench/uut/RegWrite_EX
add wave -noupdate /testbench/uut/RegWrite_MEM
add wave -noupdate -color {Cornflower Blue} -itemcolor {Midnight Blue} /testbench/uut/RegWrite_WB
add wave -noupdate -color {Cornflower Blue} -itemcolor {Midnight Blue} /testbench/uut/Register_bank/reg_file
add wave -noupdate /testbench/uut/Update_Rs_ID
add wave -noupdate /testbench/uut/Update_Rs_EX
add wave -noupdate /testbench/uut/Update_Rs_Mem
add wave -noupdate /testbench/uut/Update_Rs_WB
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/PC4
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/branch_address_out
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/prediction_out
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/PC4_ID
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/prediction_in
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/branch_address_in
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/update
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/valid
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/prediction
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/tag
add wave -noupdate -color {Blue Violet} -itemcolor Thistle /testbench/uut/b_predictor/address
add wave -noupdate /testbench/uut/DirSalto_ID
add wave -noupdate /testbench/uut/IR_bancoID_in
add wave -noupdate /testbench/uut/prediction_ID
add wave -noupdate /testbench/uut/predictor_error
add wave -noupdate /testbench/uut/address_error
add wave -noupdate /testbench/uut/decission_error
add wave -noupdate /testbench/uut/saltar
add wave -noupdate /testbench/uut/Reg_RS_EX
add wave -noupdate /testbench/uut/Reg_RS_MEM
add wave -noupdate /testbench/uut/Reg_RS_WB
add wave -noupdate /testbench/uut/Z
add wave -noupdate /testbench/uut/Branch
add wave -noupdate /testbench/uut/RegDst_ID
add wave -noupdate /testbench/uut/RegDst_EX
add wave -noupdate /testbench/uut/ALUSrc_ID
add wave -noupdate /testbench/uut/ALUSrc_EX
add wave -noupdate /testbench/uut/MemtoReg_ID
add wave -noupdate /testbench/uut/MemtoReg_EX
add wave -noupdate /testbench/uut/MemtoReg_MEM
add wave -noupdate /testbench/uut/MemtoReg_WB
add wave -noupdate /testbench/uut/MemWrite_ID
add wave -noupdate /testbench/uut/MemWrite_EX
add wave -noupdate -color Salmon -itemcolor Salmon /testbench/uut/MemWrite_MEM
add wave -noupdate /testbench/uut/Mem_D/RAM
add wave -noupdate /testbench/uut/MemRead_ID
add wave -noupdate /testbench/uut/MemRead_EX
add wave -noupdate /testbench/uut/MemRead_MEM
add wave -noupdate /testbench/uut/PC_in
add wave -noupdate -color {Blue Violet} -itemcolor {Blue Violet} -radix decimal /testbench/uut/PC_out
add wave -noupdate /testbench/uut/four
add wave -noupdate /testbench/uut/PC4
add wave -noupdate /testbench/uut/IR_in
add wave -noupdate -color Tan -itemcolor Goldenrod /testbench/uut/IR_ID
add wave -noupdate /testbench/uut/PC4_ID
add wave -noupdate /testbench/uut/inm_ext_EX
add wave -noupdate /testbench/uut/Mux_out
add wave -noupdate /testbench/uut/BusW
add wave -noupdate /testbench/uut/BusA
add wave -noupdate /testbench/uut/BusB
add wave -noupdate /testbench/uut/BusA_EX
add wave -noupdate /testbench/uut/BusB_EX
add wave -noupdate /testbench/uut/BusB_MEM
add wave -noupdate /testbench/uut/inm_ext
add wave -noupdate /testbench/uut/inm_ext_x4
add wave -noupdate /testbench/uut/ALU_out_EX
add wave -noupdate /testbench/uut/ALU_out_MEM
add wave -noupdate /testbench/uut/ALU_out_WB
add wave -noupdate /testbench/uut/Mem_out
add wave -noupdate /testbench/uut/MDR
add wave -noupdate /testbench/uut/RW_EX
add wave -noupdate /testbench/uut/RW_MEM
add wave -noupdate /testbench/uut/RW_WB
add wave -noupdate /testbench/uut/Reg_Rd_EX
add wave -noupdate /testbench/uut/Reg_Rt_EX
add wave -noupdate /testbench/uut/ALUctrl_ID
add wave -noupdate /testbench/uut/ALUctrl_EX
add wave -noupdate /testbench/clk
add wave -noupdate -color {Blue Violet} -itemcolor {Blue Violet} -radix decimal /testbench/uut/PC_out
add wave -noupdate -color Yellow -radix decimal /testbench/uut/ALU_MIPs/DA
add wave -noupdate -color Yellow -radix decimal /testbench/uut/ALU_MIPs/DB
add wave -noupdate -color Yellow -radix decimal /testbench/uut/ALU_MIPs/ALUctrl
add wave -noupdate -color Yellow -radix decimal /testbench/uut/ALU_MIPs/Dout
add wave -noupdate -color Red -radix decimal /testbench/uut/Mem_D/ADDR
add wave -noupdate -color Red -radix decimal /testbench/uut/Mem_D/Din
add wave -noupdate -color Red -radix decimal /testbench/uut/Mem_D/WE
add wave -noupdate -color Red -radix decimal /testbench/uut/Mem_D/RE
add wave -noupdate -color Red -radix decimal /testbench/uut/Mem_D/Dout
add wave -noupdate -color Magenta -radix decimal /testbench/uut/Register_bank/RA
add wave -noupdate -color Magenta -radix decimal /testbench/uut/Register_bank/RB
add wave -noupdate -color Magenta -radix decimal /testbench/uut/Register_bank/BusA
add wave -noupdate -color Magenta -radix decimal /testbench/uut/Register_bank/BusB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 270
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {158 ns}
