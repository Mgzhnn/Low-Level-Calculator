library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display_Encoder is
    Port (
        Sel           : in STD_LOGIC_VECTOR(1 downto 0);
        mag_A         : in STD_LOGIC_VECTOR(3 downto 0);
        sign_A        : in STD_LOGIC;
        mag_B         : in STD_LOGIC_VECTOR(3 downto 0);
        sign_B        : in STD_LOGIC;
        AddSub_Mag    : in STD_LOGIC_VECTOR(4 downto 0);
        AddSub_Sign   : in STD_LOGIC;
        Mul_Result    : in STD_LOGIC_VECTOR(7 downto 0);
        Mul_Sign      : in STD_LOGIC;
        Div_Quotient  : in STD_LOGIC_VECTOR(3 downto 0);
        Div_Remainder : in STD_LOGIC_VECTOR(3 downto 0);
        Div_Sign      : in STD_LOGIC;
        x_inter       : out STD_LOGIC_VECTOR(21 downto 0)
    );
end Display_Encoder;

architecture Behavioral of Display_Encoder is

    signal Final_Mag    : STD_LOGIC_VECTOR(6 downto 0); 
    signal Final_Sign   : STD_LOGIC;
    signal Final_Out2   : STD_LOGIC_VECTOR(3 downto 0);
    signal Final_Out1   : STD_LOGIC_VECTOR(3 downto 0);
    signal Final_OpCode : STD_LOGIC_VECTOR(2 downto 0);

