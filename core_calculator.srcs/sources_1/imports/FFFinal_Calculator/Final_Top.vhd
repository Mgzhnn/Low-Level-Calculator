library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Final_Top_Calculator is
    Port ( 
        Clk    : in  STD_LOGIC;
        Reset  : in  STD_LOGIC;
        Start  : in  STD_LOGIC;
        Sel    : in  STD_LOGIC_VECTOR (1 downto 0);
        A      : in  STD_LOGIC_VECTOR (3 downto 0);
        B      : in  STD_LOGIC_VECTOR (3 downto 0);
        
        Done   : out STD_LOGIC;
        a_to_g : out STD_LOGIC_VECTOR (7 downto 0);
        an     : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Final_Top_Calculator;

architecture Structural of Final_Top_Calculator is
    
    component Core_Calculator
        Port (
            CLK, Reset, Start : in  STD_LOGIC;
            Sel    : in  STD_LOGIC_VECTOR(1 downto 0);
            A, B   : in  STD_LOGIC_VECTOR(3 downto 0);
            
            AddSub_Result : out STD_LOGIC_VECTOR(4 downto 0);
            Mul_Result    : out STD_LOGIC_VECTOR(7 downto 0);
            Div_Quotient  : out STD_LOGIC_VECTOR(3 downto 0);
            Div_Remainder : out STD_LOGIC_VECTOR(3 downto 0);
            
            SIGN_A, SIGN_B, SIGN_C : out STD_LOGIC;
            Done   : out STD_LOGIC
        );
    end component;

    component Display_Encoder
        Port (
            Sel           : in  STD_LOGIC_VECTOR(1 downto 0);
            mag_A, mag_B  : in  STD_LOGIC_VECTOR(3 downto 0);
            sign_A, sign_B: in  STD_LOGIC;
            AddSub_Mag    : in  STD_LOGIC_VECTOR(4 downto 0);
            AddSub_Sign   : in  STD_LOGIC;
            Mul_Result    : in  STD_LOGIC_VECTOR(7 downto 0);
            Mul_Sign      : in  STD_LOGIC;
            Div_Quotient  : in  STD_LOGIC_VECTOR(3 downto 0);
            Div_Remainder : in  STD_LOGIC_VECTOR(3 downto 0);
            Div_Sign      : in  STD_LOGIC;
            x_inter       : out STD_LOGIC_VECTOR(21 downto 0)
        );
    end component;
    
    component negative_complement
        Port ( A : in STD_LOGIC_VECTOR(3 downto 0); pos_A : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component myseven_segments
        port( x:in std_logic_vector(21 downto 0);
              clk, clr, reset: in std_logic;
              a_to_g, an: out std_logic_vector(7 downto 0));
    end component;
    
    
    signal c_AddSub_Res : STD_LOGIC_VECTOR(4 downto 0);
    signal c_Mul_Res    : STD_LOGIC_VECTOR(7 downto 0);
    signal c_Div_Q      : STD_LOGIC_VECTOR(3 downto 0);
    signal c_Div_R      : STD_LOGIC_VECTOR(3 downto 0);
    signal c_Sign_A, c_Sign_B : STD_LOGIC;
    signal c_Done       : STD_LOGIC;
    signal c_core_Sign : STD_LOGIC;
    
    signal Stable_Mul_Res : STD_LOGIC_VECTOR(7 downto 0);
    signal Stable_Div_Q   : STD_LOGIC_VECTOR(3 downto 0);
    signal Stable_Div_R   : STD_LOGIC_VECTOR(3 downto 0);   

    signal s_mag_A, s_mag_B : STD_LOGIC_VECTOR(3 downto 0);
    signal s_sign_A, s_sign_B : STD_LOGIC;
    
    signal s_AddSub_Mag : STD_LOGIC_VECTOR(4 downto 0);
    signal s_AddSub_Sign: STD_LOGIC;
    signal s_Mul_Sign   : STD_LOGIC;
    signal s_Div_Sign   : STD_LOGIC;
    
    signal s_x_inter    : STD_LOGIC_VECTOR(21 downto 0);

begin

    U_NEG_A: negative_complement port map (A => A, pos_A => s_mag_A);
    U_NEG_B: negative_complement port map (A => B, pos_A => s_mag_B);
    s_sign_A <= A(3);
    s_sign_B <= B(3);

    U_CORE: Core_Calculator
    port map (
        CLK => Clk, Reset => Reset, Start => Start, Sel => Sel,
        A => A, B => B,
        AddSub_Result => c_AddSub_Res,
        Mul_Result    => c_Mul_Res,
        Div_Quotient  => c_Div_Q, 
        Div_Remainder => c_Div_R,
        SIGN_A => c_Sign_A, SIGN_B => c_Sign_B, SIGN_C => c_core_Sign,
        Done => c_Done
    );
    
    Done <= c_Done; 
    s_AddSub_Sign <= c_AddSub_Res(4);
        
    process(Clk, Reset)
    begin
        if Reset = '1' then
            Stable_Mul_Res <= (others => '0');
            Stable_Div_Q   <= (others => '0');
            Stable_Div_R   <= (others => '0');
        elsif rising_edge(Clk) then
            if Sel = "10" and c_Done = '1' then
                Stable_Mul_Res <= c_Mul_Res;
                if c_Mul_Res = "00000000" then
                s_Mul_Sign <= '0';
            else
                s_Mul_Sign <= c_core_Sign;
            end if;
                
            end if;
            if Sel = "11" and c_Done = '1' then
                Stable_Div_Q <= c_Div_Q;
                Stable_Div_R <= c_Div_R;
                s_Div_Sign   <= c_core_Sign;
            end if;
        end if;
    end process;

    process(c_AddSub_Res)
        variable inv : std_logic_vector(4 downto 0);
        variable cry : std_logic;
        variable res : std_logic_vector(4 downto 0);
    begin
        if c_AddSub_Res(4) = '0' then
            s_AddSub_Mag <= c_AddSub_Res;
        else
            inv := not c_AddSub_Res;
            cry := '1';
            for i in 0 to 4 loop
                res(i) := inv(i) xor cry;
                cry := inv(i) and cry;
            end loop;
            s_AddSub_Mag <= res;
        end if;
    end process;
    
    U_ENC: Display_Encoder
    port map (
        Sel => Sel,
        mag_A => s_mag_A, sign_A => s_sign_A,
        mag_B => s_mag_B, sign_B => s_sign_B,
        AddSub_Mag => s_AddSub_Mag, AddSub_Sign => s_AddSub_Sign,

        Mul_Result => Stable_Mul_Res,    
        Mul_Sign => s_Mul_Sign,

        Div_Quotient => Stable_Div_Q,    
        Div_Remainder => Stable_Div_R, 
        Div_Sign => s_Div_Sign,
        
        x_inter => s_x_inter
    );

    U_FND: myseven_segments
    port map (
        x => s_x_inter,
        clk => Clk,
        clr => Start, 
        reset => Reset,
        a_to_g => a_to_g,
        an => an
    );

end Structural;
