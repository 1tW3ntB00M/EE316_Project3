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

component pwm_gen is
   generic(Data_Size: integer := 8; Cnt2: integer := 255);
   port(
		clk 			: in std_logic;
		reset			: in std_logic;
		PWM_Mode        : in std_logic;
		AIN0_data       : in std_logic; --Jumper P5 Light Dependant Resistor
        AIN1_data       : in std_logic; --Jumper P4 Thermister(TEMP)
        AIN3_data       : in std_logic; --Jumper P6 Potentiometer (POT)
		pwm_out		    : out std_logic
   );
end component;

component ModeSM_P3 is
  Port (
        iClk				: in std_logic;
		Reset		    	: in std_logic;	
        Btn1                : in std_logic;
        Btn2                : in std_logic;
        Btn3                : in std_logic;
        PWM_Mode            : out std_logic;
        LED0                : out std_logic;
        LED1                : out std_logic;
        LED2                : out std_logic;
        LED3                : out std_logic
   );
end component;

--component JbJaTEST is
--  Port ( 
--    Btn0   : in std_logic;
--    Btn1   : in std_logic;
--    Btn2   : in std_logic;
--    Btn3   : in std_logic;
--    LED0   : out std_logic;
--    LED1   : out std_logic;
--    LED2   : out std_logic;
--    LED3   : out std_logic
--  );
--end component;

signal Reset_Master  : std_logic;
signal Reset         : std_logic;
signal Btn0_db       : std_logic;
--signal Btn1_db       : std_logic;
signal Btn1_p        : std_logic;
signal Btn2_db       : std_logic;
signal Btn3_db       : std_logic;
signal PWMmode       : std_logic;
signal oPWM          : std_logic;

begin
Reset_Master <= Reset or Btn0_db;
led0_b       <= PWMmode;
o2Lowp       <= oPWM;
led1_g       <= oPWM;


inst_Reset_Delay : Reset_Delay
PORT map (
         iCLK    => iCLK,	
         oRESET  => Reset
			);

inst_Btn0_db_Reset : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"FFFF") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn0,
        CLK 	  => iCLK,
        BTN_O 	  => Btn0_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_Btn1_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"FFFF") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn1,
        CLK 	  => iCLK,
        BTN_O 	  => open,
        TOGGLE_O  => open,
	    PULSE_O   => Btn1_p
			  );
			  
inst_Btn2_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"FFFF") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn2,
        CLK 	  => iCLK,
        BTN_O 	  => Btn2_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_Btn3_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"FFFF") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn3,
        CLK 	  => iCLK,
        BTN_O 	  => Btn3_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_PWM : pwm_gen
GENERIC map (
	 Data_Size  => 8,
	 Cnt2 => 255
	 ) --"FFFF" for running "0004" fopr sim
    Port map ( 
        clk 			=> iClk,
		reset			=> Reset_Master,
		PWM_Mode        => PWMmode,
		AIN0_data       => AIN0, --Light Dependant Resistor
        AIN1_data       => AIN1, --Thermister(TEMP)
        AIN3_data       => AIN3, --Jumper P6 Potentiometer (POT)
		pwm_out		    => oPWM
			  );
			  
inst_MODE_SM : ModeSM_P3
Port map( 
    iClk				=> iClk,
	Reset		    	=> Reset_Master,
    Btn1                => Btn1_p,
    Btn2                => Btn2_db,
    Btn3                => Btn3_db,
    PWM_Mode            => PWMmode,
    LED0                => LED0,
    LED1                => LED1,
    LED2                => LED2,
    LED3                => LED3
  );
			  
--inst_JBJA_Testing : JbJaTEST
--Port map( 
--    Btn0   => Btn0_db,
--    Btn1   => Btn1_db,
--    Btn2   => Btn2_db,
--    Btn3   => Btn3_db,
--    LED0   => LED0,
--    LED1   => LED1,
--    LED2   => LED2,
--    LED3   => LED3
--  );


end Structural;
