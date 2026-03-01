library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AddSub_Controller is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        Start   : in  STD_LOGIC;
        Sel     : in  STD_LOGIC_VECTOR(1 downto 0); -- 00:Add, 01:Sub

        -- control to datapath
        Op_Sel  : out STD_LOGIC;                    -- to Signed_Adder_Sub.Op_Sel
        Done    : out STD_LOGIC;                    -- one-clock pulse when result ready
        OP_Code : out STD_LOGIC_VECTOR(2 downto 0)  -- encoding for output display
    );
end AddSub_Controller;

architecture Behavioral of AddSub_Controller is

    type state_type is (IDLE, DONE_STATE);
    signal state : state_type := IDLE;

    -- registered outputs
    signal r_Op_Sel  : STD_LOGIC := '0';
    signal r_Done    : STD_LOGIC := '0';
    signal r_OP_Code : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

begin

    -- drive ports from registers
    Op_Sel  <= r_Op_Sel;
    Done    <= r_Done;
    OP_Code <= r_OP_Code;

    process(CLK, RESET)
    begin
        if RESET = '1' then
            state     <= IDLE;
            r_Op_Sel  <= '0';
            r_Done    <= '0';
            r_OP_Code <= (others => '0');

        elsif rising_edge(CLK) then
            case state is

                when IDLE =>
                    r_Done <= '0';  -- default

                    if Start = '1' then
                        case Sel is
                            when "00" =>           -- ADD
                                r_Op_Sel  <= '0';   -- addition
                                r_OP_Code <= "100";
                                r_Done    <= '1';   -- result ready now
                                state     <= DONE_STATE;

                            when "01" =>           -- SUB
                                r_Op_Sel  <= '1';   -- subtraction
                                r_OP_Code <= "101";
                                r_Done    <= '1';
                                state     <= DONE_STATE;

                            when others =>
                                -- unsupported operation yet (10,11)
                                r_Done <= '0';
                                -- stay in IDLE
                        end case;
                    end if;

                when DONE_STATE =>
                    r_Done <= '0';  -- pulse only 1 clock

                    -- Wait for Start to go low before allowing new operation
                    if Start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;

