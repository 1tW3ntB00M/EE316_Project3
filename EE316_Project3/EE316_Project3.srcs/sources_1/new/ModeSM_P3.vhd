----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2026 01:43:11 PM
-- Design Name: 
-- Module Name: ModeSM_P3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModeSM_P3 is
  Port (
        iClk				: in std_logic;
		Reset		    	: in std_logic;	
        Btn1                : in std_logic;
        Btn2                : in std_logic;
        Btn3                : in std_logic;
        LED0                : out std_logic;
        LED1                : out std_logic;
        LED2                : out std_logic;
        LED3                : out std_logic
   );
end ModeSM_P3;

architecture Behavioral of ModeSM_P3 is

component univ_bin_counter is
   generic(N: integer := 8; N2: integer := 255; N1: integer := 0);
   port(
			clk, reset				   : in std_logic;
			syn_clr, load, en, up	: in std_logic;
			clk_en 					   : in std_logic := '1';			
			d						      : in std_logic_vector(N-1 downto 0);
			max_tick, min_tick		: out std_logic;
			q						      : out std_logic_vector(N-1 downto 0)		
   );
end component;

type state is (Init, LDR, TEMP, POT, AMP);
signal MODE : state;

begin

process(iCLK)
	begin
		if rising_edge(iCLK) then
			if Reset = '1' then
				MODE <= Init;
			else		
				case MODE is 
					when Init =>
					   LED0 <= '0';
					   LED1 <= '0';
					   LED2 <= '0';
					   LED3 <= '0';
                       MODE <= LDR;
					when LDR =>
					   LED0 <= '1';
					   if Btn1 = '1' then
					       LED0 <= '0';
					       LED1 <= '1';
					       LED2 <= '0';
					       LED3 <= '0';
					       MODE <= TEMP;
					   end if; 
					   
					when TEMP =>
					   if Btn1 = '1' then
					       LED0 <= '0';
					       LED1 <= '0';
					       LED2 <= '1';
					       LED3 <= '0';
					       MODE <= POT;
					   end if; 
					
					when POT =>
					   if Btn1 = '1' then
					       LED0 <= '0';
					       LED1 <= '0';
					       LED2 <= '0';
					       LED3 <= '1';
					       MODE <= AMP;
					   end if; 
					
					when AMP =>
					   if Btn1 = '1' then
					       LED0 <= '1';                                                    
					       LED1 <= '0';
					       LED2 <= '0';
					       LED3 <= '0';
					       MODE <= LDR;
					   end if; 
					
	             end case;
			end if;
		end if;
	end process;
end Behavioral;
