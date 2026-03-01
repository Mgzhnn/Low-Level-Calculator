library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_AddSub is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        Start   : in  STD_LOGIC;
        Sel     : in  STD_LOGIC_VECTOR(1 downto 0);
        A       : in  STD_LOGIC_VECTOR(3 downto 0);
        B       : in  STD_LOGIC_VECTOR(3 downto 0);

        Result  : out STD_LOGIC_VECTOR(4 downto 0);
        Done    : out STD_LOGIC;
        OP_Code : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Top_AddSub;

architecture Behavioral of Top_AddSub is

    signal Op_Sel_sig  : STD_LOGIC;

begin


    U_CTRL : entity work.AddSub_Controller
        port map (
            CLK     => CLK,
            RESET   => RESET,
            Start   => Start,
            Sel     => Sel,
            Op_Sel  => Op_Sel_sig,
            Done    => Done,
            OP_Code => OP_Code
        );


    U_ADD_SUB : entity work.Signed_Adder_Sub
        port map (
            A      => A,
            B      => B,
            Op_Sel => Op_Sel_sig,
            Result => Result
            
        );

end Behavioral;
