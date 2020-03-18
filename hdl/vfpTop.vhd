-------------------------------------------------------------------------------
--
-- Filename    : VFP_v1_0.vhd
-- Create Date : 05062019 [05-06-2019]
-- Author      : Zakinder
--
-- Description:
-- This file instantiation top level video frame process components.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;

entity VFP_v1_0 is
generic (
    -- System Revision
    revision_number           : std_logic_vector(31 downto 0) := x"03072020";
    -- Axi4 Master-Stream Connected to Inner LoopBack
    C_rgb_m_axis_TDATA_WIDTH  : integer := 16;
    C_rgb_m_axis_START_COUNT  : integer := 32;
    -- Axi4 Slave-Stream Connected to Inner LoopBack
    C_rgb_s_axis_TDATA_WIDTH  : integer := 16;
    -- Axi4 Master-Stream Connected to VDMA
    C_m_axis_mm2s_TDATA_WIDTH : integer := 16;
    C_m_axis_mm2s_START_COUNT : integer := 32;
    -- Axi4 Lite
    C_vfpConfig_DATA_WIDTH    : integer := 32;
    C_vfpConfig_ADDR_WIDTH    : integer := 8;
    conf_data_width           : integer := 32;
    conf_addr_width           : integer := 8;
    -- VFP filters data widths
    i_data_width              : integer := 8;
    s_data_width              : integer := 16;
    b_data_width              : integer := 32;
    -- D5m Camera Raw Data Settings
    d5m_data_width            : integer := 12;
    d5m_frame_width           : integer := 4096;
    -- HD Video
    bmp_width                 : integer := 1920;
    bmp_height                : integer := 1080;
    bmp_precision             : integer := 12;
    -- Set filters
    F_CGA_FULL_RANGE          : boolean := false;
    F_TES                     : boolean := true;
    F_LUM                     : boolean := false;
    F_TRM                     : boolean := false;
    F_RGB                     : boolean := true;
    F_SHP                     : boolean := true;
    F_BLU                     : boolean := false;
    F_EMB                     : boolean := false;
    F_YCC                     : boolean := true;
    F_SOB                     : boolean := true;
    F_CGA                     : boolean := true;
    F_HSV                     : boolean := true;
    F_HSL                     : boolean := true);
port (
    -- d5m input
    pixclk                    : in std_logic;
    ifval                     : in std_logic;
    ilval                     : in std_logic;
    idata                     : in std_logic_vector(d5m_data_width - 1 downto 0);
    -- tx channel
    rgb_m_axis_aclk           : in std_logic;
    rgb_m_axis_aresetn        : in std_logic;
    rgb_m_axis_tready         : in std_logic;
    rgb_m_axis_tvalid         : out std_logic;
    rgb_m_axis_tlast          : out std_logic;
    rgb_m_axis_tuser          : out std_logic;
    rgb_m_axis_tdata          : out std_logic_vector(C_rgb_m_axis_TDATA_WIDTH-1 downto 0);
    -- rx channel
    rgb_s_axis_aclk           : in std_logic;
    rgb_s_axis_aresetn        : in std_logic;
    rgb_s_axis_tready         : out std_logic;
    rgb_s_axis_tvalid         : in std_logic;
    rgb_s_axis_tuser          : in std_logic;
    rgb_s_axis_tlast          : in std_logic;
    rgb_s_axis_tdata          : in std_logic_vector(C_rgb_s_axis_TDATA_WIDTH-1 downto 0);
    -- destination channel
    m_axis_mm2s_aclk          : in std_logic;
    m_axis_mm2s_aresetn       : in std_logic;
    m_axis_mm2s_tready        : in std_logic;
    m_axis_mm2s_tvalid        : out std_logic;
    m_axis_mm2s_tuser         : out std_logic;
    m_axis_mm2s_tlast         : out std_logic;
    m_axis_mm2s_tdata         : out std_logic_vector(C_m_axis_mm2s_TDATA_WIDTH-1 downto 0);
    m_axis_mm2s_tkeep         : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tstrb         : out std_logic_vector(2 downto 0);
    m_axis_mm2s_tid           : out std_logic_vector(0 downto 0);
    m_axis_mm2s_tdest         : out std_logic_vector(0 downto 0);
    -- video configuration
    vfpconfig_aclk            : in std_logic;
    vfpconfig_aresetn         : in std_logic;
    vfpconfig_awaddr          : in std_logic_vector(C_vfpConfig_ADDR_WIDTH-1 downto 0);
    vfpconfig_awprot          : in std_logic_vector(2 downto 0);
    vfpconfig_awvalid         : in std_logic;
    vfpconfig_awready         : out std_logic;
    vfpconfig_wdata           : in std_logic_vector(C_vfpConfig_DATA_WIDTH-1 downto 0);
    vfpconfig_wstrb           : in std_logic_vector((C_vfpConfig_DATA_WIDTH/8)-1 downto 0);
    vfpconfig_wvalid          : in std_logic;
    vfpconfig_wready          : out std_logic;
    vfpconfig_bresp           : out std_logic_vector(1 downto 0);
    vfpconfig_bvalid          : out std_logic;
    vfpconfig_bready          : in std_logic;
    vfpconfig_araddr          : in std_logic_vector(C_vfpConfig_ADDR_WIDTH-1 downto 0);
    vfpconfig_arprot          : in std_logic_vector(2 downto 0);
    vfpconfig_arvalid         : in std_logic;
    vfpconfig_arready         : out std_logic;
    vfpconfig_rdata           : out std_logic_vector(C_vfpConfig_DATA_WIDTH-1 downto 0);
    vfpconfig_rresp           : out std_logic_vector(1 downto 0);
    vfpconfig_rvalid          : out std_logic;
    vfpconfig_rready          : in std_logic);
