----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2026 02:40:18 PM
-- Design Name: 
-- Module Name: Top_Level_tb - Behavioral
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

entity Top_Level_tb is
--  Port ( );
end Top_Level_tb;

architecture Behavioral of Top_Level_tb is

component Top_Level is
  Port ( 
    iClk   : in std_logic;
    --JB
    Btn0   : in std_logic;
    Btn1   : in std_logic;
    Btn2   : in std_logic;
    Btn3   : in std_logic;
    --JA
    LED0   : out std_logic;
    LED1   : out std_logic;
    LED2   : out std_logic;
    LED3   : out std_logic;
    --I2C
    ck_scl : inout std_logic;
    ck_sda : inout std_logic;
    --ON board LED
    led0_b : out std_logic;
    led1_g : out std_logic;
    --PWM
    o2Lowp : out std_logic
    --PCF8591 Out
    --AIN0   : in std_logic --Jumper P5 Light Dependant Resistor
    --AIN1   : in std_logic; --Jumper P4 Thermister(TEMP)
    --AIN3   : in std_logic --Jumper P6 Potentiometer (POT)
  );
end component;

    signal clock 	    : std_logic := '0';
	signal reset        : std_logic;
	signal sBTN1        : std_logic;
	signal sBTN2        : std_logic;
	signal sBTN3        : std_logic;
	signal sLED0        : std_logic;
	signal sLED1        : std_logic;
	signal sLED2        : std_logic;
	signal sLED3        : std_logic;
	signal sSCL         : std_logic;
	signal sSDA         : std_logic;
	signal so2Lowp      : std_logic;
	signal sAIN0        : std_logic;
	signal sAIN1        : std_logic;
	signal sAIN3        : std_logic;

begin

DUT: Top_Level
		port map(
		iClk   => clock,
        --JB
        Btn0   => reset,
        Btn1   => sBTN1,
        Btn2   => sBTN2,
        Btn3   => sBTN3,
        --JA
        LED0   => sLED0,
        LED1   => sLED1,
        LED2   => sLED2,
        LED3   => sLED3,
        --I2C
        ck_scl => sSCL,
        ck_sda => sSDA,
        --ON board LED
        --led0_b <= ?,
        --led1_g <= ?,
        --PWM
        o2Lowp => so2Lowp
        --PCF8591 Out
        --AIN0   => sAIN0 --Jumper P5 Light Dependant Resistor
       -- AIN1   => sAIN1, --Jumper P4 Thermister(TEMP)
       -- AIN3   => sAIN3 --Jumper P6 Potentiometer (POT)
		);

    clock <= not clock after 10 ns;
    
    process
		begin
		
		reset <= '0';
		wait for 10 ms;
		
		sBTN1 <= '1';
		wait for 10 ns;
		
		sBTN1 <= '0';
		wait for 10 ms;
		
		sBTN1 <= '1';
		wait for 10 ns;
		
		sBTN1 <= '0';
		wait for 10 ms;
		
		wait;
		
	end process;


end Behavioral;
