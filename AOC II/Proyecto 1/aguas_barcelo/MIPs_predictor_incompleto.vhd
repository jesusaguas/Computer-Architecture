----------------------------------------------------------------------------------
-- Description: Mips segmentado tal y como lo hemos estudiado en clase. Sus caracter�sticas son:
-- Saltos 1-retardados
-- instrucciones aritm�ticas, LW, SW y BEQ
-- MI y MD de 128 palabras de 32 bits
-- Registro de salida de 32 bits mapeado en la direcci�n FFFFFFFF. Si haces un SW en esa direcci�n se escribe en este registro y no en la memoria
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MIPs_segmentado is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  output : out  STD_LOGIC_VECTOR (31 downto 0));
end MIPs_segmentado;

architecture Behavioral of MIPs_segmentado is
component reg32 is
    Port ( Din : in  STD_LOGIC_VECTOR (31 downto 0);
           clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
           load : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;
---------------------------------------------------------------
-- Interfaz del componente que debeis disenar
component branch_predictor is
 Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
 			-- Puerto de lectura se accede con los 8 bits menos significativos de PC+4 sumado en IF
			PC4 : in  STD_LOGIC_VECTOR (7 downto 0);
			branch_address_out : out  STD_LOGIC_VECTOR (31 downto 0); -- direcci�n de salto
			prediction_out : out  STD_LOGIC; -- indica si hay que saltar a la direcci�n de salto (1) o no (0)
         	-- Puerto de escritura se env�a PC+4, la direcci�n de salto y la predicci�n, y se activa la se�al update_prediction
			PC4_ID:  in  STD_LOGIC_VECTOR (7 downto 0); -- Etiqueta: 8 bits menos significativos del PC+4 de la etapa ID
			prediction_in : in  STD_LOGIC; -- predicci�n
			branch_address_in : in  STD_LOGIC_VECTOR (31 downto 0); -- direcci�n de salto
       	update:  in  STD_LOGIC); -- da la orden de actualizar la informaci�n del predictor
