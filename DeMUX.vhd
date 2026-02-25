----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2026 03:58:40 PM
-- Design Name: 
-- Module Name: DeMUX - Behavioral
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

entity DeMUX is
    generic(
        DataS : integer := 8
    );
    Port (
        iClk            : in std_logic;
        ADC             : in std_logic_vector(DataS-1 downto 0);
        switch          : in std_logic;
        oADC_Clk_Gen    : out std_logic_vector(DataS-1 downto 0);
        oADC_PWM        : out std_logic_vector(DataS-1 downto 0)
    );
end DeMUX;

architecture Behavioral of DeMUX is

    signal oADC  :std_logic_vector(DataS-1 downto 0);

begin

oADC <= ADC;

DeMUXULATE: process(iClk)
	 begin
	 if switch = '0' then
	   oADC_PWM <= oADC;
	 elsif switch = '1' then
	   oADC_Clk_GEN <= oADC;
	 end if;
end process;

end Behavioral;
