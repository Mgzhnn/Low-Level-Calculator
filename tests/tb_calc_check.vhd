library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Self-checking test: every operation on all 256 signed (A, B) pairs. Compares the
-- sign and digits sent to the display (x_inter) with reference arithmetic.
-- Division is Euclidean (0 <= r < |b|); division by zero must show "--" with no sign.
-- Needs VHDL-2008 (external name for x_inter).
entity tb_calc_check is
end tb_calc_check;

architecture sim of tb_calc_check is
    signal Clk, Reset, Start : std_logic := '0';
    signal Sel : std_logic_vector(1 downto 0) := "00";
    signal A, B : std_logic_vector(3 downto 0) := "0000";
    signal Done : std_logic;
    signal a_to_g, an : std_logic_vector(7 downto 0);
    signal running : boolean := true;
begin
    uut: entity work.Final_Top_Calculator
        port map (Clk => Clk, Reset => Reset, Start => Start, Sel => Sel, A => A, B => B,
                  Done => Done, a_to_g => a_to_g, an => an);

    Clk <= not Clk after 5 ns when running else '0';

    process
        alias x is <<signal .tb_calc_check.uut.s_x_inter : std_logic_vector(21 downto 0)>>;
        variable want, q, r, got_val, got_r, errors : integer;
        variable got_neg : boolean;

        procedure run_op(op : std_logic_vector(1 downto 0); av, bv : integer) is
        begin
            Sel <= op;
            A <= std_logic_vector(to_signed(av, 4));
            B <= std_logic_vector(to_signed(bv, 4));
            wait until rising_edge(Clk);
            Start <= '1';
            wait until rising_edge(Clk);
            Start <= '0';
            if op(1) = '1' then
                wait until rising_edge(Clk) and Done = '1';
            end if;
            for k in 1 to 3 loop
                wait until rising_edge(Clk);
            end loop;
            wait for 1 ns;
        end procedure;

        procedure fail(msg : string) is
        begin
            errors := errors + 1;
            if errors <= 12 then
                report msg;
            end if;
        end procedure;
    begin
        errors := 0;
        Reset <= '1';
        wait for 20 ns;
        Reset <= '0';

        for op in 0 to 3 loop
            for av in -8 to 7 loop
                for bv in -8 to 7 loop
                    run_op(std_logic_vector(to_unsigned(op, 2)), av, bv);
                    got_neg := x(11) = '1';
                    got_val := to_integer(unsigned(x(10 downto 7))) * 10 + to_integer(unsigned(x(6 downto 3)));

                    if op < 3 then
                        case op is
                            when 0      => want := av + bv;
                            when 1      => want := av - bv;
                            when others => want := av * bv;
                        end case;
                        if got_val /= abs(want) or got_neg /= (want < 0) then
                            fail("op " & integer'image(op) & " on " & integer'image(av) & ", " & integer'image(bv) &
                                 ": shows negative=" & boolean'image(got_neg) & " " & integer'image(got_val) &
                                 ", want " & integer'image(want));
                        end if;

                    elsif bv = 0 then
                        if x(10 downto 3) /= "11011101" or got_neg then
                            fail("divide " & integer'image(av) & "/0 does not show --");
                        end if;

                    else
                        r := av mod abs(bv);
                        q := (av - r) / bv;
                        got_val := to_integer(unsigned(x(10 downto 7)));
                        got_r := to_integer(unsigned(x(6 downto 3)));
                        if got_val /= abs(q) or got_r /= r or got_neg /= (q < 0) then
                            fail("divide " & integer'image(av) & "/" & integer'image(bv) &
                                 ": shows negative=" & boolean'image(got_neg) & " q=" & integer'image(got_val) &
                                 " r=" & integer'image(got_r) & ", want q=" & integer'image(q) & " r=" & integer'image(r));
                        end if;
                    end if;
                end loop;
            end loop;
        end loop;

        if errors = 0 then
            report "PASS tb_calc_check: 4 operations x 256 input pairs";
        else
            report "FAIL tb_calc_check: " & integer'image(errors) & " mismatches";
        end if;
        running <= false;
        wait;
    end process;
end sim;
