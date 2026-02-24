LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity i2c_user_logic is
PORT(
    clk             : IN     STD_LOGIC;                    --system clock
    btn_in          : IN     std_logic_vector(3 downto 0); 
    sda             : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl             : INOUT  STD_LOGIC;                   --serial clock output of i2c bus
    data_read       : out    std_logic_vector(7 downto 0);
    dataready       : out    std_logic);
end i2c_user_logic;

ARCHITECTURE logic OF i2c_user_logic IS

component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 25_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 50_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;	 			      --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component;

TYPE machine IS(start, write_control, read_data, repeat); --needed states

constant sensor_addr    : std_logic_vector(6 downto 0) := "1001000"; -- sensor i2c address (0x48)

signal cont			    : unsigned(19 downto 0):=X"03FFF";
signal state		    : machine;
signal reset_n   	    : STD_LOGIC;                          --active low reset
signal i2c_busy         : STD_LOGIC;                            --indicates transaction in progress
signal busy_prev	    : STD_LOGIC;
signal data_rd  	    : STD_LOGIC_VECTOR(7 DOWNTO 0);       --data read from slave
signal i2c_ena   	    : STD_LOGIC;                          --latch in command
signal i2c_addr         : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1001000" ;       --address of target slave
signal i2c_rw           : STD_LOGIC;                          --'0' is write, '1' is read
signal i2c_data_rw	    : std_logic_vector(7 downto 0);
signal ack_error	    : std_logic;
signal i2c_sda          : STD_LOGIC;                         --serial data output of i2c bus
signal i2c_scl          : STD_LOGIC;                        --serial clock output of i2c bus
signal control_byte_AIN0 : std_logic_vector(7 downto 0) := X"00"; 
signal control_byte_AIN1 : std_logic_vector(7 downto 0) := X"01"; 
signal control_byte_AIN2 : std_logic_vector(7 downto 0) := X"02"; 
signal control_byte_AIN3 : std_logic_vector(7 downto 0) := X"03"; 
signal btn_in_prev      : std_logic_vector(3 downto 0);
signal device_select    : std_logic;                            -- '0' for LCD, '1' for sensor
begin

process (clk)
	begin
	if rising_edge(clk) then
	busy_prev   <= i2c_busy;
	btn_in_prev <= btn_in;
	end if;
	end process;

process(clk)
begin  
    if rising_edge(clk) then
        CASE state is
            when start =>
                if cont /= X"00000" then
                    cont        <= cont - 1;
                    reset_n     <= '0';
                    state       <= start;
                    i2c_ena     <= '0';
                else
                    reset_n     <= '1';
                    i2c_ena     <= '1';
                    i2c_data_rw <= x"00"; -- Initialize data byte as 0
                    state       <= write_control;
                    i2c_rw      <= '0';  -- Write operation (default)
                end if;

            when write_control =>
                if i2c_busy = '0' and busy_prev = '1' then
                    -- If device select is 0, write to LCD, else read from sensor
                    if device_select = '0' then
                        -- Write to LCD
                        -- Send the ASCII value of "H" to the LCD (0x48)
                        i2c_data_rw <= x"48";  -- ASCII value for 'H'
                        state <= write_control;  -- Keep writing to LCD
                    else
                        -- Read from sensor (PCF8591 ADC)
                        i2c_rw <= '1';               -- Set to read mode
                        i2c_addr <= sensor_addr;     -- Set to sensor address
                        state <= read_data;          -- Move to read data state
                    end if;
                else
                    state <= read_data;  -- Wait to read data when not busy
                end if;

            when read_data =>
                dataready <= '0';
                if btn_in_prev /= btn_in then
                    i2c_rw <= '0';  -- Reset to write mode
                    cont  <= X"03FFF";  -- Reset counter
                    state <= start;  -- Return to start
                elsif i2c_busy = '0' and busy_prev = '1' then
                    -- Data is ready, set it as output
                    dataready <= '1';
                    if device_select = '1' then
                        -- Process sensor data read (e.g., temperature reading)
                        -- Assuming the sensor sends data to `data_rd`
                        data_read <= data_rd;  -- Store sensor data for processing
                    else
                        data_read <= "00000000"; -- No data from sensor
                    end if;
                    state <= read_data;       -- Keep reading if needed
                end if;

            when others =>
                state <= start;  -- Default state to start if any error
        end case;
    end if;  
end process;


inst_i2c_master : i2c_master
generic map(
    input_clk => 25_000_000, --input clock speed from user logic in Hz
    bus_clk   => 100_000)  --speed the i2c bus (scl) will run at in Hz
port map(
	clk     	=> clk,                      -- clock   
    reset_n 	=> reset_n,                  -- reset
    ena     	=> i2c_ena,                  -- command bit
    addr    	=> i2c_addr,                 -- address
    rw      	=> i2c_rw,                   -- read/write (0 for write, 1 for read)  
    data_wr 	=> i2c_data_rw,      
    busy      	=> i2c_busy,                 --indicates transaction in progress
    data_rd     => data_rd,
    ack_error   => ack_error,
    sda         => sda,
    scl         => scl
);

end logic;