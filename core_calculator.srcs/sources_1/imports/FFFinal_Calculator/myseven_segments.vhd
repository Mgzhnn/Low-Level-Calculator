library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity myseven_segments is
   Port (
        x:in std_logic_vector(21 downto 0);
        clk: in std_logic;
        clr: in std_logic;
        reset: in std_logic;
        a_to_g: out std_logic_vector(7 downto 0);
        an: out std_logic_vector(7 downto 0)
         );
end myseven_segments;

architecture Behavioral of myseven_segments is
   signal digit_select: std_logic_vector(2 downto 0);
   signal digit:std_logic_vector(3 downto 0);
   signal clkdiv: std_logic_vector(20 downto 0);
   signal x_4bit: std_logic_vector(31 downto 0);
begin


x_4bit(3 downto 0) <=
"1010" when x(2 downto 0) = "100" else
"1011" when x(2 downto 0) = "101" else
"1100" when x(2 downto 0) = "110" else
"1111";
x_4bit(7 downto 4) <= x(6 downto 3);
x_4bit(11 downto 8) <= x(10 downto 7);
x_4bit(15 downto 12) <= "1101" when x(11) = '1' else "1110";
x_4bit(19 downto 16) <= x(15 downto 12);
x_4bit(23 downto 20) <= "1101" when x(16) = '1' else "1110";
x_4bit(27 downto 24) <= x(20 downto 17);
x_4bit(31 downto 28) <= "1101" when x(21) = '1' else "1110";


digit_select<=clkdiv(20 downto 18);

process(clk)
begin
 if rising_edge(clk) then
    if reset = '1' then
      digit <= "0000";
    else

      case digit_select is
        when "000"=>digit<=x_4bit(3 downto 0);
        when "001"=>digit<=x_4bit(7 downto 4);
        when "010"=>digit<=x_4bit(11 downto 8);
        when "011"=>digit<=x_4bit(15 downto 12);
        when "100"=>digit<=x_4bit(19 downto 16);
        when "101"=>digit<=x_4bit(23 downto 20);
        when "110"=>digit<=x_4bit(27 downto 24);
        when others=>digit<=x_4bit(31 downto 28);
      end case;
    end if;

  end if;
end process;



process(digit)              
begin
  case digit is
   when "0000"=>a_to_g<="00111111";
   when "0001"=>a_to_g<="00000110";
   when "0010"=>a_to_g<="01011011";
   when "0011"=>a_to_g<="01001111";
   when "0100"=>a_to_g<="01100110";
   when "0101"=>a_to_g<="01101101";
   when "0110"=>a_to_g<="01111101";
   when "0111"=>a_to_g<="00000111";
   when "1000"=>a_to_g<="01111111";
   when "1001"=>a_to_g<="01101111";
   when "1010"=>a_to_g<="11110111";
   when "1011"=>a_to_g<="11101101";
   when "1100"=>a_to_g<="10110111";
   when "1101"=>a_to_g<="01000000";
   when "1110"=>a_to_g<="00111111";
   when "1111"=>a_to_g<="01011110";
   when others =>a_to_g<="00000000";
  end case;
 end process;

 process(digit_select)
 begin
 case digit_select is 
  when "000"=>an<="00000001";
  when "001"=>an<="00000010";
  when "010"=>an<="00000100";
  when "011"=>an<="00001000";
  when "100"=>an<="00010000";
  when "101"=>an<="00100000";
  when "110"=>an<="01000000";
  when others=>an<="10000000";
 end case;
end process;

process(clk,clr)
 begin
  if clr='0' then
    clkdiv<=(others=>'0');
    elsif clk'event and clk='1' then
    clkdiv<=clkdiv+1;
  end if;
end process;
  
end Behavioral;