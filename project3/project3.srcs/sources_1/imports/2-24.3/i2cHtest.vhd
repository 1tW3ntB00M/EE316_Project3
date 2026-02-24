library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity I2C_LCD_Write_H is
    Port ( clk   : in STD_LOGIC;  -- System clock
           reset : in STD_LOGIC;  -- Reset signal
           SDA   : inout STD_LOGIC; -- I2C Data line
           SCL   : out STD_LOGIC); -- I2C Clock line
end I2C_LCD_Write_H;

architecture Behavioral of I2C_LCD_Write_H is
    -- I2C protocol states
    type state_type is (IDLE, START, SEND, STOP, PAUSE);
    signal state : state_type := IDLE;
    signal bit_count : integer range 0 to 7 := 0;
    signal data : STD_LOGIC_VECTOR(7 downto 0) := "01001000"; -- ASCII 'H'
    signal SDA_int : STD_LOGIC := '1'; -- Internal SDA signal
    signal SCL_int : STD_LOGIC := '0'; -- Internal SCL signal
    signal done : STD_LOGIC := '0'; -- Done signal to indicate completion

begin
    -- SCL control
    process(clk, reset)
    begin
        if reset = '1' then
            SCL_int <= '0';
        elsif rising_edge(clk) then
            if state = SEND then
                SCL_int <= not SCL_int; -- Toggle clock during sending
            else
                SCL_int <= '0'; -- Keep clock low in other states
            end if;
        end if;
    end process;

    -- SDA control (data sending)
    process(clk, reset)
    begin
        if reset = '1' then
            SDA_int <= '1';  -- Idle state for SDA (high)
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    SDA_int <= '1';  -- Idle state, SDA high
                when START =>
                    SDA_int <= '0';  -- Start condition, SDA low
                when SEND =>
                    SDA_int <= data(7 - bit_count); -- Send bits from MSB to LSB
                when STOP =>
                    SDA_int <= '1';  -- Stop condition, SDA high
                when PAUSE =>
                    SDA_int <= '1';  -- Idle state, SDA high
            end case;
        end if;
    end process;

    -- I2C state machine
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_count <= 0;
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    -- Wait for reset or initialization
                    state <= START;
                when START =>
                    -- Send start condition (SDA falls while SCL is high)
                    state <= SEND;
                when SEND =>
                    if bit_count < 7 then
                        bit_count <= bit_count + 1;  -- Continue sending bits
                    else
                        -- Once all bits are sent, go to STOP condition
                        state <= STOP;
                    end if;
                when STOP =>
                    -- Send stop condition (SDA rises while SCL is high)
                    state <= PAUSE;  -- Wait for the next cycle
                when PAUSE =>
                    done <= '1';  -- Indicate that the transmission is complete
                    state <= IDLE;  -- Go back to IDLE state
            end case;
        end if;
    end process;

    -- Output signals
    SCL <= SCL_int;
    SDA <= SDA_int when SCL_int = '1' else 'Z';  -- Tri-state when not active

end Behavioral;
