-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 08.07.2015 13:35:52
-- Module Name : pcie_uv7_rx.vhd
--
-- Description :
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reduce_pack.all;
use work.pcie_pkg.all;

entity pcie_uv7_rx is
generic (
--AXISTEN_IF_WIDTH               : std_logic_vector(1 downto 0) := "00";
AXISTEN_IF_CQ_ALIGNMENT_MODE   : string := "FALSE";
AXISTEN_IF_RC_ALIGNMENT_MODE   : string := "FALSE";
AXISTEN_IF_RC_STRADDLE         : integer := 0;
AXISTEN_IF_ENABLE_RX_MSG_INTFC : integer := 0;
AXISTEN_IF_ENABLE_MSG_ROUTE    : std_logic_vector(17 downto 0) := TO_UNSIGNED(16#2FFF, 18);

G_DATA_WIDTH   : integer := 64     ;
G_STRB_WIDTH   : integer := 64 / 8 ; -- TSTRB width
G_KEEP_WIDTH   : integer := 64 / 32;
G_PARITY_WIDTH : integer := 64 / 8   -- TPARITY width
);
port(
p_in_user_clk : in  std_logic;
p_in_reset_n  : in  std_logic;

-- Completer Request Interface
p_in_m_axis_cq_tdata      : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_cq_tlast      : in  std_logic;
p_in_m_axis_cq_tvalid     : in  std_logic;
p_in_m_axis_cq_tuser      : in  std_logic_vector(84 downto 0);
p_in_m_axis_cq_tkeep      : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_pcie_cq_np_req_count : in  std_logic_vector(5 downto 0);
p_out_m_axis_cq_tready    : out std_logic;
p_out_pcie_cq_np_req      : out std_logic;

-- Requester Completion Interface
p_in_m_axis_rc_tdata    : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
p_in_m_axis_rc_tlast    : in  std_logic;
p_in_m_axis_rc_tvalid   : in  std_logic;
p_in_m_axis_rc_tkeep    : in  std_logic_vector(G_KEEP_WIDTH - 1 downto 0);
p_in_m_axis_rc_tuser    : in  std_logic_vector(74 downto 0);
p_out_m_axis_rc_tready  : out std_logic;

--RX Message Interface
p_in_cfg_msg_received      : in  std_logic;
p_in_cfg_msg_received_type : in  std_logic_vector(4 downto 0);
p_in_cfg_msg_data          : in  std_logic_vector(7 downto 0);

-- Memory Read data handshake with Completion
-- transmit unit. Transmit unit reponds to
-- req_compl assertion and responds with compl_done
-- assertion when a Completion w/ data is transmitted.
p_out_req_compl    : out std_logic := '0';
p_out_req_compl_wd : out std_logic := '0';
p_out_req_compl_ur : out std_logic := '0';
p_in_compl_done    : in  std_logic;

p_out_req_tc       : out std_logic_vector(2 downto 0) ;-- Memory Read TC
p_out_req_attr     : out std_logic_vector(2 downto 0) ;-- Memory Read Attribute
p_out_req_len      : out std_logic_vector(10 downto 0);-- Memory Read Length
p_out_req_rid      : out std_logic_vector(15 downto 0);-- Memory Read Requestor ID { 8'b0 (Bus no),
                                                       --                            3'b0 (Dev no),
                                                       --                            5'b0 (Func no)}
p_out_req_tag      : out std_logic_vector(7 downto 0) ;-- Memory Read Tag
p_out_req_be       : out std_logic_vector(7 downto 0) ;-- Memory Read Byte Enables
p_out_req_addr     : out std_logic_vector(12 downto 0);-- Memory Read Address
p_out_req_at       : out std_logic_vector(1 downto 0) ;-- Address Translation

-- Outputs to the TX Block in case of an UR
-- Required to form the completions
p_out_req_des_qword0      : out std_logic_vector(63 downto 0);-- DWord0 and Dword1 of descriptor of the request
p_out_req_des_qword1      : out std_logic_vector(63 downto 0);-- DWord2 and Dword3 of descriptor of the request
p_out_req_des_tph_present : out std_logic;                    -- TPH Present in the request
p_out_req_des_tph_type    : out std_logic_vector(1 downto 0) ;-- If TPH Present then TPH type
p_out_req_des_tph_st_tag  : out std_logic_vector(7 downto 0) ;-- TPH Steering tag of the request

--Output to Indicate that the Request was a Mem lock Read Req
p_out_req_mem_lock : out std_logic;
p_out_req_mem      : out std_logic;

--Memory interface used to save 2 DW data received
--on Memory Write 32 TLP. Data extracted from
--inbound TLP is presented to the Endpoint memory
--unit. Endpoint memory unit reacts to wr_en
--assertion and asserts wr_busy when it is
--processing written information.
p_out_wr_addr     : out std_logic_vector(10 downto 0);-- Memory Write Address
p_out_wr_be       : out std_logic_vector(7 downto 0); -- Memory Write Byte Enable
p_out_wr_data     : out std_logic_vector(63 downto 0);-- Memory Write Data
p_out_wr_en       : out std_logic;                    -- Memory Write Enable
p_out_payload_len : out std_logic;                    -- Transaction Payload Length
p_in_wr_busy      : in  std_logic                     -- Memory Write Busy
);
end entity pcie_uv7_rx;

architecture behavioral of pcie_uv7_rx is

type TFsm_state is (
S_RX_IDLE    ,
S_RX_IOWR_QW1,
S_RX_IOWR_WT ,
S_RX_MWR_QW1 ,
-- S_RX_MWR_QW41,
-- S_RX_MWR_QW42,
S_RX_MWR_WT  ,
S_RX_MRD_QW1 ,
-- S_RX_MRD_QW41,
-- S_RX_MRD_QW42,
S_RX_MRD_WT  ,
S_RX_CPL_QW1 ,
S_RX_CPLD_QWN,
S_RX_CPLD_WT ,
S_RX_MRD_WT1
);
signal i_fsm_rx_cs            : TFsm_state;

signal i_in_pkt_q           : std_logic;
signal i_sop                : std_logic;

signal i_m_axis_cq_tready   : std_logic;


begin --architecture behavioral of pcie_uv7_rx


--Generate a signal that indicates if we are currently receiving a packet.
--This value is one clock cycle delayed from what is actually on the AXIS data bus.
process(p_in_user_clk)
begin
if rising_edge(p_in_user_clk) then
  if (p_in_reset_n = '0') then
    i_in_pkt_q <= '0';

  elsif (p_in_m_axis_cq_tvalid and i_m_axis_cq_tready and p_in_m_axis_cq_tlast) then
    i_in_pkt_q <= '0';

  elsif (sop and i_m_axis_cq_tready) then
    i_in_pkt_q <= '1';
  end if;
end if;
end process;

i_sop <= not i_in_pkt_q and p_in_m_axis_cq_tvalid;



--Rx State Machine
fsm : process(p_in_user_clk)
begin
if rising_edge(p_in_user_clk) then
  if p_in_reset_n = '0' then

    i_fsm_cs <= S_RX_IDLE;

    i_trn_rdst_rdy_n <= '0';

    i_req_compl <= '0';
    i_req_exprom <= '0';
    i_req_pkt_type <= (others => '0');
    i_req_tc   <= (others => '0');
    i_req_td   <= '0';
    i_req_ep   <= '0';
    i_req_attr <= (others => '0');
    i_req_len  <= (others => '0');
    i_req_rid  <= (others => '0');
    i_req_tag  <= (others => '0');
    i_req_be   <= (others => '0');
    i_req_addr <= (others => '0');

    i_cpld_tlp_len <= (others => '0');
    i_cpld_tlp_cnt <= (others => '0');
    i_cpld_tlp_dlast <= '0';
    i_cpld_tlp_work <= '0';

    i_trn_dw_sel <= (others => '0');
    i_trn_dw_skip <= '0';

    i_usr_di <= (others => '0');
    i_usr_wr <= '0';
    i_usr_rd <= '0';

  else

    case i_fsm_cs is
        --#######################################################################
        --Анализ типа принятого пакета
        --#######################################################################
        when S_RX_IDLE =>
            i_m_axis_cq_tready <= '1';
            i_m_axis_rc_tready <= '1';

            if i_sop = '1' then
              i_desc_hdr_qw0     <= p_in_m_axis_cq_tdata(63 downto 0);
              i_req_byte_enables <= p_in_m_axis_cq_tuser(7 downto 0);

              i_fsm_cs <= S_RX_MRD_QW1;
            end if;

        --#######################################################################
        --Анализ типа принятого пакета
        --#######################################################################
        when S_RX_PKT_CHK =>

            if p_in_m_axis_cq_tvalid = '1' then
                case p_in_m_axis_cq_tdata(14 downto 11) is --field FMT (Format pkt) + field TYPE (Type pkt)
                    -------------------------------------------------------------------------
                    --IORd - 3DW, no data (PC<-FPGA)
                    -------------------------------------------------------------------------
                    when C_PCIE3_PKT_TYPE_IO_RD_ND =>

                      if UNSIGNED(trn_rd(41 downto 32)) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                        i_req_pkt_type <= trn_rd(62 downto 56);
                        i_req_tc       <= trn_rd(54 downto 52);
                        i_req_td       <= trn_rd(47);
                        i_req_ep       <= trn_rd(46);
                        i_req_attr     <= trn_rd(45 downto 44);
                        i_req_len      <= trn_rd(41 downto 32); --Length data payload (DW)
                        i_req_rid      <= trn_rd(31 downto 16);
                        i_req_tag      <= trn_rd(15 downto  8);
                        i_req_be       <= trn_rd( 7 downto  0);

                        i_fsm_cs <= S_RX_MRD_QW1;
                      end if;

                    -------------------------------------------------------------------------
                    --IOWr - 3DW, +data (PC->FPGA)
                    -------------------------------------------------------------------------
                    when C_PCIE_PKT_TYPE_IOWR_3DW_WD =>

                      if UNSIGNED(trn_rd(41 downto 32)) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                        i_req_pkt_type <= trn_rd(62 downto 56);
                        i_req_tc       <= trn_rd(54 downto 52);
                        i_req_td       <= trn_rd(47);
                        i_req_ep       <= trn_rd(46);
                        i_req_attr     <= trn_rd(45 downto 44);
                        i_req_len      <= trn_rd(41 downto 32); --Length data payload (DW)
                        i_req_rid      <= trn_rd(31 downto 16);
                        i_req_tag      <= trn_rd(15 downto  8);
                        i_req_be       <= trn_rd( 7 downto  0);

                        i_fsm_cs <= S_RX_IOWR_QW1;
                      end if;

                    -------------------------------------------------------------------------
                    --MWr - 3DW, +data (PC->FPGA)
                    -------------------------------------------------------------------------
                   when C_PCIE_PKT_TYPE_MWR_3DW_WD =>

                     if UNSIGNED(trn_rd(41 downto 32)) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                        i_fsm_cs <= S_RX_MWR_QW1;
                     end if;

                   --  -------------------------------------------------------------------------
                   --  --MWr - 4DW, +data (PC->FPGA)
                   --  -------------------------------------------------------------------------
                   -- when C_PCIE_PKT_TYPE_MWR_4DW_WD =>

                   --   if trn_rd(41 downto 32) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                   --      i_fsm_cs <= S_RX_MWR_QW41;
                   --   end if;

                    -------------------------------------------------------------------------
                    --MRd - 3DW, no data (PC<-FPGA)
                    -------------------------------------------------------------------------
                    when C_PCIE_PKT_TYPE_MRD_3DW_ND =>

                      if UNSIGNED(trn_rd(41 downto 32)) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                        i_req_pkt_type <= trn_rd(62 downto 56);
                        i_req_tc       <= trn_rd(54 downto 52);
                        i_req_td       <= trn_rd(47);
                        i_req_ep       <= trn_rd(46);
                        i_req_attr     <= trn_rd(45 downto 44);
                        i_req_len      <= trn_rd(41 downto 32);
                        i_req_rid      <= trn_rd(31 downto 16);
                        i_req_tag      <= trn_rd(15 downto  8);
                        i_req_be       <= trn_rd( 7 downto  0);

                        if i_bar_exprom = '1' then
                          i_req_exprom <= '1';
                        end if;

                        i_fsm_cs <= S_RX_MRD_QW1;
                      end if;

                    -- -------------------------------------------------------------------------
                    -- --MRd - 4DW, no data (PC<-FPGA)
                    -- -------------------------------------------------------------------------
                    -- when C_PCIE_PKT_TYPE_MRD_4DW_ND =>

                    --   if UNSIGNED(trn_rd(41 downto 32)) = TO_UNSIGNED(16#01#, 10) then --Length data payload (DW)
                    --     i_req_pkt_type <= trn_rd(62 downto 56);
                    --     i_req_tc       <= trn_rd(54 downto 52);
                    --     i_req_td       <= trn_rd(47);
                    --     i_req_ep       <= trn_rd(46);
                    --     i_req_attr     <= trn_rd(45 downto 44);
                    --     i_req_len      <= trn_rd(41 downto 32);
                    --     i_req_rid      <= trn_rd(31 downto 16);
                    --     i_req_tag      <= trn_rd(15 downto  8);
                    --     i_req_be       <= trn_rd( 7 downto  0);

                    --     if i_bar_exprom = '1' then
                    --       i_req_exprom <= '1';
                    --     end if;

                    --     i_fsm_cs <= S_RX_MRD_QW41;
                    --   end if;

                    -------------------------------------------------------------------------
                    --Cpl - 3DW, no data
                    -------------------------------------------------------------------------
                    when C_PCIE_PKT_TYPE_CPL_3DW_ND =>

                      --if trn_rd(15 downto 13) /= C_PCIE_COMPL_STATUS_SC then
                        i_fsm_cs <= S_RX_CPL_QW1;
                      --end if;

                    -------------------------------------------------------------------------
                    --CplD - 3DW, +data
                    -------------------------------------------------------------------------
                    when C_PCIE_PKT_TYPE_CPLD_3DW_WD =>

                        i_cpld_tlp_len <= trn_rd(41 downto 32); --Length data payload (DW)
                        i_cpld_tlp_cnt <= (others => '0');
                        i_cpld_tlp_work <= '1';
                        i_trn_dw_sel <= (others => '1');
                        i_trn_dw_skip <= '1';
                        i_fsm_cs <= S_RX_CPLD_QWN;

                     when others =>
                        i_fsm_cs <= S_RX_IDLE;

                end case; --case (trn_rd(62 downto 56))
            end if; --if trn_rsof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
        --end S_RX_IDLE :


        --#######################################################################
        --IOWr - 3DW, +data (PC->FPGA)
        --#######################################################################
        when S_RX_IOWR_QW1 =>

            if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
              i_req_addr <= trn_rd(63 downto 34);
              i_usr_di <= trn_rd(31 downto 0);

              if i_bar_usr = '1' then
                i_usr_wr <= '1';
              end if;

              i_req_compl <= '1'; ----Request send pkt Cpl
              i_trn_rdst_rdy_n <= '1';
              i_fsm_cs <= S_RX_IOWR_WT;
            else
              if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
                i_fsm_cs <= S_RX_IDLE;
              end if;
            end if;

        when S_RX_IOWR_WT =>

            i_usr_wr <= '0';
            if compl_done_i = '1' then --Send pkt Cpl is done
              i_req_compl <= '0';
              i_trn_rdst_rdy_n <= '0';
              i_fsm_cs <= S_RX_IDLE;
            end if;
        --END: IOWr - 3DW, +data


        --#######################################################################
        --MRd - 3DW, no data (PC<-FPGA)
        --#######################################################################
        when S_RX_MRD_QW1 =>

            if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
              i_req_addr <= trn_rd(63 downto 34);
              i_trn_rdst_rdy_n <= '1';

              if i_req_exprom = '0' then
                if i_bar_usr = '1' then
                  i_usr_rd <= '1';
                end if;
              end if;

              i_fsm_cs <= S_RX_MRD_WT1;
            else
              if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
                i_req_exprom <= '0';
                i_fsm_cs <= S_RX_IDLE;
              end if;
            end if;

        when S_RX_MRD_WT1 =>

            i_usr_rd <= '0';
            i_req_compl <= '1'; --Request send pkt CplD
            i_fsm_cs <= S_RX_MRD_WT;

        when S_RX_MRD_WT =>

            if compl_done_i = '1' then --Send pkt  CplD is done
              i_req_exprom <= '0';
              i_req_compl <= '0';
              i_trn_rdst_rdy_n <= '0';
              i_fsm_cs <= S_RX_IDLE;
            end if;
        --END: MRd - 3DW, no data


        -- --#######################################################################
        -- --MRd - 4DW, no data (PC<-FPGA)
        -- --#######################################################################
        -- when S_RX_MRD_QW41 =>

        --     if trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
        --       i_req_addr <= trn_rd(31 downto 2);
        --       i_trn_rdst_rdy_n <= '1';

        --       if i_req_exprom = '0' then
        --         if i_bar_usr = '1' then
        --           i_usr_rd <= '1';
        --         end if;
        --       end if;

        --       i_fsm_cs <= S_RX_MRD_WT1;
        --     else
        --       if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
        --         i_req_exprom <= '0';
        --         i_fsm_cs <= S_RX_IDLE;
        --       end if;
        --     end if;

        -- when S_RX_MRD_QW42 =>

        --     i_usr_rd <= '0';

        --     if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
        --     i_req_compl <= '1';--Request send pkt CplD
        --     i_fsm_cs <= S_RX_MRD_WT;
        --     end if;
        -- --END: MRd - 4DW, no data


        --#######################################################################
        --MWr - 3DW, +data (PC->FPGA)
        --#######################################################################
        when S_RX_MWR_QW1 =>

            if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
              i_req_addr <= trn_rd(63 downto 34);
              i_usr_di <= trn_rd(31 downto 0);

              if i_bar_usr = '1' then
                i_usr_wr <= '1';
              end if;

              i_trn_rdst_rdy_n <= '1';
              i_fsm_cs <= S_RX_MWR_WT;
            else
              if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
                i_fsm_cs <= S_RX_IDLE;
              end if;
            end if;

        when S_RX_MWR_WT =>
            i_usr_wr <= '0';
            i_trn_rdst_rdy_n <= '0';
            i_fsm_cs <= S_RX_IDLE;
        --END: MWr - 3DW, +data


        -- --#######################################################################
        -- --MWr - 4DW, +data (PC->FPGA)
        -- --#######################################################################
        -- when S_RX_MWR_QW41 =>

        --     if trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
        --       i_usr_di <= trn_rd(63 downto 32);

        --       i_trn_rdst_rdy_n <= '1';
        --       i_fsm_cs <= S_RX_MWR_WT;
        --     else
        --       if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
        --         i_fsm_cs <= S_RX_IDLE;
        --       end if;
        --     end if;

        -- when S_RX_MWR_QW42 =>

        --     if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
        --       i_req_addr <= trn_rd(31 downto 2);

        --       if i_bar_usr = '1' then
        --         i_usr_wr <= '1';
        --       end if;

        --       i_trn_rdst_rdy_n <= '1';
        --       i_fsm_cs <= S_RX_MWR_WT;
        --     else
        --       if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
        --         i_fsm_cs <= S_RX_IDLE;
        --       end if;
        --     end if;
        -- --END: MWr - 4DW, +data (PC->FPGA)


        --#######################################################################
        --Cpl - 3DW, no data
        --#######################################################################
        when S_RX_CPL_QW1 =>

            if trn_reof_n = '0' and trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' then
              i_fsm_cs <= S_RX_IDLE;
            else
              if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
                i_fsm_cs <= S_RX_IDLE;
              end if;
            end if;
        --END: Cpl - 3DW, no data


        --#######################################################################
        --CplD - 3DW, +data
        --#######################################################################
        when S_RX_CPLD_QWN =>

            if trn_rsrc_rdy_n = '0' and trn_rsrc_dsc_n = '1' and usr_txbuf_full_i = '0' then

                if    i_trn_dw_sel = TO_UNSIGNED(16#00#, i_trn_dw_sel'length) then
                  i_usr_di <= trn_rd(31 downto 0);
                elsif i_trn_dw_sel = TO_UNSIGNED(16#01#, i_trn_dw_sel'length) then
                  i_usr_di <= trn_rd(63 downto 32);
                end if;

                if trn_reof_n = '0' then
                    i_trn_dw_sel <= i_trn_dw_sel - 1;
                    i_trn_dw_skip <= '0';

                    if i_trn_dw_skip = '0' then
                      i_usr_wr <= '1';
                      i_cpld_tlp_cnt <= i_cpld_tlp_cnt + 1;
                    else
                      i_usr_wr <= '0';
                    end if;

                    if   ((UNSIGNED(trn_rrem_n) = TO_UNSIGNED(16#00#, trn_rrem_n'length)) and
                                  (i_trn_dw_sel = TO_UNSIGNED(16#00#, i_trn_dw_sel'length)))
                      or
                         ((UNSIGNED(trn_rrem_n) = TO_UNSIGNED(16#01#, trn_rrem_n'length)) and
                                  (i_trn_dw_sel = TO_UNSIGNED(16#01#, i_trn_dw_sel'length))) then

                      i_cpld_tlp_dlast <= '1';
                      i_trn_rdst_rdy_n <= '1';
                      i_fsm_cs <= S_RX_CPLD_WT;

                    end if;

                else --if trn_reof_n = '1' then

                    if trn_rsof_n = '1' then
                        i_trn_dw_sel <= i_trn_dw_sel - 1;
                        i_trn_dw_skip <= '0';

                        if i_trn_dw_skip = '0' then
                          i_usr_wr <= '1';
                          i_cpld_tlp_cnt <= i_cpld_tlp_cnt + 1;
                        else
                          i_usr_wr <= '0';
                        end if;

                        i_fsm_cs <= S_RX_CPLD_QWN;
                    else
                        i_usr_wr <= '0';
                        i_fsm_cs <= S_RX_CPLD_QWN;
                    end if;

                end if;
            else
              if trn_rsrc_dsc_n = '0' then --Core PCIE break recieve data
                  i_cpld_tlp_dlast <= '1';
                  i_usr_wr <= '0';
                  i_fsm_cs <= S_RX_CPLD_WT;
              else
                  i_usr_wr <= '0';
                  i_fsm_cs <= S_RX_CPLD_QWN;
              end if;
            end if;
        --end S_RX_CPLD_QWN :

        when S_RX_CPLD_WT =>

            i_cpld_tlp_cnt <= (others => '0');
            i_cpld_tlp_dlast <= '0';
            i_cpld_tlp_work <= '0';
            i_trn_rdst_rdy_n <= '0';
            i_trn_dw_sel <= (others => '0');
            i_usr_wr <= '0';
            i_fsm_cs <= S_RX_IDLE;
        --END: CplD - 3DW, +data

    end case; --case i_fsm_cs is
  end if;
end if;--rst_n,
end process; --fsm

end architecture behavioral;