end component;
--------------------------------------------------------------
component adder32 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component mux2_1 is
  Port (  DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
          DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
		  ctrl : in  STD_LOGIC;
          Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component mux4_1 is
  Port (   DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn2 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn3 : in  STD_LOGIC_VECTOR (31 downto 0);
		   ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component memoriaRAM_D is port (
		CLK : in std_logic;
		ADDR : in std_logic_vector (31 downto 0); --Dir
        Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        WE : in std_logic;		-- write enable
		RE : in std_logic;		-- read enable
		Dout : out std_logic_vector (31 downto 0));
end component;

component memoriaRAM_I is port (
		CLK : in std_logic;
		ADDR : in std_logic_vector (31 downto 0); --Dir
        Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        WE : in std_logic;		-- write enable
		RE : in std_logic;		-- read enable
		Dout : out std_logic_vector (31 downto 0));
end component;

component Banco_ID is
 Port ( IR_in : in  STD_LOGIC_VECTOR (31 downto 0); -- instrucci�n leida en IF
        PC4_in:  in  STD_LOGIC_VECTOR (31 downto 0); -- PC+4 sumado en IF
		-- se�ales de la predicci�n de salto (direcci�n y predicci�n)
        address_predicted : in  STD_LOGIC_VECTOR (31 downto 0);
        prediction: in  STD_LOGIC;
		  clk : in  STD_LOGIC;
		  reset : in  STD_LOGIC;
        load : in  STD_LOGIC;
        IR_ID : out  STD_LOGIC_VECTOR (31 downto 0); -- instrucci�n en la etapa ID
        PC4_ID:  out  STD_LOGIC_VECTOR (31 downto 0);-- PC+4 en la etapa ID
        address_predicted_ID : out  STD_LOGIC_VECTOR (31 downto 0);
        prediction_ID: out  STD_LOGIC);
end component;

component BReg is
port (
        clk : in std_logic;
		reset : in std_logic;
        RA : in std_logic_vector (4 downto 0); --Dir para el puerto de lectura A
        RB : in std_logic_vector (4 downto 0); --Dir para el puerto de lectura A
        RW : in std_logic_vector (4 downto 0); --Dir para el puerto de escritura
        BusW : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        RegWrite : in std_logic;
        BusA : out std_logic_vector (31 downto 0);
        BusB : out std_logic_vector (31 downto 0)
    );
end component;

component Ext_signo is
    Port ( inm : in  STD_LOGIC_VECTOR (15 downto 0);
           inm_ext : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component two_bits_shifter is
    Port ( Din : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component UC is
   Port ( IR_op_code : in  STD_LOGIC_VECTOR (5 downto 0);
           Branch : out  STD_LOGIC;
           RegDst : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           MemWrite : out  STD_LOGIC;
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC
           );
end component;

COMPONENT Banco_EX
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         load : IN  std_logic;
         busA : IN  std_logic_vector(31 downto 0);
         busB : IN  std_logic_vector(31 downto 0);
         busA_EX : OUT  std_logic_vector(31 downto 0);
         busB_EX : OUT  std_logic_vector(31 downto 0);
		 inm_ext: IN  std_logic_vector(31 downto 0);
		 inm_ext_EX: OUT  std_logic_vector(31 downto 0);
         RegDst_ID : IN  std_logic;
         ALUSrc_ID : IN  std_logic;
         MemWrite_ID : IN  std_logic;
         MemRead_ID : IN  std_logic;
         MemtoReg_ID : IN  std_logic;
         RegWrite_ID : IN  std_logic;
         RegDst_EX : OUT  std_logic;
         ALUSrc_EX : OUT  std_logic;
         MemWrite_EX : OUT  std_logic;
         MemRead_EX : OUT  std_logic;
         MemtoReg_EX : OUT  std_logic;
         RegWrite_EX : OUT  std_logic;
		 ALUctrl_ID: in STD_LOGIC_VECTOR (2 downto 0);
		 ALUctrl_EX: out STD_LOGIC_VECTOR (2 downto 0);
-- Nuevo (para la anticipacion)
		 Reg_Rs_ID : IN  std_logic_vector(4 downto 0);
		 Reg_Rs_EX : OUT  std_logic_vector(4 downto 0);
----------------------
         Reg_Rt_ID : IN  std_logic_vector(4 downto 0);
         Reg_Rd_ID : IN  std_logic_vector(4 downto 0);
         Reg_Rt_EX : OUT  std_logic_vector(4 downto 0);
         Reg_Rd_EX : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
-- Unidad de anticipacion de operandos
    COMPONENT UA
	Port(
			Reg_Rs_EX: IN  std_logic_vector(4 downto 0);
			Reg_Rt_EX: IN  std_logic_vector(4 downto 0);
			RegWrite_MEM: IN std_logic;
			RW_MEM: IN  std_logic_vector(4 downto 0);
			RegWrite_WB: IN std_logic;
			RW_WB: IN  std_logic_vector(4 downto 0);
			MUX_ctrl_A: out std_logic_vector(1 downto 0);
			MUX_ctrl_B: out std_logic_vector(1 downto 0)
		);
	end component;
-- Mux 4 a 1
	component mux4_1_32bits is
	Port ( DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
		   DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
		   DIn2 : in  STD_LOGIC_VECTOR (31 downto 0);
		   DIn3 : in  STD_LOGIC_VECTOR (31 downto 0);
		   ctrl : in  std_logic_vector(1 downto 0);
		   Dout : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
    COMPONENT ALU
    PORT(
         DA : IN  std_logic_vector(31 downto 0);
         DB : IN  std_logic_vector(31 downto 0);
         ALUctrl : IN  std_logic_vector(2 downto 0);
         Dout : OUT  std_logic_vector(31 downto 0)
               );
    END COMPONENT;

	 component mux2_5bits is
		  Port (  DIn0 : in  STD_LOGIC_VECTOR (4 downto 0);
				  DIn1 : in  STD_LOGIC_VECTOR (4 downto 0);
				  ctrl : in  STD_LOGIC;
				  Dout : out  STD_LOGIC_VECTOR (4 downto 0));
		end component;

	 component mux2_6bits is
		  Port (  DIn0 : in  STD_LOGIC_VECTOR (5 downto 0);
				  DIn1 : in  STD_LOGIC_VECTOR (5 downto 0);
				  ctrl : in  STD_LOGIC;
				  Dout : out  STD_LOGIC_VECTOR (5 downto 0));
		end component;

COMPONENT Banco_MEM
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         load : IN  std_logic;
		 ALU_out_EX : IN  std_logic_vector(31 downto 0);
         ALU_out_MEM : OUT  std_logic_vector(31 downto 0);
         MemWrite_EX : IN  std_logic;
         MemWrite_MEM : OUT  std_logic;
		 MemRead_EX : IN  std_logic;
         MemRead_MEM : OUT  std_logic;
		 MemtoReg_EX : IN  std_logic;
         MemtoReg_MEM : OUT  std_logic;
		 RegWrite_EX : IN  std_logic;
         RegWrite_MEM : OUT  std_logic;
         BusB_EX : IN  std_logic_vector(31 downto 0);
         BusB_MEM : OUT  std_logic_vector(31 downto 0);
         RW_EX : IN  std_logic_vector(4 downto 0);
         RW_MEM : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;

    COMPONENT Banco_WB
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         load : IN  std_logic;
		 ALU_out_MEM : IN  std_logic_vector(31 downto 0);
         ALU_out_WB : OUT  std_logic_vector(31 downto 0);
         MEM_out : IN  std_logic_vector(31 downto 0);
         MDR : OUT  std_logic_vector(31 downto 0);
         MemtoReg_MEM : IN  std_logic;
		 MemtoReg_WB : OUT  std_logic;
		 RegWrite_MEM : IN  std_logic;
         RegWrite_WB : OUT  std_logic;
         RW_MEM : IN  std_logic_vector(4 downto 0);
         RW_WB : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;

signal load_PC, RegWrite_ID, RegWrite_EX, RegWrite_MEM, RegWrite_WB, Z, Branch, RegDst_ID, RegDst_EX, ALUSrc_ID, ALUSrc_EX, ctrldirsSalto: std_logic;
signal MemtoReg_ID, MemtoReg_EX, MemtoReg_MEM, MemtoReg_WB, MemWrite_ID, MemWrite_EX, MemWrite_MEM, MemRead_ID, MemRead_EX, MemRead_MEM: std_logic;
signal PC_in, PC_out, four, cero, PC4, DirSalto_ID, IR_in, IR_ID, PC4_ID, inm_ext_EX, Mux_out, IR_bancoID_in, dirSalto : std_logic_vector(31 downto 0);
signal BusW, BusA, BusB, BusA_EX, BusB_EX, BusB_MEM, inm_ext, inm_ext_x4, ALU_out_EX, ALU_out_MEM, ALU_out_WB, Mem_out, MDR, address_predicted, address_predicted_ID, branch_address_in : std_logic_vector(31 downto 0);
signal prediction, prediction_in, update_predictor, prediction_ID, predictor_error, address_error, decission_error, saltar : std_logic;
signal riesgo_beq, riesgo_beq_rt_d2, riesgo_beq_rt_d1, riesgo_beq_rs_d2, riesgo_beq_rs_d1, riesgo_lw_uso, riesgo_rt_lw_uso, riesgo_rs_lw_uso, avanzar_ID, riesgo_datos: std_logic;
signal RW_EX, RW_MEM, RW_WB, Reg_Rd_EX, Reg_Rt_EX, Reg_Rs_EX, Reg_Rs_ID,Reg_Rt_ID: std_logic_vector(4 downto 0);
signal controlSignalsBefore, controlSignalsAfter: std_logic_vector(5 downto 0);
signal ALUctrl_ID, ALUctrl_EX : std_logic_vector(2 downto 0);
signal Op_code_ID: std_logic_vector(5 downto 0);
signal PCSrc: std_logic_vector(1 downto 0);
signal MUX_ctrl_A, MUX_ctrl_B : std_logic_vector(1 downto 0);
signal Mux_A_out, Mux_B_out: std_logic_vector(31 downto 0);
begin
pc: reg32 port map (	Din => PC_in, clk => clk, reset => reset, load => load_PC, Dout => PC_out);

load_PC <= avanzar_ID; -- Si paramos en ID, hay que parar tambi�n en IF

four <= "00000000000000000000000000000100";
cero <= "00000000000000000000000000000000";


adder_4: adder32 port map (Din0 => PC_out, Din1 => four, Dout => PC4);

b_predictor: branch_predictor port map ( 	clk => clk, reset => reset,
											PC4 => PC4(9 downto 2),
											branch_address_out => address_predicted,
											prediction_out => prediction,
         									PC4_ID => PC4_ID(9 downto 2),
											prediction_in => prediction_in,
											branch_address_in => branch_address_in,
       										update => update_predictor);

------------------------------------
-- Prediccion de saltos: MUX para elegir la proxima instruccion
-- A este Mux le llegan 4 opciones:
-- 	PC4: PC actual +4                                                           --Cuando no hay que  saltar y el predictor dice : NO SALTAR
-- 	@address_predicted: la direcci�n de saltoque proporciona el predictor      --Cuando hay que saltar y el predictor dice: SALTAR
--	PC4_ID: el PC +4 de la instrucci�n que est� en ID                         --Cuando (al comprobar el salto) no habia que saltar pero se ha saltado.
-- 	DirSalto_ID: la direcci�n de salto calculada en la etapa ID                --Cuando (al comprobar el sato) habia que saltar pero no se ha saltado.
-- Inicialmente ponemos la se�al de control (PCSrc) a 0 (�es decir este procesador no salta nunca!), ten�is que dise�ar vosotros la l�gica que gestione bien esta se�al.
PCSrc <= "00" when (prediction = '0' AND predictor_error = '0')
        else "01" when (prediction = '1' AND predictor_error = '0')
        else "10" when (Saltar='0' AND predictor_error = '1')
        else "11";

muxPC: mux4_1 port map (Din0 => PC4, DIn1 => address_predicted, Din2 => PC4_ID, DIn3 => DirSalto_ID, ctrl => PCSrc, Dout => PC_in);
-----------------------------------
Mem_I: memoriaRAM_I PORT MAP (CLK => CLK, ADDR => PC_out, Din => cero, WE => '0', RE => '1', Dout => IR_in);
--------------------------------------------------------------
-- Prediccion de saltos: Anulaci�n de la instrucci�n. Si en ID se detecta un error la instrucci�n que se acaba de leer se anula. Para ello se sustituye su c�digo por el de una nop
-- La siguiente l�nea es un mux descrito de forma funcional
IR_bancoID_in(31 downto 26) <= IR_in(31 downto 26) when (predictor_error='0') else "000000";
IR_bancoID_in(25 downto 0) <= IR_in(25 downto 0);
-----------------------------------------------------------------
-- hay que mandar la info de la predicci�n a la etapa ID para poder comprobar si ha sido acierto o fallo para ello a�adimos dos registros al banco: direcci�n (address_predicted que es la direcci�n que hemos metido en la entrada del PC) y decisi�n (prediction_out)
Banco_IF_ID: Banco_ID port map (	IR_in => IR_bancoID_in, PC4_in => PC4, clk => clk, reset => reset, load => avanzar_ID, IR_ID => IR_ID, PC4_ID => PC4_ID,
									address_predicted => PC_in, prediction => prediction, address_predicted_ID => address_predicted_ID, prediction_ID => prediction_ID );
--
------------------------------------------Etapa ID-------------------------------------------------------------------
--
Register_bank: BReg PORT MAP (clk => clk, reset => reset, RA => IR_ID(25 downto 21), RB => IR_ID(20 downto 16),
                              RW => RW_WB, BusW => busW, RegWrite => RegWrite_WB,
                              BusA => BusA, BusB => BusB);

sign_ext: Ext_signo port map (inm => IR_ID(15 downto 0), inm_ext => inm_ext);

two_bits_shift: two_bits_shifter	port map (Din => inm_ext, Dout => inm_ext_x4);

adder_dir: adder32 port map (Din0 => inm_ext_x4, Din1 => PC4_ID, Dout => DirSalto_ID);

Z <= '1' when (busA=busB) else '0';

------------------------------------
-- Riesgos de datos: os damos las se�ales definidas, pero est�n todas a cero, deb�is incluir el c�digo identifica cada riesgo
-- Detectar lw/uso:

Reg_Rs_ID <= IR_ID(25 downto 21);
Reg_Rt_ID <= IR_ID(20 downto 16);

riesgo_rs_lw_uso <= '0' when (Op_code_ID="000000")
                    else '1' when (MemRead_EX='1' AND Reg_Rs_ID=RW_EX)
                    else '0';
riesgo_rt_lw_uso <= '0' when (Op_code_ID="000000")
                    else '1' when (MemRead_EX='1' AND Reg_Rt_ID=RW_EX)
                    else '0';

riesgo_lw_uso <= riesgo_rs_lw_uso or riesgo_rt_lw_uso;

riesgo_datos <= (riesgo_lw_uso OR predictor_error);

muxRiesgoDatos: mux2_6bits port map (Din0 => controlSignalsBefore, DIn1 => cero(5 downto 0), ctrl => riesgo_datos, Dout => controlSignalsAfter);


RegDst_ID <= controlSignalsAfter(5);
ALUSrc_ID <= controlSignalsAfter(4);
MemWrite_ID <= controlSignalsAfter(3);
MemRead_ID <= controlSignalsAfter(2);
MemtoReg_ID <= controlSignalsAfter(1);
RegWrite_ID <= controlSignalsAfter(0);

-- Detectar riesgos en los beq:
riesgo_beq_rs_d1 <= '1' when (Reg_Rs_ID=RW_EX AND RegWrite_EX='1' AND (Op_code_ID="000100" OR Op_code_ID="000101"))
                    else '0';
riesgo_beq_rs_d2 <= '1' when (Reg_Rs_ID=RW_MEM AND RegWrite_MEM='1' AND (Op_code_ID="000100" OR Op_code_ID="000101"))
                    else '0';
riesgo_beq_rt_d1 <= '1' when (Reg_Rt_ID=RW_EX AND RegWrite_EX='1' AND (Op_code_ID="000100" OR Op_code_ID="000101"))
                    else '0';
riesgo_beq_rt_d2 <= '1' when (Reg_Rt_ID=RW_MEM AND RegWrite_MEM='1' AND (Op_code_ID="000100" OR Op_code_ID="000101"))
                    else '0';


riesgo_beq <= riesgo_beq_rs_d1 or riesgo_beq_rs_d2 or riesgo_beq_rt_d1 or riesgo_beq_rt_d2;
-- en funci�n de los riesgos se para o se permite continuar a la instrucci�n en ID

avanzar_ID <= '0' when (riesgo_lw_uso='1' or riesgo_beq='1')
               else '1';

-- Env�o de instrucci�n a EX. Adoptamos una soluci�n sencilla, si hay que parar pasamos hacia adelante las se�ales de control de una nop
Op_code_ID <= IR_ID(31 downto 26);
------------------------------------------------------------

--UC_seg: UC port map (IR_op_code => Op_code_ID, Branch => Branch, RegDst => RegDst_ID,  ALUSrc => ALUSrc_ID, MemWrite => MemWrite_ID,
--							MemRead => MemRead_ID, MemtoReg => MemtoReg_ID, RegWrite => RegWrite_ID);
UC_seg: UC port map (IR_op_code => Op_code_ID, Branch => Branch, RegDst => controlSignalsBefore(5),  ALUSrc => controlSignalsBefore(4), MemWrite => controlSignalsBefore(3),
							MemRead => controlSignalsBefore(2), MemtoReg => controlSignalsBefore(1), RegWrite => controlSignalsBefore(0));

------------------------------------
-- Prediccion de saltos: Comprobar si hab�a que saltar
-- Ahora mismo s�lo esta implementada la instrucci�n de salto BEQ. Si es una instrucci�n de salto y se activa la se�al Z se debe saltar
-- Si se a�aden otras opciones (como BNE) hay que actualizar esto
    Saltar <= '1' when (Branch='1' AND Z='1' AND Op_code_ID="000100" AND avanzar_ID='1')       --Si hay que saltar, son iguales y es BEQ(000100), saltamos
          else '1' when (Branch='1' AND Z='0' AND Op_code_ID="000101" AND avanzar_ID='1')  --Si hay que saltar, son distintos y es BNE(000101), saltamos
          else '0';
------------------------------------
-- Prediccion de saltos: Comprobaci�n de la predicci�n realizada:
-- las se�ales est�n a cero. Ten�is que dise�ar vosotros la l�gica necesaria para cada caso
address_error <= '1' when (address_predicted_ID/=DirSalto_ID AND Branch='1' AND avanzar_ID='1')
                 else '0';
decission_error <= '1' when (prediction_ID/=Saltar AND Branch='1' AND avanzar_ID='1')
                    else '0';
-- Ha habido un error si el predictor tom� la decisi�n contraria (decission error) o si se decidi� saltar pero se salt� a una direcci�n incorrecta
predictor_error <= (address_error OR decission_error);
-- Actualizaci�n del predictor: si la predicci�n fue err�nea damos la orden de que se carguen los datos correctos
update_predictor <= '1' when (predictor_error = '1')
                    else '0';
prediction_in <= '1' when (Saltar = '1')
                else '0';
branch_address_in <= DirSalto_ID;                   --Esta es la direccion a la que habria que ir cuando se equivoca el predictor
-------------------------------------------------------------------------
-- si la operaci�n es aritm�tica (es decir: IR_ID(31 downto 26)= "000001") miro el campo funct
-- como s�lo hay 4 operaciones en la alu, basta con los bits menos significativos del campo func de la instrucci�n
-- si no es aritm�tica le damos el valor de la suma (000)
ALUctrl_ID <= IR_ID(2 downto 0) when IR_ID(31 downto 26)= "000001" else "000";

Banco_ID_EX: Banco_EX PORT MAP ( clk => clk, reset => reset, load => '1', busA => busA, busB => busB, busA_EX => busA_EX, busB_EX => busB_EX,
				RegDst_ID => RegDst_ID, ALUSrc_ID => ALUSrc_ID, MemWrite_ID => MemWrite_ID, MemRead_ID => MemRead_ID,
				MemtoReg_ID => MemtoReg_ID, RegWrite_ID => RegWrite_ID, RegDst_EX => RegDst_EX, ALUSrc_EX => ALUSrc_EX,
				MemWrite_EX => MemWrite_EX, MemRead_EX => MemRead_EX, MemtoReg_EX => MemtoReg_EX, RegWrite_EX => RegWrite_EX,
				ALUctrl_ID => ALUctrl_ID, ALUctrl_EX => ALUctrl_EX, inm_ext => inm_ext, inm_ext_EX=> inm_ext_EX,
				-- Nuevo (para la anticipaci�n)
				Reg_Rs_ID => IR_ID(25 downto 21), Reg_Rs_EX => Reg_Rs_EX,
				Reg_Rt_ID => IR_ID(20 downto 16), Reg_Rd_ID => IR_ID(15 downto 11), Reg_Rt_EX => Reg_Rt_EX, Reg_Rd_EX => Reg_Rd_EX);

--
------------------------------------------Etapa EX-------------------------------------------------------------------
--

---------------------------------------------------------------------------------
-- Unidad de anticipacion. Ahora mismo selecciona siempre la entrada 0. Deb�is editarla y escribir el c�digo para que selecciones el caso adecuado

Unidad_Ant: UA port map (	Reg_Rs_EX => Reg_Rs_EX, Reg_Rt_EX => Reg_Rt_EX, RegWrite_MEM => RegWrite_MEM, RW_MEM => RW_MEM,
							RegWrite_WB => RegWrite_WB, RW_WB => RW_WB, MUX_ctrl_A => MUX_ctrl_A, MUX_ctrl_B => MUX_ctrl_B);
---------------------------------------------------------------------------------
-- Unidad de anticipacion: Muxes para la anticipacion
Mux_A: mux4_1_32bits port map  ( DIn0 => BusA_EX, DIn1 => ALU_out_MEM, DIn2 => busW, DIn3 => cero, ctrl => MUX_ctrl_A, Dout => Mux_A_out);
Mux_B: mux4_1_32bits port map  ( DIn0 => BusB_EX, DIn1 => ALU_out_MEM, DIn2 => busW, DIn3 => cero, ctrl => MUX_ctrl_B, Dout => Mux_B_out);

muxALU_src: mux2_1 port map (Din0 => Mux_B_out, DIn1 => inm_ext_EX, ctrl => ALUSrc_EX, Dout => Mux_out);

ALU_MIPs: ALU PORT MAP ( DA => Mux_A_out, DB => Mux_out, ALUctrl => ALUctrl_EX, Dout => ALU_out_EX);

mux_dst: mux2_5bits port map (Din0 => Reg_Rt_EX, DIn1 => Reg_Rd_EX, ctrl => RegDst_EX, Dout => RW_EX);

ctrldirsSalto <= '0' when (MUX_ctrl_B="00")
                  else '1';

mux_dirsaltoW: mux2_1 port map (Din0 => BusB_EX, DIn1 => Mux_B_out, ctrl => ctrldirsSalto, Dout => dirSalto);

Banco_EX_MEM: Banco_MEM PORT MAP ( 	ALU_out_EX => ALU_out_EX, ALU_out_MEM => ALU_out_MEM, clk => clk, reset => reset, load => '1', MemWrite_EX => MemWrite_EX,
					MemRead_EX => MemRead_EX, MemtoReg_EX => MemtoReg_EX, RegWrite_EX => RegWrite_EX, MemWrite_MEM => MemWrite_MEM, MemRead_MEM => MemRead_MEM,
					MemtoReg_MEM => MemtoReg_MEM, RegWrite_MEM => RegWrite_MEM, BusB_EX => dirSalto, BusB_MEM => BusB_MEM, RW_EX => RW_EX, RW_MEM => RW_MEM);

--
------------------------------------------Etapa MEM-------------------------------------------------------------------
--


Mem_D: memoriaRAM_D PORT MAP (CLK => CLK, ADDR => ALU_out_MEM, Din => BusB_MEM, WE => MemWrite_MEM, RE => MemRead_MEM, Dout => Mem_out);

Banco_MEM_WB: Banco_WB PORT MAP ( 	ALU_out_MEM => ALU_out_MEM, ALU_out_WB => ALU_out_WB, Mem_out => Mem_out, MDR => MDR, clk => clk, reset => reset, load => '1', MemtoReg_MEM => MemtoReg_MEM, RegWrite_MEM => RegWrite_MEM,
									MemtoReg_WB => MemtoReg_WB, RegWrite_WB => RegWrite_WB, RW_MEM => RW_MEM, RW_WB => RW_WB );

mux_busW: mux2_1 port map (Din0 => ALU_out_WB, DIn1 => MDR, ctrl => MemtoReg_WB, Dout => busW);

output <= IR_ID;
end Behavioral;
