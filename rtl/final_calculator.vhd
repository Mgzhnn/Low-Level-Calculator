library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Core_Calculator is
    Port (
        CLK    : in  STD_LOGIC;
        Reset  : in  STD_LOGIC;
        Start  : in  STD_LOGIC;
        Sel    : in  STD_LOGIC_VECTOR(1 downto 0);  
        A      : in  STD_LOGIC_VECTOR(3 downto 0);  
        B      : in  STD_LOGIC_VECTOR(3 downto 0);

        AddSub_Result : out STD_LOGIC_VECTOR(4 downto 0); 
        Mul_Result    : out STD_LOGIC_VECTOR(7 downto 0); 
        Div_Quotient  : out STD_LOGIC_VECTOR(3 downto 0); 
        Div_Remainder : out STD_LOGIC_VECTOR(3 downto 0); 

        SIGN_A : out STD_LOGIC;
        SIGN_B : out STD_LOGIC;
        SIGN_C : out STD_LOGIC; 

        Done   : out STD_LOGIC   
    );
end Core_Calculator;

architecture Structural of Core_Calculator is
    component Top_AddSub is
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
    end component;

    component Multiplier_4bit is
        Port ( 
            Clk      : in  STD_LOGIC;
            Reset    : in  STD_LOGIC;
            Start    : in  STD_LOGIC;
            A_in     : in  STD_LOGIC_VECTOR (3 downto 0);
            B_in     : in  STD_LOGIC_VECTOR (3 downto 0);
            Result   : out STD_LOGIC_VECTOR (7 downto 0);
            Done     : out STD_LOGIC
        );
    end component;

    component Divider_4bit is
        Port ( 
            Clk      : in  STD_LOGIC;
            Reset    : in  STD_LOGIC;
            Start    : in  STD_LOGIC;
            A_in     : in  STD_LOGIC_VECTOR (3 downto 0);
            B_in     : in  STD_LOGIC_VECTOR (3 downto 0);
            Quotient : out STD_LOGIC_VECTOR (3 downto 0);
            Remainder: out STD_LOGIC_VECTOR (3 downto 0);
            Done     : out STD_LOGIC
        );
    end component;

    component Abs_4bit is
        Port (
            X      : in  STD_LOGIC_VECTOR(3 downto 0);
            MAG_X  : out STD_LOGIC_VECTOR(3 downto 0);
            SIGN_X : out STD_LOGIC
        );
    end component;

    component Euclid_Div_Adjust is
        Port (
            SIGN_A   : in  STD_LOGIC;
            SIGN_B   : in  STD_LOGIC;
            Q_mag    : in  STD_LOGIC_VECTOR(3 downto 0);
            R_mag    : in  STD_LOGIC_VECTOR(3 downto 0);
            B_mag    : in  STD_LOGIC_VECTOR(3 downto 0);
            Q_e      : out STD_LOGIC_VECTOR(3 downto 0);
            R_e      : out STD_LOGIC_VECTOR(3 downto 0);
            SIGN_Q_e : out STD_LOGIC
        );
    end component;

    signal s_MAG_A, s_MAG_B       : STD_LOGIC_VECTOR(3 downto 0);
    signal s_SIGN_A, s_SIGN_B     : STD_LOGIC;

    signal Start_AddSub, Start_Mul, Start_Div : STD_LOGIC;

    signal Done_Mul, Done_Div    : STD_LOGIC;

    signal AddSub_Res_i : STD_LOGIC_VECTOR(4 downto 0);
    signal Mul_Res_i    : STD_LOGIC_VECTOR(7 downto 0);
    signal Div_Q_i      : STD_LOGIC_VECTOR(3 downto 0); 
    signal Div_R_i      : STD_LOGIC_VECTOR(3 downto 0); 

    signal Div_Q_e_i    : STD_LOGIC_VECTOR(3 downto 0); 
    signal Div_R_e_i    : STD_LOGIC_VECTOR(3 downto 0); 
    signal SIGN_Q_e_i   : STD_LOGIC;

    signal SIGN_C_i     : STD_LOGIC;
begin

    U_ABS_A : Abs_4bit
        port map (
            X      => A,
            MAG_X  => s_MAG_A,
            SIGN_X => s_SIGN_A
        );

    U_ABS_B : Abs_4bit
        port map (
            X      => B,
            MAG_X  => s_MAG_B,
            SIGN_X => s_SIGN_B
        );

    SIGN_A <= s_SIGN_A;
    SIGN_B <= s_SIGN_B;

    Start_AddSub <= Start when (Sel = "00" or Sel = "01") else '0';
    Start_Mul    <= Start when (Sel = "10") else '0';
    Start_Div    <= Start when (Sel = "11") else '0';

    U_ADDSUB_TOP : Top_AddSub
        port map (
            CLK     => CLK,
            RESET   => Reset,
            Start   => Start_AddSub,
            Sel     => Sel,           
            A       => A,
            B       => B,
            Result  => AddSub_Res_i,
            Done    => open,
            OP_Code => open
        );

    AddSub_Result <= AddSub_Res_i;

    U_MUL : Multiplier_4bit
        port map (
            Clk    => CLK,
            Reset  => Reset,
            Start  => Start_Mul,
            A_in   => s_MAG_A,
            B_in   => s_MAG_B,
            Result => Mul_Res_i,
            Done   => Done_Mul
        );

    Mul_Result <= Mul_Res_i;

    U_DIV : Divider_4bit
        port map (
            Clk       => CLK,
            Reset     => Reset,
            Start     => Start_Div,
            A_in      => s_MAG_A,
            B_in      => s_MAG_B,
            Quotient  => Div_Q_i,
            Remainder => Div_R_i,
            Done      => Done_Div
        );

    U_EUCLID : Euclid_Div_Adjust
        port map (
            SIGN_A   => s_SIGN_A,
            SIGN_B   => s_SIGN_B,
            Q_mag    => Div_Q_i,
            R_mag    => Div_R_i,
            B_mag    => s_MAG_B,
            Q_e      => Div_Q_e_i,
            R_e      => Div_R_e_i,
            SIGN_Q_e => SIGN_Q_e_i
        );

    Div_Quotient  <= Div_Q_e_i;
    Div_Remainder <= Div_R_e_i;

    with Sel select
        SIGN_C_i <=
            AddSub_Res_i(4)          when "00", 
            AddSub_Res_i(4)          when "01", 
            (s_SIGN_A xor s_SIGN_B)  when "10",  
            SIGN_Q_e_i               when "11", 
            '0'                      when others;

    SIGN_C <= SIGN_C_i;

    Done <= Done_Mul when Sel = "10" else
            Done_Div when Sel = "11" else
            '0';

end Structural;
