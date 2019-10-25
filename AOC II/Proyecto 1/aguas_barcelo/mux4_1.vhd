------------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:10:55 03/31/2014 
-- Design Name: 
-- Module Name:    mux4_1_8bits - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux4_1 is
  Port (   DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn2 : in  STD_LOGIC_VECTOR (31 downto 0);
           DIn3 : in  STD_LOGIC_VECTOR (31 downto 0);
		   ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
end mux4_1;

architecture Behavioral of mux4_1 is

begin
Dout <= DIn3 when (ctrl ="11") else 
		DIn2 when (ctrl ="10") else
		DIn1 when (ctrl ="01") else 
		DIn0;

end Behavioral;
