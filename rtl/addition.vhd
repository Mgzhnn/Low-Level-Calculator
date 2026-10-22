library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Partial_Full_Adder is
    Port ( A, B, Cin : in STD_LOGIC;
           S, P, G   : out STD_LOGIC);
end Partial_Full_Adder;

architecture Behavioral_PFA of Partial_Full_Adder is
begin
    S <= A xor B xor Cin;
    P <= A xor B;
    G <= A and B;
end Behavioral_PFA;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Carry_Look_Ahead is
    Port ( A, B : in STD_LOGIC_VECTOR (3 downto 0);
           Cin  : in STD_LOGIC;
           S    : out STD_LOGIC_VECTOR (3 downto 0);
           Cout : out STD_LOGIC;
           C3_out : out STD_LOGIC ); 
end Carry_Look_Ahead;

architecture Behavioral_CLA of Carry_Look_Ahead is
    signal c1, c2, c3 : STD_LOGIC;
    signal P, G : STD_LOGIC_VECTOR(3 downto 0);
begin
    PFA1: entity work.Partial_Full_Adder port map(A(0), B(0), Cin, S(0), P(0), G(0));
    PFA2: entity work.Partial_Full_Adder port map(A(1), B(1), c1, S(1), P(1), G(1));
    PFA3: entity work.Partial_Full_Adder port map(A(2), B(2), c2, S(2), P(2), G(2));
    PFA4: entity work.Partial_Full_Adder port map(A(3), B(3), c3, S(3), P(3), G(3));

    c1 <= G(0) or (P(0) and Cin);
    c2 <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and Cin);
    c3 <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or (P(2) and P(1) and P(0) and Cin);
    Cout <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0)) or (P(3) and P(2) and P(1) and P(0) and Cin);
    
    C3_out <= c3; 
end Behavioral_CLA;
