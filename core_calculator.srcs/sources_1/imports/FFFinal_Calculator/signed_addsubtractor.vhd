library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Signed_Adder_Sub is
    Port ( 
        A       : in  STD_LOGIC_VECTOR (3 downto 0);
        B       : in  STD_LOGIC_VECTOR (3 downto 0);
        Op_Sel  : in  STD_LOGIC;
        Result  : out STD_LOGIC_VECTOR (4 downto 0); 
        Co      : out STD_LOGIC                      
    );
end Signed_Adder_Sub;

architecture Behavioral of Signed_Adder_Sub is
    component Carry_Look_Ahead
    Port ( 
        A, B : in STD_LOGIC_VECTOR (3 downto 0);
        Cin  : in STD_LOGIC;
        S    : out STD_LOGIC_VECTOR (3 downto 0);
        Cout : out STD_LOGIC;
        C3_out : out STD_LOGIC 
    );
    end component;

    signal B_in_logic : STD_LOGIC_VECTOR (3 downto 0);
    signal CLA_Cin  : STD_LOGIC;
    signal CLA_S    : STD_LOGIC_VECTOR (3 downto 0);
    signal CLA_Cout : STD_LOGIC;
    signal CLA_C3   : STD_LOGIC;

begin
    B_in_logic <= not B when Op_Sel = '1' else B;
    CLA_Cin    <= Op_Sel;

    CLA_Unit: Carry_Look_Ahead
    port map (
        A      => A,
        B      => B_in_logic,
        Cin    => CLA_Cin,
        S      => CLA_S,
        Cout   => CLA_Cout,
        C3_out => CLA_C3
    );

    Result(4) <= CLA_S(3) XOR CLA_C3 XOR CLA_Cout;
    Result(3 downto 0) <= CLA_S;

    Co <= CLA_Cout;

end Behavioral;