begin

    process(Sel, AddSub_Mag, AddSub_Sign, Mul_Result, Mul_Sign, Div_Quotient, Div_Remainder, Div_Sign)
    begin
        case Sel is
            when "00" => -- Addition
                Final_Mag    <= "00" & AddSub_Mag; -- 5bit -> 7bit
                Final_Sign   <= AddSub_Sign;
                Final_OpCode <= "100";
            when "01" => -- Subtraction
                Final_Mag    <= "00" & AddSub_Mag; -- 5bit -> 7bit
                Final_Sign   <= AddSub_Sign;
                Final_OpCode <= "101";
            when "10" => -- Multiplication
                Final_Mag    <= Mul_Result(6 downto 0); -- 7bit 
                Final_Sign   <= Mul_Sign;
                Final_OpCode <= "110";
            when "11" => -- Division
                Final_Mag    <= (others => '0');
                Final_Sign   <= Div_Sign;
                Final_OpCode <= "111";
            when others =>
                Final_Mag    <= (others => '0');
                Final_Sign   <= '0';
                Final_OpCode <= "000";
        end case;
    end process;

    process(Sel, Final_Mag, Div_Quotient, Div_Remainder)
        variable Q_Abs : std_logic_vector(3 downto 0);
    begin
        if Sel = "11" then
            case Div_Quotient is
                when "1000" => Q_Abs := "1000";
                when "1001" => Q_Abs := "0111";
                when "1010" => Q_Abs := "0110";
                when "1011" => Q_Abs := "0101";
                when "1100" => Q_Abs := "0100";
                when "1101" => Q_Abs := "0011";
                when "1110" => Q_Abs := "0010";
                when "1111" => Q_Abs := "0001";
                when others => Q_Abs := Div_Quotient;
            end case;
            Final_Out2 <= Q_Abs;
            Final_Out1 <= Div_Remainder;
            
        else

            if Final_Mag >= "0111100" then    -- >= 60 
                Final_Out2 <= "0110"; -- 6
                case Final_Mag is
                    when "0111100" => Final_Out1 <= "0000"; -- 60
                    when "0111101" => Final_Out1 <= "0001"; -- 61
                    when "0111110" => Final_Out1 <= "0010"; -- 62
                    when "0111111" => Final_Out1 <= "0011"; -- 63
                    when others    => Final_Out1 <= "0100"; -- 64
                end case;
                
            elsif Final_Mag >= "0110010" then -- >= 50 
                Final_Out2 <= "0101"; -- 5
                case Final_Mag is
                    when "0110010" => Final_Out1 <= "0000";
                    when "0110011" => Final_Out1 <= "0001";
                    when "0110100" => Final_Out1 <= "0010";
                    when "0110101" => Final_Out1 <= "0011";
                    when "0110110" => Final_Out1 <= "0100";
                    when "0110111" => Final_Out1 <= "0101";
                    when "0111000" => Final_Out1 <= "0110";
                    when "0111001" => Final_Out1 <= "0111";
                    when "0111010" => Final_Out1 <= "1000";
                    when others    => Final_Out1 <= "1001";
                end case;
                
            elsif Final_Mag >= "0101000" then -- >= 40 
                Final_Out2 <= "0100"; -- 4
                case Final_Mag is
                    when "0101000" => Final_Out1 <= "0000";
                    when "0101001" => Final_Out1 <= "0001";
                    when "0101010" => Final_Out1 <= "0010";
                    when "0101011" => Final_Out1 <= "0011";
                    when "0101100" => Final_Out1 <= "0100";
                    when "0101101" => Final_Out1 <= "0101";
                    when "0101110" => Final_Out1 <= "0110";
                    when "0101111" => Final_Out1 <= "0111";
                    when "0110000" => Final_Out1 <= "1000";
                    when others    => Final_Out1 <= "1001";
                end case;

            elsif Final_Mag >= "0011110" then -- >= 30 
                Final_Out2 <= "0011"; -- 3
                case Final_Mag is
                    when "0011110" => Final_Out1 <= "0000";
                    when "0011111" => Final_Out1 <= "0001";
                    when "0100000" => Final_Out1 <= "0010";
                    when "0100001" => Final_Out1 <= "0011";
                    when "0100010" => Final_Out1 <= "0100";
                    when "0100011" => Final_Out1 <= "0101"; -- 35
                    when "0100100" => Final_Out1 <= "0110";
                    when "0100101" => Final_Out1 <= "0111";
                    when "0100110" => Final_Out1 <= "1000";
                    when others    => Final_Out1 <= "1001";
                end case;
                
            elsif Final_Mag >= "0010100" then -- >= 20 
                Final_Out2 <= "0010"; -- 2
                case Final_Mag is
                    when "0010100" => Final_Out1 <= "0000";
                    when "0010101" => Final_Out1 <= "0001";
                    when "0010110" => Final_Out1 <= "0010";
                    when "0010111" => Final_Out1 <= "0011";
                    when "0011000" => Final_Out1 <= "0100";
                    when "0011001" => Final_Out1 <= "0101"; -- 25
                    when "0011010" => Final_Out1 <= "0110";
                    when "0011011" => Final_Out1 <= "0111";
                    when "0011100" => Final_Out1 <= "1000";
                    when others    => Final_Out1 <= "1001";
                end case;
                
            elsif Final_Mag >= "0001010" then -- >= 10 
                Final_Out2 <= "0001"; -- 1
                case Final_Mag is
                    when "0001010" => Final_Out1 <= "0000"; -- 10
                    when "0001011" => Final_Out1 <= "0001";
                    when "0001100" => Final_Out1 <= "0010";
                    when "0001101" => Final_Out1 <= "0011";
                    when "0001110" => Final_Out1 <= "0100";
                    when "0001111" => Final_Out1 <= "0101"; -- 15
                    when "0010000" => Final_Out1 <= "0110"; -- 16
                    when "0010001" => Final_Out1 <= "0111"; -- 17
                    when "0010010" => Final_Out1 <= "1000"; -- 18 
                    when others    => Final_Out1 <= "1001"; -- 19
                end case;
                
            else 
                Final_Out2 <= "0000";
                Final_Out1 <= Final_Mag(3 downto 0);
            end if;
        end if;
    end process;

    x_inter(21)          <= sign_A;
    x_inter(20 downto 17)<= mag_A;
    x_inter(16)          <= sign_B;
    x_inter(15 downto 12)<= mag_B;
    x_inter(11)          <= Final_Sign;
    x_inter(10 downto 7) <= Final_Out2;
    x_inter(6 downto 3)  <= Final_Out1;
    x_inter(2 downto 0)  <= Final_OpCode;

end Behavioral;
