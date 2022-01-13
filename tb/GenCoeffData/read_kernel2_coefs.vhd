--12302021 [12-30-2021]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
use work.tbpackage.all;
entity read_kernel2_coefs is
generic (
    s_data_width  : integer := 16;
    input_file    : string  := "input_image");
port (
    clk             : in std_logic;
    reset           : in std_logic;
    iCord           : in coord;
    kSet1Out        : out  kernelCoeff);
end read_kernel2_coefs;
architecture Behavioral of read_kernel2_coefs is
constant projFold   : string := "K:/ZEDBOARD/simulations/Coeff_Data";
constant backSlash  : string := "/";
file test_vector    : text open read_mode is projFold&backSlash&input_file&".txt";
constant num_col    : integer := 10;
type t_integer_array    is array(integer range <> )  of integer;
begin
p_read : process(reset,clk)
variable row                    : line;
variable v_data_read            : t_integer_array(1 to num_col);
begin
    if(reset=lo) then
        v_data_read            := (others=> 0);
    elsif(rising_edge(clk)) then
    if(v_data_read(10) /= 999) then
        if(not endfile(test_vector)) then
            readline(test_vector,row);
        end if;
        for i in 1 to num_col loop
            read(row,v_data_read(i));
        end loop;
    end if;
         kSet1Out.k1    <= std_logic_vector(to_signed((v_data_read(1)),16));
         kSet1Out.k2    <= std_logic_vector(to_signed((v_data_read(2)),16));
         kSet1Out.k3    <= std_logic_vector(to_signed((v_data_read(3)),16));
         kSet1Out.k4    <= std_logic_vector(to_signed((v_data_read(4)),16));
         kSet1Out.k5    <= std_logic_vector(to_signed((v_data_read(5)),16));
         kSet1Out.k6    <= std_logic_vector(to_signed((v_data_read(6)),16));
         kSet1Out.k7    <= std_logic_vector(to_signed((v_data_read(7)),16));
         kSet1Out.k8    <= std_logic_vector(to_signed((v_data_read(8)),16));
         kSet1Out.k9    <= std_logic_vector(to_signed((v_data_read(9)),16));
         kSet1Out.kSet  <= (v_data_read(10));
    end if;
end process p_read;
--257 504 98 -148 -291 439 439 -368 -71 61
--1400 -125 -125 -125 1200 -125 -125 -125 800 54
--257 504 98 -148 -291 439 439 -239 -71 6
--1600 -125 -275 -125 1600 -275 -275 -100 1600 2
end Behavioral;