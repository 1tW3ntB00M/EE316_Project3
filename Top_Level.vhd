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
    o2Lowp : out std_logic
    --PCF8591 Out
    --AIN0   : in std_logic --Jumper P5 Light Dependant Resistor
--    AIN1   : in std_logic; --Jumper P4 Thermister(TEMP)
--    AIN3   : in std_logic --Jumper P6 Potentiometer (POT)
  );
end Top_Level;

architecture Structural of Top_Level is

signal state_duty           : std_logic_vector(3 downto 0);
signal state_clock          : std_logic;
--signal adc_data             : std_logic_vector(7 downto 0);
signal adc_ready            : std_logic;
signal ADC_Clk_Gen          : std_logic_vector(7 downto 0);
signal ADC_PWM              : std_logic_vector(7 downto 0);

--component i2cHtest is
--    Port ( clk   : in STD_LOGIC;  -- System clock
--           reset : in STD_LOGIC;  -- Reset signal
--           SDA   : inout STD_LOGIC; -- I2C Data line
--           SCL   : out STD_LOGIC); -- I2C Clock line
--end component;

component i2c_user_logic is 
    PORT(
    clk             : IN     STD_LOGIC;                    --system clock
    btn_in          : IN     std_logic_vector(3 downto 0); 
    sda             : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl             : INOUT  STD_LOGIC;                   --serial clock output of i2c bus
    data_read       : out    std_logic_vector(7 downto 0);
    dataready       : out    std_logic);
END component;

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

component clock_gen is
  generic(
    DataS : integer := 8;
    N1    : integer := 125000;
    N2    : integer := 41666
  );
  Port (
    iClk     : in std_logic;
    reset    : in std_logic;
    ADC      : in std_logic_vector(7 downto 0);
    oClk_Gen : out std_logic
  );
end component;

component ADC_I2C_user_logic is							-- Modified from SPI usr logic from last year
    Port ( 
           iclk                : in STD_LOGIC;
           write_interupt      : in std_logic;
		   ChannelSel          : in std_LOGIC_VECTOR(1 downto 0);
		   EightBitDataFromADC : out std_LOGIC_VECTOR(7 downto 0);
		   dataready           : out std_logic;
           oADCSDA             : inout STD_LOGIC;
           oADCSCL             : inout STD_LOGIC
			  );
end component;

component pwm_gen is
   generic(Data_Size: integer := 8; Cnt2: integer := 255);
   port(
		clk 			: in std_logic;
		reset			: in std_logic;
		--PWM_Mode        : in std_logic;
		--AIN0_data       : in std_logic; --Jumper P5 Light Dependant Resistor
        --AIN1_data       : in std_logic; --Jumper P4 Thermister(TEMP)
        --AIN3_data       : in std_logic; --Jumper P6 Potentiometer (POT)
        ADC             : in std_logic_vector(7 downto 0);
		pwm_out		    : out std_logic
   );
end component;

component DeMUX is
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
end component;

component ModeSM_P3 is
  Port (
        iClk				: in std_logic;
		Reset		    	: in std_logic;	
        Btn1                : in std_logic;
        Btn2                : in std_logic;
        Btn3                : in std_logic;
        ADC_Mode            : out std_LOGIC_VECTOR(1 downto 0);
        PWM_Mode            : out std_logic;
        Pencile             : out std_logic;
        LED0                : out std_logic;
        LED1                : out std_logic;
        LED2                : out std_logic;
        LED3                : out std_logic
   );
end component;

