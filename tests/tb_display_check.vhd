library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Self-checking display test (VHDL-2008):
--  * with Start resting at '0', all 8 digits are scanned
--  * the result sign digit is blank for a positive result and "-" for a negative one
--  * changing Sel between add and subtract updates the value without pressing Start
entity tb_display_check is
end tb_display_check;

architecture sim of tb_display_check is
    signal Clk, Reset, Start : std_logic := '0';
    signal Sel : std_logic_vector(1 downto 0) := "00";
    signal A, B : std_logic_vector(3 downto 0) := "0000";
    signal Done : std_logic;
    signal a_to_g, an : std_logic_vector(7 downto 0);
    signal running : boolean := true;

    constant SEG_BLANK : std_logic_vector(7 downto 0) := "00000000";
    constant SEG_MINUS : std_logic_vector(7 downto 0) := "01000000";
    constant AN_RESULT_SIGN : std_logic_vector(7 downto 0) := "00001000";
    -- One full scan of the 8 digits: clkdiv(20 downto 18) steps every 2**18 cycles
    constant SCAN_CYCLES : natural := 8 * 2**18 + 100;
begin
    uut: entity work.Final_Top_Calculator
        port map (Clk => Clk, Reset => Reset, Start => Start, Sel => Sel, A => A, B => B,
                  Done => Done, a_to_g => a_to_g, an => an);

    Clk <= not Clk after 5 ns when running else '0';

    process
        alias x is <<signal .tb_display_check.uut.s_x_inter : std_logic_vector(21 downto 0)>>;
        variable seen, sign_seg : std_logic_vector(7 downto 0);
        variable errors : integer := 0;

        procedure press_start is
        begin
            wait until rising_edge(Clk);
            Start <= '1';
            wait until rising_edge(Clk);
            Start <= '0';
            for k in 1 to 3 loop
                wait until rising_edge(Clk);
            end loop;
        end procedure;

        -- Scan once; return the digit enables seen and the segments of the result sign digit
        procedure scan is
        begin
            seen := (others => '0');
            for k in 1 to SCAN_CYCLES loop
                wait until rising_edge(Clk);
                seen := seen or an;
                if an = AN_RESULT_SIGN then
                    sign_seg := a_to_g;
                end if;
            end loop;
        end procedure;

        impure function value return integer is
        begin
            return to_integer(unsigned(x(10 downto 7))) * 10 + to_integer(unsigned(x(6 downto 3)));
        end function;
    begin
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';

        -- 3 + 2 = 5, then leave Start at '0'
        Sel <= "00"; A <= "0011"; B <= "0010";
        press_start;
        scan;
        if seen /= "11111111" then
            errors := errors + 1;
            report "digits scanned with Start = '0': " & to_string(seen) & ", want 11111111";
        end if;
        if sign_seg /= SEG_BLANK then
            errors := errors + 1;
            report "sign digit for +5 is " & to_string(sign_seg) & ", want blank";
        end if;

        -- Switch to subtract without pressing Start: 3 - 2 = 1
        Sel <= "01";
        wait until rising_edge(Clk);
        wait for 1 ns;
        if x(2 downto 0) /= "101" or value /= 1 then
            errors := errors + 1;
            report "after Sel -> subtract: op " & to_string(x(2 downto 0)) & " value " & integer'image(value) & ", want 101 and 1";
        end if;

        -- 2 - 3 = -1: the sign digit must show "-"
        A <= "0010"; B <= "0011";
        scan;
        if sign_seg /= SEG_MINUS then
            errors := errors + 1;
            report "sign digit for -1 is " & to_string(sign_seg) & ", want minus";
        end if;

        if errors = 0 then
            report "PASS tb_display_check: scanning, sign digits, add/subtract select";
        else
            report "FAIL tb_display_check: " & integer'image(errors) & " mismatches";
        end if;
        running <= false;
        wait;
    end process;
end sim;
