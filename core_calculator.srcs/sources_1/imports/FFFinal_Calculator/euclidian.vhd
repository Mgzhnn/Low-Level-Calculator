library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Euclid_Div_Adjust is
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
end Euclid_Div_Adjust;

architecture Structural of Euclid_Div_Adjust is

    component Signed_Adder_Sub is
        Port (
            A       : in  STD_LOGIC_VECTOR (3 downto 0);
            B       : in  STD_LOGIC_VECTOR (3 downto 0);
            Op_Sel  : in  STD_LOGIC;
            Result  : out STD_LOGIC_VECTOR (4 downto 0);
            Co      : out STD_LOGIC
        );
    end component;

    signal sign_diff  : STD_LOGIC;
    signal R_is_zero  : STD_LOGIC;
    
    signal Q_neg_res   : STD_LOGIC_VECTOR(4 downto 0);
    signal Q_neg       : STD_LOGIC_VECTOR(3 downto 0);
    
    signal Q_negm1_res : STD_LOGIC_VECTOR(4 downto 0);
    signal Q_negm1     : STD_LOGIC_VECTOR(3 downto 0);

    signal Q_plus1_res : STD_LOGIC_VECTOR(4 downto 0);
    signal Q_plus1     : STD_LOGIC_VECTOR(3 downto 0);

    signal R_corr_res  : STD_LOGIC_VECTOR(4 downto 0);
    signal R_corr      : STD_LOGIC_VECTOR(3 downto 0);
    
    signal Q_e_internal : STD_LOGIC_VECTOR(3 downto 0);

begin

    sign_diff <= SIGN_A xor SIGN_B;
    R_is_zero <= '1' when R_mag = "0000" else '0';

    U_Q_NEG : Signed_Adder_Sub
        port map (
            A       => "0000",
            B       => Q_mag,
            Op_Sel  => '1',
            Result  => Q_neg_res,
            Co      => open
        );
    Q_neg <= Q_neg_res(3 downto 0);

    U_Q_NEG_MINUS1 : Signed_Adder_Sub
        port map (
            A       => Q_neg,
            B       => "0001",
            Op_Sel  => '1', -- Subtract 1
            Result  => Q_negm1_res,
            Co      => open
        );
    Q_negm1 <= Q_negm1_res(3 downto 0);

    U_Q_PLUS1 : Signed_Adder_Sub
        port map (
            A       => Q_mag,
            B       => "0001",
            Op_Sel  => '0', -- Add 1
            Result  => Q_plus1_res,
            Co      => open
        );
    Q_plus1 <= Q_plus1_res(3 downto 0);

    U_R_CORR : Signed_Adder_Sub
        port map (
            A       => B_mag,
            B       => R_mag,
            Op_Sel  => '1',
            Result  => R_corr_res,
            Co      => open
        );
    R_corr <= R_corr_res(3 downto 0);

    process(SIGN_A, sign_diff, R_is_zero, Q_mag, Q_neg, Q_negm1, Q_plus1, R_mag, R_corr)
    begin
        if R_is_zero = '1' or SIGN_A = '0' then
            R_e <= R_mag;
            if sign_diff = '0' then
                Q_e_internal <= Q_mag;  
            else
                Q_e_internal <= Q_neg;  
            end if;
            
        else 
            R_e <= R_corr; -- R = |B| - r
            
            if sign_diff = '0' then
                Q_e_internal <= Q_plus1; 
            else
                Q_e_internal <= Q_negm1;
            end if;
        end if;
    end process;

    Q_e <= Q_e_internal;
    SIGN_Q_e <= '0' when Q_e_internal = "0000" else sign_diff;

end Structural;