end VFP_v1_0;

architecture arch_imp of VFP_v1_0 is

    constant adwrWidth        : integer := 16;
    constant addrWidth        : integer := 12;
    
    signal s_mm_axi           : integer := 0;
    signal s_rgb_set          : rRgb;
    signal s_wr_regs          : mRegs;
    signal s_rd_regs          : mRegs;
    signal s_video_data       : vStreamData;

begin


-- This module recieve stream raw data in format of bayer pattern from d5m camera device 
-- and it convert into 24 bit rgb pixel value with its frame mapped coordinates, start of 
-- frame, end of frame and line valid.
bayer_to_rgb_inst: bayer_to_rgb
generic map(
    -- d5m camera max supported frame width 3741.
    img_width                 => d5m_frame_width,
    -- d5m camera input data width.
    dataWidth                 => d5m_data_width)
port map(
    -- system clock
    clk                       => m_axis_mm2s_aclk,
    -- system async reset
    rst_l                     => m_axis_mm2s_aresetn,
    -- d5m clock
    pixclk                    => pixclk,
    -- d5m frame valid
    ifval                     => ifval,
    -- d5m line valid
    ilval                     => ilval,
    -- d5m data
    idata                     => idata,
    -- rgb frame data set record
    oRgbSet                   => s_rgb_set);


-- This module implement master requests, process frames and select video channel.
video_stream_inst: video_stream
generic map(
    revision_number           => revision_number,
    i_data_width              => i_data_width,
    s_data_width              => s_data_width,
    b_data_width              => b_data_width,
    img_width                 => d5m_frame_width,
    adwrWidth                 => adwrWidth,
    addrWidth                 => addrWidth,
    bmp_width                 => bmp_width,
    bmp_height                => bmp_height,
    F_TES                     => F_TES,
    F_LUM                     => F_LUM,
    F_TRM                     => F_TRM,
    F_RGB                     => F_RGB,
    F_SHP                     => F_SHP,
    F_BLU                     => F_BLU,
    F_EMB                     => F_EMB,
    F_YCC                     => F_YCC,
    F_SOB                     => F_SOB,
    F_CGA                     => F_CGA,
    F_HSV                     => F_HSV,
    F_HSL                     => F_HSL)
port map(
    -- system clock
    clk                       => m_axis_mm2s_aclk,
    -- system async reset
    rst_l                     => m_axis_mm2s_aresetn,
    -- master write registers
    iWrRegs                   => s_wr_regs,
    -- master read registers
    oRdRegs                   => s_rd_regs,
    -- rgb frame data set record
    iRgbSet                   => s_rgb_set,
    -- filtered rgb data
    oVideoData                => s_video_data,
    -- end node bus select configed by master
    oMmAxi                    => s_mm_axi);