component out_LUT is
  Port (
    iClk     : in std_logic;
    oClk_Gen : in std_logic;
    oPWM     : in std_logic;
    switch   : in std_logic;
    out_LUT  : out std_logic
    
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

signal Reset_Master      : std_logic;
signal Reset             : std_logic;
signal Btn0_db           : std_logic;
--signal Btn1_db       : std_logic;
signal Btn1_p            : std_logic;
signal Btn2_db           : std_logic;
signal Btn3_db           : std_logic;
signal PWMmode           : std_logic;
signal oPWM              : std_logic;
signal oClk_Gen          : std_logic;
signal sADC_Mode         : std_logic_vector(1 downto 0);
signal ADC_Data          : std_logic_vector(7 downto 0);
signal Sensor_Data_ready : std_logic;
signal garry            : std_logic;

begin
Reset_Master <= Reset or Btn0_db;
led0_b       <= PWMmode;
--o2Lowp       <= oPWM;
led1_g       <= Sensor_Data_ready;
              
inst_DeMUX : DeMUX
    generic map(
        DataS => 8
    )
    Port map(
        iClk            => iClk,
        ADC             => ADC_Data,
        switch          => PWMmode,
        oADC_Clk_Gen    => ADC_Clk_Gen,
        oADC_PWM        => ADC_PWM
    );              
    
inst_Clk_Gen: clock_gen
  generic map(
    DataS => 8,
    N1    => 125000,
    N2    => 41666
  )
  Port map(
    iClk     => iClk,
    reset    => Reset_Master,
    ADC      => ADC_Clk_Gen,
    oClk_Gen => oClk_Gen
  );
              
inst_Reset_Delay : Reset_Delay
PORT map (
         iCLK    => iCLK,	
         oRESET  => Reset
			);

inst_Btn0_db_Reset : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"0004") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn0,
        CLK 	  => iCLK,
        BTN_O 	  => Btn0_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_Btn1_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"0004") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn1,
        CLK 	  => iCLK,
        BTN_O 	  => open,
        TOGGLE_O  => open,
	    PULSE_O   => Btn1_p
			  );
			  
inst_Btn2_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"0004") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn2,
        CLK 	  => iCLK,
        BTN_O 	  => Btn2_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_Btn3_db : btn_debounce_toggle
GENERIC map (
	 CNTR_MAX => X"0004") --"FFFF" for running "0004" fopr sim
    Port map ( 
        BTN_I 	  => Btn3,
        CLK 	  => iCLK,
        BTN_O 	  => Btn3_db,
        TOGGLE_O  => open,
	    PULSE_O   => open
			  );
			  
inst_ADC_slave : ADC_I2C_user_logic						
    Port map ( 
        iclk                => iClk,
        write_interupt      => garry,
		ChannelSel          => sADC_Mode,
		EightBitDataFromADC => ADC_Data,
		dataready           => Sensor_Data_ready,
        oADCSDA             => ck_sda,
        oADCSCL             => ck_scl 
			  );

 
inst_PWM : pwm_gen
GENERIC map (
	 Data_Size  => 8,
	 Cnt2 => 255
	 )
    Port map ( 
        clk 			=> iClk,
		reset			=> Reset_Master,
		--PWM_Mode        => PWMmode,
		--AIN0_data       => AIN0, --Light Dependant Resistor
        --AIN1_data       => AIN1, --Thermister(TEMP)
        --AIN3_data       => AIN3, --Jumper P6 Potentiometer (POT)
        ADC             => ADC_PWM,
		pwm_out		    => oPWM
			  );
			  
inst_MODE_SM : ModeSM_P3
Port map( 
    iClk				=> iClk,
	Reset		    	=> Reset_Master,
    Btn1                => Btn1_p,
    Btn2                => Btn2_db,
    Btn3                => Btn3_db,
    ADC_Mode            => sADC_Mode,
    PWM_Mode            => PWMmode,
    Pencile             => garry,
    LED0                => LED0,
    LED1                => LED1,
    LED2                => LED2,
    LED3                => LED3
  );
  
inst_oUtlEt: out_LUT 
  Port map(
    iClk     => iClk,
    oClk_Gen => oClk_Gen,
    oPWM     => oPWM,
    switch   => PWMmode,
    out_LUT  => o2Lowp
    
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
