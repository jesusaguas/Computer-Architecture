----------------------------------------------------------------------------------
-- Description: Banco de registros que separa las etapas IF e ID. Almacena la instrucción en IR_ID y el PC+4 en PC4_ID
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Banco_ID is
 Port ( IR_in : in  STD_LOGIC_VECTOR (31 downto 0); -- instrucción leida en IF
        PC4_in:  in  STD_LOGIC_VECTOR (31 downto 0); -- PC+4 sumado en IF
		-- señales de la predicción de salto (dirección y predicción)
        address_predicted : in  STD_LOGIC_VECTOR (31 downto 0);
        prediction: in  STD_LOGIC;
		  clk : in  STD_LOGIC;
		  reset : in  STD_LOGIC;
        load : in  STD_LOGIC;
        IR_ID : out  STD_LOGIC_VECTOR (31 downto 0); -- instrucción en la etapa ID
        PC4_ID:  out  STD_LOGIC_VECTOR (31 downto 0);-- PC+4 en la etapa ID
        address_predicted_ID : out  STD_LOGIC_VECTOR (31 downto 0);
        prediction_ID: out  STD_LOGIC); 
end Banco_ID;

architecture Behavioral of Banco_ID is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            IR_ID <= "00000000000000000000000000000000";
			PC4_ID <= "00000000000000000000000000000000";
			address_predicted_ID <= "00000000000000000000000000000000";
			prediction_ID <= '0';
         else
            if (load='1') then 
					IR_ID <= IR_in;
					PC4_ID <= PC4_in;
					address_predicted_ID <= address_predicted;
					prediction_ID <= prediction;
				end if;	
         end if;        
      end if;
   end process;

end Behavioral;