-- This module transmit filtered video data to axi4 stream and transmit and recieve request from master.
axis_external_inst: axi_external
generic map(
    revision_number           => revision_number,
    C_rgb_m_axis_TDATA_WIDTH  => C_rgb_m_axis_TDATA_WIDTH,
    C_rgb_s_axis_TDATA_WIDTH  => C_rgb_s_axis_TDATA_WIDTH,
    C_m_axis_mm2s_TDATA_WIDTH => C_m_axis_mm2s_TDATA_WIDTH,
    C_vfpConfig_DATA_WIDTH    => C_vfpConfig_DATA_WIDTH,
    C_vfpConfig_ADDR_WIDTH    => C_vfpConfig_ADDR_WIDTH,
    conf_data_width           => conf_data_width,
    conf_addr_width           => conf_addr_width,
    i_data_width              => i_data_width,
    s_data_width              => s_data_width,
    b_data_width              => b_data_width)
port map(
    -- end node bus select configed by master
    iMmAxi                    => s_mm_axi,
    -- filtered rgb data
    iStreamData               => s_video_data,
    -- master write registers
    oWrRegs                   => s_wr_regs,
    -- master read registers
    iRdRegs                   => s_rd_regs,
    --tx channel
    rgb_m_axis_aclk           => rgb_m_axis_aclk,
    rgb_m_axis_aresetn        => rgb_m_axis_aresetn,
    rgb_m_axis_tready         => rgb_m_axis_tready,
    rgb_m_axis_tvalid         => rgb_m_axis_tvalid,
    rgb_m_axis_tlast          => rgb_m_axis_tlast,
    rgb_m_axis_tuser          => rgb_m_axis_tuser,
    rgb_m_axis_tdata          => rgb_m_axis_tdata,
    --rx channel
    rgb_s_axis_aclk           => rgb_s_axis_aclk,
    rgb_s_axis_aresetn        => rgb_s_axis_aresetn,
    rgb_s_axis_tready         => rgb_s_axis_tready,
    rgb_s_axis_tvalid         => rgb_s_axis_tvalid,
    rgb_s_axis_tuser          => rgb_s_axis_tuser,
    rgb_s_axis_tlast          => rgb_s_axis_tlast,
    rgb_s_axis_tdata          => rgb_s_axis_tdata,
    --destination channel
    m_axis_mm2s_aclk          => m_axis_mm2s_aclk,
    m_axis_mm2s_aresetn       => m_axis_mm2s_aresetn,
    m_axis_mm2s_tready        => m_axis_mm2s_tready,
    m_axis_mm2s_tvalid        => m_axis_mm2s_tvalid,
    m_axis_mm2s_tuser         => m_axis_mm2s_tuser,
    m_axis_mm2s_tlast         => m_axis_mm2s_tlast,
    m_axis_mm2s_tdata         => m_axis_mm2s_tdata,
    m_axis_mm2s_tkeep         => m_axis_mm2s_tkeep,
    m_axis_mm2s_tstrb         => m_axis_mm2s_tstrb,
    m_axis_mm2s_tid           => m_axis_mm2s_tid,
    m_axis_mm2s_tdest         => m_axis_mm2s_tdest,
    --video configuration
    vfpconfig_aclk            => vfpconfig_aclk,
    vfpconfig_aresetn         => vfpconfig_aresetn,
    vfpconfig_awaddr          => vfpconfig_awaddr,
    vfpconfig_awprot          => vfpconfig_awprot,
    vfpconfig_awvalid         => vfpconfig_awvalid,
    vfpconfig_awready         => vfpconfig_awready,
    vfpconfig_wdata           => vfpconfig_wdata,
    vfpconfig_wstrb           => vfpconfig_wstrb,
    vfpconfig_wvalid          => vfpconfig_wvalid,
    vfpconfig_wready          => vfpconfig_wready,
    vfpconfig_bresp           => vfpconfig_bresp,
    vfpconfig_bvalid          => vfpconfig_bvalid,
    vfpconfig_bready          => vfpconfig_bready,
    vfpconfig_araddr          => vfpconfig_araddr,
    vfpconfig_arprot          => vfpconfig_arprot,
    vfpconfig_arvalid         => vfpconfig_arvalid,
    vfpconfig_arready         => vfpconfig_arready,
    vfpconfig_rdata           => vfpconfig_rdata,
    vfpconfig_rresp           => vfpconfig_rresp,
    vfpconfig_rvalid          => vfpconfig_rvalid,
    vfpconfig_rready          => vfpconfig_rready);
    
end arch_imp;