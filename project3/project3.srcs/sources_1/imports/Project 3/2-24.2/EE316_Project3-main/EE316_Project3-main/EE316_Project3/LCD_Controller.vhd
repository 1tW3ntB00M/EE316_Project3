LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


ENTITY LCD_Controller IS
    PORT (
        Reset        	    : IN std_logic;
        Data         	    : IN std_logic_vector(15 DOWNTO 0);
		Address			    : IN std_logic_vector(7 downto 0);
        iclk          	    : IN std_logic;
        LCD_RS, LCD_EN 	    : OUT std_logic;
        LCD_DATA			: OUT std_logic_vector(7 DOWNTO 0);
		clk_en				: in std_logic;
	    state_in			: in std_logic_vector(3 downto 0);
		Hz_state			: in std_logic_vector(3 downto 0);
		blon				: out std_logic;
		rw					: out std_logic;
		LCDon				: out std_logic
     );
END LCD_Controller;

ARCHITECTURE arch OF LCD_Controller IS
    
    
    COMPONENT hex2ascii IS
        PORT ( 
            SIGNAL hex_digit        : in std_logic_vector(3 downto 0);
            SIGNAL ascii            : out std_logic_vector(7 downto 0) 
            );
    END COMPONENT;
    
        TYPE STATE_TYPE IS (STATE0, STATE1, STATE2);
        SIGNAL STATE                        : STATE_TYPE;
        SIGNAL Data_sent                    : STD_LOGIC_VECTOR (8 downto 0);
        SIGNAL LUT_INDEX                    : integer range 0 to 63:= 0;
        SIGNAL LCD_DATA_VALUE               : STD_LOGIC_VECTOR(7 downto 0);
       
        
        type array_type is array (0 to 7) of std_logic_vector(7 downto 0);
        signal ascii : array_type;
		  signal ps : std_logic_vector(3 downto 0);
		  signal Hz_ps : std_logic_vector(3 downto 0);
   BEGIN
		  
		  blon <= '1';
		  rw	  <= '0';
		  LCDon  <= '1';	
        
		  a0 : hex2ascii port map (hex_digit => address( 3 downto 0), ascii => ascii(4));
		  a1 : hex2ascii port map (hex_digit => address( 7 downto 4), ascii => ascii(5));
		  
        d0 : hex2ascii port map (hex_digit => data( 3 downto 0), ascii => ascii(0));
        d1 : hex2ascii port map (hex_digit => data( 7 downto 4), ascii => ascii(1));
        d2 : hex2ascii port map (hex_digit => data( 11 downto 8), ascii => ascii(2));
        d3 : hex2ascii port map (hex_digit => data( 15 downto 12), ascii => ascii(3));
        
        LCD_DATA         <= data_sent(7 downto 0);
        LCD_RS          <= DATA_sent(8);
           
        process (iclk, LUT_INDEX, ascii, state_in, Hz_state, reset)
        BEGIN
		  case state_in is
		  --------------------------------init--------------------------------
			when "0001" =>
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
					 
                WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"49"; -- I
                WHEN 11      => data_sent <= "1"&X"6E"; -- n
					 WHEN 12		  => data_sent <= "1"&X"69"; -- i
                WHEN 13      => data_sent <= "1"&X"74"; -- t
                WHEN 14      => data_sent <= "1"&X"69"; -- i
                WHEN 15      => data_sent <= "1"&X"61"; -- a
                WHEN 16      => data_sent <= "1"&X"6C"; -- l
                WHEN 17      => data_sent <= "1"&X"69"; -- i
                WHEN 18      => data_sent <= "1"&X"7A"; -- z
                WHEN 19      => data_sent <= "1"&X"69"; -- i
                WHEN 20      => data_sent <= "1"&X"6E"; -- n
                WHEN 21      => data_sent <= "1"&X"67"; -- g
                WHEN 22      => data_sent <= "1"&X"2E"; -- . 
                WHEN OTHERS => data_sent <= "0"&X"01";
              END CASE;
				  
			------------------------------test----------------------------------	  
			when "0010" =>
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
                
					 WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"54"; -- T
                WHEN 11      => data_sent <= "1"&X"65"; -- e
                WHEN 12      => data_sent <= "1"&X"73"; -- s
                WHEN 13      => data_sent <= "1"&X"74"; -- t
                WHEN 14      => data_sent <= "1"&X"20"; -- space
                WHEN 15      => data_sent <= "1"&X"4D"; -- M
                WHEN 16      => data_sent <= "1"&X"6F"; -- o
                WHEN 17      => data_sent <= "1"&X"64"; -- d
                WHEN 18      => data_sent <= "1"&X"65"; -- e
                              
                WHEN 19      => data_sent <= "0"&X"C0"; -- sets to bottom left 
					 
					 WHEN 20      => data_sent <= "1"&ascii(5);
					 WHEN 21      => data_sent <= "1"&ascii(4);
					 WHEN 22      => data_sent <= "1"&X"20"; -- space
                WHEN 23      => data_sent <= "1"&ascii(3);
                WHEN 24      => data_sent <= "1"&ascii(2);
                WHEN 25      => data_sent <= "1"&ascii(1);
                WHEN 26      => data_sent <= "1"&ascii(0);
					 
                WHEN OTHERS => data_sent <= "0"&X"01";
			
              END CASE;
				  --------------------------------pause---------------------------------------------
			when "0100" =>
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
                
					 WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"50"; -- P
                WHEN 11      => data_sent <= "1"&X"61"; -- a
                WHEN 12      => data_sent <= "1"&X"75"; -- u
                WHEN 13      => data_sent <= "1"&X"73"; -- s
                WHEN 14      => data_sent <= "1"&X"65"; -- e
					 WHEN 15      => data_sent <= "1"&X"20"; -- space
                WHEN 16      => data_sent <= "1"&X"4D"; -- M
                WHEN 17      => data_sent <= "1"&X"6F"; -- o
                WHEN 18      => data_sent <= "1"&X"64"; -- d
                WHEN 19      => data_sent <= "1"&X"65"; -- e
                              
                WHEN 20      => data_sent <= "0"&X"C0"; -- sets to bottom left 
						
					 WHEN 21      => data_sent <= "1"&ascii(5);
					 WHEN 22      => data_sent <= "1"&ascii(4);
					 WHEN 23      => data_sent <= "1"&X"20"; -- space
                WHEN 24      => data_sent <= "1"&ascii(3);
                WHEN 25      => data_sent <= "1"&ascii(2);
                WHEN 26      => data_sent <= "1"&ascii(1);
                WHEN 27      => data_sent <= "1"&ascii(0);
					 
                WHEN OTHERS => data_sent <= "0"&X"01";
			
              END CASE;
			
				  --------------------------------PWM---------------------------------------------
			when "1000" =>
			
				if (Hz_state(0)='1') then
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
                
					 WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"50"; -- P
                WHEN 11      => data_sent <= "1"&X"57"; -- W
                WHEN 12      => data_sent <= "1"&X"4D"; -- M
                WHEN 13      => data_sent <= "1"&X"20"; -- Spaace
                WHEN 14      => data_sent <= "1"&X"47"; -- G
					 WHEN 15      => data_sent <= "1"&X"65"; -- e
                WHEN 16      => data_sent <= "1"&X"6E"; -- n
                WHEN 17      => data_sent <= "1"&X"65"; -- e
                WHEN 18      => data_sent <= "1"&X"72"; -- r
                WHEN 19      => data_sent <= "1"&X"61"; -- a
					 WHEN 20      => data_sent <= "1"&X"74"; -- t
					 WHEN 21      => data_sent <= "1"&X"69"; -- i
					 WHEN 22      => data_sent <= "1"&X"6F"; -- o
					 WHEN 23      => data_sent <= "1"&X"6E"; -- n
				
					 WHEN 24 		=> data_sent <= "0"&X"C0"; -- sets to bottom left
					 WHEN 25 		=> data_sent <= "1"&X"36"; -- 6
					 WHEN 26 		=> data_sent <= "1"&X"30"; -- 0
					 WHEN 27 		=> data_sent <= "1"&X"20"; -- space
					 WHEN 28 		=> data_sent <= "1"&X"48"; -- H
					 WHEN 29 		=> data_sent <= "1"&X"7A"; -- z
					 WHEN OTHERS => data_sent <= "0"&X"01";
					 END CASE;
				elsif (Hz_state(1)='1') then
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
                
					 WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"50"; -- P
                WHEN 11      => data_sent <= "1"&X"57"; -- W
                WHEN 12      => data_sent <= "1"&X"4D"; -- M
                WHEN 13      => data_sent <= "1"&X"20"; -- Spaace
                WHEN 14      => data_sent <= "1"&X"47"; -- G
					 WHEN 15      => data_sent <= "1"&X"65"; -- e
                WHEN 16      => data_sent <= "1"&X"6E"; -- n
                WHEN 17      => data_sent <= "1"&X"65"; -- e
                WHEN 18      => data_sent <= "1"&X"72"; -- r
                WHEN 19      => data_sent <= "1"&X"61"; -- a
					 WHEN 20      => data_sent <= "1"&X"74"; -- t
					 WHEN 21      => data_sent <= "1"&X"69"; -- i
					 WHEN 22      => data_sent <= "1"&X"6F"; -- o
					 WHEN 23      => data_sent <= "1"&X"6E"; -- n
				
					 WHEN 24 		=> data_sent <= "0"&X"C0"; -- sets to bottom left
					 WHEN 25 		=> data_sent <= "1"&X"31"; -- 1
					 WHEN 26 		=> data_sent <= "1"&X"32"; -- 2
					 WHEN 27 		=> data_sent <= "1"&X"30"; -- 0
					 WHEN 28 		=> data_sent <= "1"&X"20"; -- space
					 WHEN 29 		=> data_sent <= "1"&X"48"; -- H
					 WHEN 30 		=> data_sent <= "1"&X"7A"; -- z
					 WHEN OTHERS => data_sent <= "0"&X"01";
					 END CASE;
				elsif (Hz_state(2)='1') then
            case LUT_INDEX IS
					
                WHEN 0      => data_sent <= "0"&X"01"; -- sets data length display lines and font
                WHEN 1      => data_sent <= "0"&X"01";
                WHEN 2      => data_sent <= "0"&X"38";
                WHEN 3      => data_sent <= "0"&X"38";
                WHEN 4      => data_sent <= "0"&X"38";
                WHEN 5      => data_sent <= "0"&X"38"; 
                WHEN 6      => data_sent <= "0"&X"01"; -- clear display
                WHEN 7      => data_sent <= "0"&X"0C"; -- turns on display 
                WHEN 8      => data_sent <= "0"&X"06"; -- sets cursor move direction to normal during operation
                
					 WHEN 9      => data_sent <= "0"&X"80"; -- sets address to top left
                WHEN 10      => data_sent <= "1"&X"50"; -- P
                WHEN 11      => data_sent <= "1"&X"57"; -- W
                WHEN 12      => data_sent <= "1"&X"4D"; -- M
                WHEN 13      => data_sent <= "1"&X"20"; -- Spaace
                WHEN 14      => data_sent <= "1"&X"47"; -- G
					 WHEN 15      => data_sent <= "1"&X"65"; -- e
                WHEN 16      => data_sent <= "1"&X"6E"; -- n
                WHEN 17      => data_sent <= "1"&X"65"; -- e
                WHEN 18      => data_sent <= "1"&X"72"; -- r
                WHEN 19      => data_sent <= "1"&X"61"; -- a
					 WHEN 20      => data_sent <= "1"&X"74"; -- t
					 WHEN 21      => data_sent <= "1"&X"69"; -- i
					 WHEN 22      => data_sent <= "1"&X"6F"; -- o
					 WHEN 23      => data_sent <= "1"&X"6E"; -- n
				
					 WHEN 24 		=> data_sent <= "0"&X"C0"; -- sets to bottom left
					 WHEN 25 		=> data_sent <= "1"&X"31"; -- 1
					 WHEN 26 		=> data_sent <= "1"&X"30"; -- 0
					 WHEN 27 		=> data_sent <= "1"&X"30"; -- 0
					 WHEN 28 		=> data_sent <= "1"&X"30"; -- 0
					 WHEN 29 		=> data_sent <= "1"&X"20"; -- space
					 WHEN 30 		=> data_sent <= "1"&X"48"; -- H
					 WHEN 31 		=> data_sent <= "1"&X"7A"; -- z
					 WHEN OTHERS => data_sent <= "0"&X"01";
					 END CASE;
				  end if;
				 when others =>
				END CASE;
           END PROCESS;
			  
      
       Process (iclk, state_in, Hz_state, LUT_INDEX, ascii, reset)
       BEGIN

		 IF RISING_EDGE(iclk) AND clk_en = '1' THEN
        if state_in /= ps then
                STATE <= STATE0;
                LCD_EN <= '0';
                LUT_INDEX <= 0;
					 ps <= state_in;
		  elsif Hz_state/= Hz_ps then
                STATE <= STATE0;
                LCD_EN <= '0';
                LUT_INDEX <= 0;
					 Hz_ps <= Hz_state;
		  elsif (state_in(0)='1') then ------ INIT
			  
					CASE STATE IS
						 WHEN STATE0 =>
							  LCD_EN <= '1';
							  STATE <= STATE1;
						 WHEN STATE1 =>
							  LCD_EN <= '0';
							  STATE <= STATE2;
						 WHEN STATE2 =>
							  LCD_EN <= '0';
							  STATE <= STATE0;
							  IF LUT_INDEX < 22 THEN
									LUT_INDEX <= LUT_INDEX + 1;
							  ELSE
									LUT_INDEX <= 9;
							  END IF;
						 WHEN OTHERS =>
							  STATE <= STATE0;
					END CASE;
				
					
			elsif (state_in(1)='1') then --- TEST 

					CASE STATE IS
						 WHEN STATE0 =>
							  LCD_EN <= '1';
							  STATE <= STATE1;
						 WHEN STATE1 =>
							  LCD_EN <= '0';
							  STATE <= STATE2;
						 WHEN STATE2 =>
							  LCD_EN <= '0';
							  STATE <= STATE0;
							  IF LUT_INDEX < 26 THEN
									LUT_INDEX <= LUT_INDEX + 1;
							  ELSE
									LUT_INDEX <= 19;
							  END IF;
						 WHEN OTHERS =>
							  STATE <= STATE0;
					END CASE;
		
			  
			elsif (state_in(2)='1') then --- Pause

						CASE STATE IS
							 WHEN STATE0 =>
								  LCD_EN <= '1';
								  STATE <= STATE1;
							 WHEN STATE1 =>
								  LCD_EN <= '0';
								  STATE <= STATE2;
							 WHEN STATE2 =>
								  LCD_EN <= '0';
								  STATE <= STATE0;
								  IF LUT_INDEX < 27 THEN
										LUT_INDEX <= LUT_INDEX + 1;
								  ELSE
										LUT_INDEX <= 20;
								  END IF;
							 WHEN OTHERS =>
								  STATE <= STATE0;
						END CASE;
			 elsif (state_in(3)='1') then --- PWM 
			 
					if (Hz_state(0)='1') then -- 60 Hz
						CASE STATE IS
							 WHEN STATE0 =>
								  LCD_EN <= '1';
								  STATE <= STATE1;
							 WHEN STATE1 =>
								  LCD_EN <= '0';
								  STATE <= STATE2;
							 WHEN STATE2 =>
								  LCD_EN <= '0';
								  STATE <= STATE0;
								  IF LUT_INDEX < 29 THEN
										LUT_INDEX <= LUT_INDEX + 1;
								  ELSE
										LUT_INDEX <= 24;
								  END IF;
							 WHEN OTHERS =>
								  STATE <= STATE0;
						END CASE;
						
					elsif (Hz_state(1)='1') then -- 120 Hz
						CASE STATE IS
							 WHEN STATE0 =>
								  LCD_EN <= '1';
								  STATE <= STATE1;
							 WHEN STATE1 =>
								  LCD_EN <= '0';
								  STATE <= STATE2;
							 WHEN STATE2 =>
								  LCD_EN <= '0';
								  STATE <= STATE0;
								  IF LUT_INDEX < 30 THEN
										LUT_INDEX <= LUT_INDEX + 1;
								  ELSE
										LUT_INDEX <= 24;
								  END IF;
							 WHEN OTHERS =>
								  STATE <= STATE0;
						END CASE;
						
					elsif (Hz_state(2)='1') then -- 1000 Hz
						CASE STATE IS
							 WHEN STATE0 =>
								  LCD_EN <= '1';
								  STATE <= STATE1;
							 WHEN STATE1 =>
								  LCD_EN <= '0';
								  STATE <= STATE2;
							 WHEN STATE2 =>
								  LCD_EN <= '0';
								  STATE <= STATE0;
								  IF LUT_INDEX < 31 THEN
										LUT_INDEX <= LUT_INDEX + 1;
								  ELSE
										LUT_INDEX <= 24;
								  END IF;
							 WHEN OTHERS =>
								  STATE <= STATE0;
						END CASE;
					end if;
			 END IF;
			  
			  
			 end if;
     end process;


end arch;            