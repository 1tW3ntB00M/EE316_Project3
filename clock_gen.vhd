library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_gen is
    Port ( clk          : in STD_LOGIC;
           data_ready   : in STD_LOGIC;
           data_in      : in STD_LOGIC_VECTOR (7 downto 0);
			  en				: in std_logic;
           clock_out    : out STD_LOGIC;
           reset        : in std_logic);
end clock_gen;

architecture Behavioral of clock_gen is
TYPE machine IS(start, read_data, clock_gen);
signal state                  : machine;
signal clock                  : std_logic := '0';
signal N_term1                : integer;
signal N_term2                : integer;
signal N_term3                : integer := 50000;
signal N_int                  : integer := 0; 
signal counter                : integer;
signal data_ready_prev        : std_logic;



begin

process(clk)
begin
    if rising_edge(clk) then
        data_ready_prev <= data_ready;
    end if;
end process;

inst_counter: process(clk, reset)
begin
    if reset = '1' then
        counter <= 0;
    elsif rising_edge(clk) then
    if counter < N_int then
        counter <= counter + 1;
    else
        counter <= 0;
    end if;
        end if;
    end process;

process(clk)
begin
    if rising_edge(clk) then
	 if en = '1' then
        CASE state IS
            WHEN start =>
                N_int    <= 0;            
                clock    <= '0';
                IF data_ready = '1' THEN
                    state <= read_data;  
                ELSE
                    state <= start;
                END IF;
            when read_data =>
                if reset = '1' then
                    state <= start;
                else
                    N_term1     <= to_integer(unsigned("0" & data_in & "0000000"));
                    N_term2     <= to_integer(unsigned("0000000" & data_in & "0"));
                    N_int       <= N_term3 - N_term1 - N_term2;
                    state       <= clock_gen;
                end if;
            when clock_gen =>
                if reset = '1' then
                    state <= start;
                else
                    if data_ready = '1' and data_ready_prev = '0' then
                        state <= read_data;
                    else
                        if clock = '1' then
                            if counter = 0 then
                                clock       <= '0';
                                clock_out   <= clock;
                                state       <= clock_gen;
                            end if;
                        else
                            if counter = 0 then
                                clock       <= '1';
                                clock_out   <= clock;
                                state       <= clock_gen;
                            end if;
                         end if;
                    end if;
                end if;
            when others => null;
        END CASE;
	 else 
		clock <= '0';
		clock_out <= clock;
	 end if;
    end if;
end process;

end Behavioral;
