----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2026 01:28:07 PM
-- Design Name: 
-- Module Name: JbJaTEST - Behavioral
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

entity JbJaTEST is
  Port ( 
    Btn0   : in std_logic;
    Btn1   : in std_logic;
    Btn2   : in std_logic;
    Btn3   : in std_logic;
    LED0   : out std_logic;
    LED1   : out std_logic;
    LED2   : out std_logic;
    LED3   : out std_logic
  );
end JbJaTEST;

architecture Behavioral of JbJaTEST is

begin

LED0 <= Btn0;
LED1 <= Btn1;
LED2 <= Btn2;
LED3 <= Btn3;

end Behavioral;
