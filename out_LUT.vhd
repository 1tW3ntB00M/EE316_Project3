----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2026 06:24:55 PM
-- Design Name: 
-- Module Name: out_LUT - Behavioral
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

entity out_LUT is
  Port (
    iClk     : in std_logic;
    oClk_Gen : in std_logic;
    oPWM     : in std_logic;
    switch   : in std_logic;
    out_LUT  : out std_logic
    
  );
end out_LUT;

architecture Behavioral of out_LUT is

begin

DeMUXULATE: process(iClk)
	 begin
	 if switch = '0' then
	   out_LUT <= oPWM;
	 elsif switch = '1' then
	   out_LUT <= oClk_Gen;
	 end if;
end process;

end Behavioral;
