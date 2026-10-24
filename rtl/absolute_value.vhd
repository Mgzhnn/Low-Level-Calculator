library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Abs_4bit is
    Port (
        X      : in  STD_LOGIC_VECTOR(3 downto 0);
        MAG_X  : out STD_LOGIC_VECTOR(3 downto 0);
        SIGN_X : out STD_LOGIC
    );
end Abs_4bit;

architecture Structural of Abs_4bit is

    component Signed_Adder_Sub is
        Port (
            A       : in  STD_LOGIC_VECTOR (3 downto 0);
            B       : in  STD_LOGIC_VECTOR (3 downto 0);
            Op_Sel  : in  STD_LOGIC;
            Result  : out STD_LOGIC_VECTOR (4 downto 0);
            Co      : out STD_LOGIC
        );
    end component;

    signal sub_res : STD_LOGIC_VECTOR(4 downto 0);

begin

    SIGN_X <= X(3);


    U_SUB_ABS : Signed_Adder_Sub
        port map (
            A       => "0000",
            B       => X,
            Op_Sel  => '1',
            Result  => sub_res,
            Co      => open
        );


    MAG_X <= sub_res(3 downto 0) when X(3) = '1' else X;

end Structural;

