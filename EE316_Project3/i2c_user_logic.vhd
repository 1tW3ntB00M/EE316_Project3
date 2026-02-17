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
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
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
						  i2c_data_rw <= x"00";
                    state       <= write_control;
                    i2c_rw      <= '0';
                end if;
                
            when write_control =>
               if i2c_busy = '0' and busy_prev = '1' then
--					 cont  <= X"03FFF";
--						if cont /= X"00000" then
--                    cont        <= cont - 1;
--						 ELSe
                i2c_rw <= '1';
                state <= read_data; 
					 --end if;
               else
                    if  btn_in = "0001" then
                       i2c_data_rw  <= control_byte_AIN0; --ldr
    
                    elsif btn_in = "0010" then
                        i2c_data_rw <= control_byte_AIN1; -- pot
    
                    elsif btn_in = "0100" then
                        i2c_data_rw <= control_byte_AIN2; -- sine
    
                    elsif btn_in = "1000" then
                        i2c_data_rw <= control_byte_AIN3; -- temp
                    end if;
                    state <= write_control;

               end if;


            when read_data =>
                dataready <= '0';
                if btn_in_prev /= btn_in  then
                    i2c_rw      <= '0';
                    cont  <= X"03FFF";
                    state <= start; 
                elsif i2c_busy = '0' and busy_prev = '1' then
                    dataready <= '1';
                    data_read <= data_rd;
                    state <= read_data;


                end if;
            
            when others =>
                state <= start; 

        end case; 
    end if;  
end process;


inst_i2c_master : i2c_master
generic map(
    input_clk => 50_000_000, --input clock speed from user logic in Hz
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