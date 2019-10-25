----------------------------------------------------------------------------------
-- Description: Banco de registros que separa las etapas IF e ID. Almacena la instrucci�n en IR_ID y el PC+4 en PC4_ID
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity branch_predictor is
 Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
 			-- Puerto de lectura se accede con los 8 bits menos significativos de PC+4 sumado en IF
			PC4 : in  STD_LOGIC_VECTOR (7 downto 0);
			branch_address_out : out  STD_LOGIC_VECTOR (31 downto 0); -- direcci�n de salto
			prediction_out : out  STD_LOGIC; -- indica si hay que saltar a la direcci�n de salto o no (1) o no (0)
         	-- Puerto de escritura se env�a PC+4, la direcci�n de salto y la predicci�n, y se activa la se�al update_prediction
			PC4_ID:  in  STD_LOGIC_VECTOR (7 downto 0); -- Etiqueta: 8 bits menos significativos del PC+4 de la etapa ID
			prediction_in : in  STD_LOGIC; -- predicci�n
			branch_address_in : in  STD_LOGIC_VECTOR (31 downto 0); -- direcci�n de salto
       	update:  in  STD_LOGIC); -- da la orden de actualizar la informaci�n del predictor
end branch_predictor;

architecture Behavioral of branch_predictor is
signal valid, prediction: STD_LOGIC;
signal tag: STD_LOGIC_VECTOR (7 downto 0);
signal address: STD_LOGIC_VECTOR (31 downto 0);
begin
SYNC_PROC: process (clk) -- el predictor es un registro con algo de l�gica adicional. Este proceso modela el comportamiento del registro
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            valid <= '0'; -- si valid vale cero el predictor predice siempre no saltar
			tag  <= "00000000"; -- etiqueta la usamos para saber si la instrucci�n a la que vamos a acceder es la misma que la almacenada en el predictor
			prediction <= '0';
			address <= "00000000000000000000000000000000";
         else
            if (update='1') then
					valid <= '1';
					tag  <= PC4_ID;
					address <= branch_address_in;
					prediction <= prediction_in;
				end if;
         end if;
      end if;
   end process;

branch_address_out <= address;

prediction_out <= '1' when (tag = PC4) and (valid = '1') and (prediction = '1') else '0';

end Behavioral;
