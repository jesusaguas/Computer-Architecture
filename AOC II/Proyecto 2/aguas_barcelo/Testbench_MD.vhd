--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   14:10:50 05/10/2018
-- Design Name:
-- Module Name:   D:/pruebas/MD/Test_MD.vhd
-- Project Name:  MD
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: MD_cont
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY Test_MD IS
END Test_MD;

ARCHITECTURE behavior OF Test_MD IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT MD_cont
    PORT(
          CLK : in std_logic;
		  reset: in std_logic;
		  Bus_Frame: in std_logic; -- indica que el master quiere m�s datos
		  bus_Rd_Wr: in std_logic;
		  Bus_AD : in std_logic_vector (31 downto 0); --Direcciones y datos
		  MD_Bus_DEVsel: out std_logic; -- para avisar de que se ha reconocido que la direcci�n pertenece a este m�dulo
		  MD_Bus_TRDY: out std_logic; -- para avisar de que se va a realizar la operaci�n solicitada en el ciclo actual
		  MD_send_data: out std_logic; -- para enviar los datos al bus
          MD_Dout : out std_logic_vector (31 downto 0)		  -- salida de datos
        );
    END COMPONENT;


   --Inputs
   signal CLK : std_logic := '0';
   signal reset : std_logic := '0';
   signal Bus_Frame : std_logic := '0';
   signal bus_Rd_Wr : std_logic := '0';
   signal Bus_AD : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal MD_Bus_DEVsel : std_logic;
   signal MD_Bus_TRDY : std_logic;
   signal MD_send_data : std_logic;
   signal MD_Dout : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: MD_cont PORT MAP (
          CLK => CLK,
          reset => reset,
          Bus_Frame => Bus_Frame,
          bus_Rd_Wr => bus_Rd_Wr,
          Bus_AD => Bus_AD,
          MD_Bus_DEVsel => MD_Bus_DEVsel,
          MD_Bus_TRDY => MD_Bus_TRDY,
          MD_send_data => MD_send_data,
          MD_Dout => MD_Dout
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
        reset 		<= '1';
		Bus_Frame 	<= '0';
		bus_Rd_Wr 		<= '1';
        Bus_AD 		<= x"10000000";
		wait for 40 ns;
		reset <= '0';
      wait for CLK_period*1;
		-- Petici�n fuera de rango no debe pasar nada
		Bus_Frame 	<= '1';

      wait for CLK_period*4;
		-- Petici�n dentro de rango de escritura
		Bus_AD 		<= X"00000000";
		wait until  MD_Bus_DEVsel = '1';
		wait for CLK_period*1;
		Bus_AD 		<= x"00000011"; --ponemos el primer dato
		wait for 1 ns;
		wait until MD_Bus_TRDY ='1'; --esperamos a que nos digan que lo pueden coger
		wait until CLK'event and CLK = '1'; -- esperamos a que llegue un flanco para que lo procesen
		Bus_AD 		<= x"00000022"; --ponemos el segundo dato
		wait for 1 ns;
		wait until MD_Bus_TRDY ='1'; --esperamos a que nos digan que lo pueden coger
		wait until CLK'event and CLK = '1'; -- esperamos a que llegue un flanco para que lo procesen
		Bus_AD 		<= x"00000033"; --ponemos el tercer dato
		wait for 1 ns;
		wait until MD_Bus_TRDY ='1'; --esperamos a que nos digan que lo pueden coger
		wait until CLK'event and CLK = '1'; -- esperamos a que llegue un flanco para que lo procesen
		Bus_AD 		<= x"00000044"; --ponemos el cuarto dato
		wait for 1 ns;
		wait until MD_Bus_TRDY ='1'; --esperamos a que nos digan que lo pueden coger
		wait until CLK'event and CLK = '1'; -- esperamos a que llegue un flanco para que lo procesen
		Bus_Frame 	<= '0'; --decimos que ya hemos terminado
		Bus_AD 		<= x"00000005"; --No deber�a escribirse
		wait for CLK_period*4;
		-- Petici�n dentro de rango de lectura
		Bus_AD 		<= X"00000000";
		bus_Rd_Wr 		<= '0';
		wait for CLK_period*4; -- no debe pasar nada porque el Bus-Frame no est� activado
		Bus_Frame <= '1';
		wait until  MD_Bus_DEVsel = '1';
		-- la memoria debe mandar datos consecutivos
		wait for CLK_period*30;


      wait;
   end process;

END;
