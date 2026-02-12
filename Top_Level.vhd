----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2026 12:12:55 PM
-- Design Name: 
-- Module Name: Top_Level - Behavioral
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

entity Top_Level is
  Port ( 
    iClk   : in std_logic;
    Btn0   : in std_logic;
    Btn1   : in std_logic;
    ck_scl : inout std_logic;
    ck_sda : inout std_logic;
    o2Lowp : out std_logic;
    --PCF8591 Out
    AIN0   : in std_logic; --Jumper P5 Light Dependant Resistor
    AIN1   : in std_logic; --Jumper P4 Thermister(TEMP)
    AIN3   : in std_logic --Jumper P6 Potentiometer (POT)
  );
end Top_Level;

architecture Structural of Top_Level is

component Reset_Delay IS	
    PORT (
        SIGNAL iCLK : IN std_logic;	
        SIGNAL oRESET : OUT std_logic
			);	
END component;

component btn_debounce_toggle is
GENERIC (
	CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
    Port ( BTN_I 	   : in  STD_LOGIC;
           CLK 	   : in  STD_LOGIC;
           BTN_O 	   : out  STD_LOGIC;
           TOGGLE_O  : out  STD_LOGIC;
			  PULSE_O   : out STD_LOGIC);
end component;

signal Reset_Master  : std_logic;
signal Reset         : std_logic;
signal Btn0_db       : std_logic;

begin
Reset_Master <= Reset or not Btn0_db;

inst_Reset_Delay : Reset_Delay
PORT map (
         iCLK    => iCLK,	
         oRESET  => Reset
			);

inst_key_0_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"FFFF") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn0,
        CLK 	  => iCLK,
        BTN_O 	  => Btn0_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );

end Structural;
