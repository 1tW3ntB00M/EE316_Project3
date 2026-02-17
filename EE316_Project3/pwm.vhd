-- Original Source: http://academic.csuohio.edu/chu_p/rtl/fpga_vhdl.html
-- Listing 4.10
-- modified: added port "clk_en", Sept 5, 2013
-- modified: added upper and lower limits of the counter, Sept 1, 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_gen is
   generic(Data_Size: integer := 8; Cnt2: integer := 255);
   port(
		clk 			: in std_logic;
		reset			: in std_logic;
		PWM_Mode        : in std_logic;
		AIN0_data       : in std_logic; --Jumper P5 Light Dependant Resistor
        AIN1_data       : in std_logic; --Jumper P4 Thermister(TEMP)
        AIN3_data       : in std_logic; --Jumper P6 Potentiometer (POT)
        ADC             : in std_logic_vector(0 downto 7);
		pwm_out		    : out std_logic
   );
end pwm_gen;

architecture logic of pwm_gen is

	 signal count_val   : STD_LOGIC_VECTOR(Data_Size-1 downto 0);
     signal counter 	: integer range 0 to Cnt2 := 0;
	 --signal sram_top	: std_logic_vector(N-1 downto 0);
--	 signal pwm			: std_logic;
	 signal N           : integer :=0;
	 signal clk_cnt	    : integer range 0 to 249999;
	 signal clk_en	    : std_logic;
	 
	 
begin

   
    inst_counter: process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
        elsif rising_edge(clk) then
            if PWM_Mode = '0' then
				if counter < Cnt2 then
					counter <= counter + 1;  -- Increment by 1
				else 
					counter <= 0;
				end if;
			else
			--Clk_Gen Mode
			   N <= 16667+((33337)/255)*to_integer(unsigned(ADC));
			   if (clk_cnt = N) then --For sim - 2, for use 249999
				clk_cnt <= 0;
				clk_en <= '1';
			   else 
				clk_cnt <= clk_cnt + 1;
				clk_en <= '0';
			   end if;
			   
			   pwm_out <= clk_en;   
			      
			end if;
        end if;
    end process;

    count_val <= std_logic_vector(to_unsigned(counter, Data_Size));
	 --sram_top  <= sram_data(15 downto 15-(N-1));
--	 pwm_out   <= pwm;
	 
	 inst_pwm_logic: process(clk,reset)
	 begin
--		 if reset = '1' then
--			  pwm <= '0';
--		 elsif rising_edge(clk) then
--			    pwm <= '1';
--		 end if;
	 end process;
		
end logic;
		
