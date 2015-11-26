-------------------------------------------------------------------------
-- Engineer    : Golovachenko Victor
--
-- Create Date : 12.02.2015 10:21:10
-- Module Name : prj_def
--
-- Description : project constants define
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.vicg_common_pkg.all;
use work.prj_cfg.all;

package prj_def is

----------------------------------------------------------------
--
----------------------------------------------------------------
type TWriterPrm is record
pixcount   : std_logic_vector(15 downto 0);
linecount  : std_logic_vector(15 downto 0);
mem_trnlen : std_logic_vector(15 downto 0);--(15 downto 8)/(7 downto 0) - MEMRD_LEN/MEMWR_LEN
end record;


constant C_FPGA_FIRMWARE_VERSION : integer := C_PCFG_FIRMWARE_VERSION;

--HOST
constant C_HDEV_DWIDTH           : integer := C_PCGF_PCIE_DWIDTH;

----------------------------------------------------------------
--module pcie_main.vhd: (max count HREG - 0x1F)
----------------------------------------------------------------
--Register Map:
constant C_HREG_FIRMWARE                      : integer := 16#00#;--FPGA firmware
constant C_HREG_CTRL                          : integer := 16#01#;--Global control
constant C_HREG_DMAPRM_ADR                    : integer := 16#02#;--Driver BUF(adress) (BYTE)
constant C_HREG_DMAPRM_LEN                    : integer := 16#03#;--Driver BUF(size) (BYTE)
constant C_HREG_DEV_CTRL                      : integer := 16#04#;--device control (fpga module connected to host(pcie))
constant C_HREG_DEV_STATUS                    : integer := 16#05#;--device status (fpga module connected to host(pcie))
constant C_HREG_IRQ                           : integer := 16#07#;--Interrupt
constant C_HREG_MEM_ADR                       : integer := 16#08#;--RAM Adress (module - pcie2mem))
constant C_HREG_MEM_CTRL                      : integer := 16#09#;--Controll (module - pcie2mem))
constant C_HREG_FG_FRMRK                      : integer := 16#0A#;--frame marker
constant C_HREG_PCIE                          : integer := 16#0D#;--PCIE info
constant C_HREG_FUNC                          : integer := 16#0E#;--FPGA module using
constant C_HREG_FUNCPRM                       : integer := 16#0F#;--FPGA module info
constant C_HREG_ETH_HEADER                    : integer := 16#10#;
constant C_HREG_TST0                          : integer := 16#1C#;--DBG registers
constant C_HREG_TST1                          : integer := 16#1D#;--(Wr) PWM control
constant C_HREG_TST2                          : integer := 16#1E#;--(Rd) Temperature


--Register C_HREG_FIRMWARE / Bit Map:
constant C_HREG_FRMWARE_LAST_BIT              : integer := 15;


--Register C_HREG_CTRL / Bit Map:
constant C_HREG_CTRL_RST_ALL_BIT              : integer := 0;
constant C_HREG_CTRL_RST_MEM_BIT              : integer := 1;
constant C_HREG_CTRL_RST_ETH_BIT              : integer := 2;
constant C_HREG_CTRL_FG_RDDONE_BIT            : integer := 3;
constant C_HREG_CTRL_LAST_BIT                 : integer := C_HREG_CTRL_FG_RDDONE_BIT;


--Register C_HREG_DEV_CTRL / Bit Map:
constant C_HREG_DEV_CTRL_DRDY_BIT             : integer := 0;
constant C_HREG_DEV_CTRL_DMA_START_BIT        : integer := 1; --(Rising_edge)
constant C_HREG_DEV_CTRL_DMA_DIR_BIT          : integer := 2; --1/0 – (PC<-FPGA)/(PC->FPGA)
constant C_HREG_DEV_CTRL_DMABUF_L_BIT         : integer := 3; --Number of start buffer (for DMATRN)
constant C_HREG_DEV_CTRL_DMABUF_M_BIT         : integer := 10;
constant C_HREG_DEV_CTRL_DMABUF_COUNT_L_BIT   : integer := 11;--Count buffer (for DMATRN)
constant C_HREG_DEV_CTRL_DMABUF_COUNT_M_BIT   : integer := 18;
constant C_HREG_DEV_CTRL_ADR_L_BIT            : integer := 19;--device adress (fpga module connected to host(pcie)) - C_HDEV_xxx
constant C_HREG_DEV_CTRL_ADR_M_BIT            : integer := 22;
constant C_HREG_DEV_CTRL_FG_CH_L_BIT          : integer := 23;--number of Frame Grabber channel
constant C_HREG_DEV_CTRL_FG_CH_M_BIT          : integer := 25;
constant C_HREG_DEV_CTRL_LAST_BIT             : integer := C_HREG_DEV_CTRL_FG_CH_M_BIT;--Max 31

--field C_HREG_DEV_CTRL_ADR - user device adress:
constant C_HDEV_CFG                           : integer := 0;--CFG
constant C_HDEV_MEM                           : integer := 1;--RAM
constant C_HDEV_FG                            : integer := 2;--Frame Grabber
constant C_HDEV_ETH                           : integer := 3;
constant C_HDEV_COUNT                         : integer := C_HDEV_ETH + 1;
constant C_HDEV_COUNT_MAX                     : integer := pwr(2, (C_HREG_DEV_CTRL_ADR_M_BIT - C_HREG_DEV_CTRL_ADR_L_BIT + 1));


--Register C_HOST_REG_STATUS_DEV / Bit Map:
constant C_HREG_DEV_STATUS_DMA_BUSY_BIT       : integer := 0; --PCIE_DMA
constant C_HREG_DEV_STATUS_MEMCTRL_RDY_BIT    : integer := 1;
constant C_HREG_DEV_STATUS_CFG_RXRDY_BIT      : integer := 2;
constant C_HREG_DEV_STATUS_CFG_TXRDY_BIT      : integer := 3;
constant C_HREG_DEV_STATUS_ETH_RDY_BIT        : integer := 4;
constant C_HREG_DEV_STATUS_ETH_LINK_BIT       : integer := 5;
constant C_HREG_DEV_STATUS_ETH_RXRDY_BIT      : integer := 6;
constant C_HREG_DEV_STATUS_ETH_TXRDY_BIT      : integer := 7;
constant C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT    : integer := 8;
constant C_HREG_DEV_STATUS_FG_VCH1_RDY_BIT    : integer := 9;
constant C_HREG_DEV_STATUS_FG_VCH2_RDY_BIT    : integer := 10;
constant C_HREG_DEV_STATUS_FG_VCH3_RDY_BIT    : integer := 11;

constant C_HREG_DEV_STATUS_FST_BIT            : integer := 1;
constant C_HREG_DEV_STATUS_LAST_BIT           : integer := C_HREG_DEV_STATUS_FG_VCH0_RDY_BIT;


--Register C_HREG_IRQ / Bit Map:
constant C_HREG_IRQ_NUM_L_WBIT                : integer := 0; --IRQ source
constant C_HREG_IRQ_NUM_M_WBIT                : integer := 3;
constant C_HREG_IRQ_EN_WBIT                   : integer := 13;
constant C_HREG_IRQ_DIS_WBIT                  : integer := 14;
constant C_HREG_IRQ_STATUS_CLR_WBIT           : integer := 15;
constant C_HREG_IRQ_CLR_WBIT                  : integer := 16;
constant C_HREG_IRQ_LAST_WBIT                 : integer := C_HREG_IRQ_CLR_WBIT;

constant C_HREG_IRQ_STATUS_L_RBIT             : integer := 0; --Status active irq
constant C_HREG_IRQ_STATUS_M_RBIT             : integer := 31;

--field C_HREG_IRQ_NUM - interrupt numbers:
constant C_HIRQ_PCIE_DMA                      : integer := 0;--DONE
constant C_HIRQ_CFG                           : integer := 1;--RxD_RDY
constant C_HIRQ_ETH                           : integer := 2;--RxD_RDY
constant C_HIRQ_FG_VCH0                       : integer := 3;
constant C_HIRQ_FG_VCH1                       : integer := 4;
constant C_HIRQ_FG_VCH2                       : integer := 5;
constant C_HIRQ_FG_VCH3                       : integer := 6;
constant C_HIRQ_COUNT                         : integer := C_HIRQ_FG_VCH0 + 1;
constant C_HIRQ_FST_BIT                       : integer := selval(0, 1, (C_HIRQ_COUNT = 1));
--constant C_HIRQ_COUNT_MAX                     : integer := pwr(2, (C_HREG_IRQ_NUM_M_WBIT - C_HREG_IRQ_NUM_L_WBIT + 1));


--Register C_HREG_MEM_ADR / Bit Map:
constant C_HREG_MEM_ADR_BANK_L_BIT            : integer := 31;--MEM_ADR_OFFSET[30..0]
constant C_HREG_MEM_ADR_BANK_M_BIT            : integer := 31;
constant C_HREG_MEM_ADR_LAST_BIT              : integer := C_HREG_MEM_ADR_BANK_M_BIT;

--Register C_HREG_MEM_CTRL / Bit Map:
constant C_HREG_MEM_CTRL_TRNWR_L_BIT          : integer := 0;
constant C_HREG_MEM_CTRL_TRNWR_M_BIT          : integer := 7;
constant C_HREG_MEM_CTRL_TRNRD_L_BIT          : integer := 8;
constant C_HREG_MEM_CTRL_TRNRD_M_BIT          : integer := 15;
constant C_HREG_MEM_CTRL_LAST_BIT             : integer := C_HREG_MEM_CTRL_TRNRD_M_BIT;


--Register C_HREG_PCIE / Bit Map:
--constant RESERV                             : integer := 5..0;
constant C_HREG_PCIE_NEG_LINK_L_RBIT          : integer := 6;
constant C_HREG_PCIE_NEG_LINK_M_RBIT          : integer := 11;
--constant RESERV                             : integer := 14...12;
constant C_HREG_PCIE_NEG_MAX_PAYLOAD_L_BIT    : integer := 15;
constant C_HREG_PCIE_NEG_MAX_PAYLOAD_M_BIT    : integer := 17;
constant C_HREG_PCIE_NEG_MAX_RD_REQ_L_BIT     : integer := 18;
constant C_HREG_PCIE_NEG_MAX_RD_REQ_M_BIT     : integer := 20;
--constant RESERV                             : integer := 23...21;
constant C_HREG_PCIE_MASTER_EN_BIT            : integer := 24;
--constant RESERV                             : integer := 27...25;
constant C_HREG_PCIE_SPEED_TESTING_BIT        : integer := 28;
constant C_HREG_PCIE_EN_TESTD_GEN_BIT         : integer := 29;
constant C_HREG_PCIE_LAST_BIT                 : integer := C_HREG_PCIE_EN_TESTD_GEN_BIT;


--Register C_HREG_FUNC / Bit Map:
--1/0 - use/(not use) into project FPGA
constant C_HREG_FUNC_MEM_BIT                  : integer := 0;
constant C_HREG_FUNC_TMR_BIT                  : integer := 1;
constant C_HREG_FUNC_FG_BIT                   : integer := 2;
constant C_HREG_FUNC_ETH_BIT                  : integer := 3;
constant C_HREG_FUNC_LAST_BIT                 : integer := C_HREG_FUNC_ETH_BIT;


--Register C_HREG_FUNCPRM / Bit Map:
constant C_HREG_FUNCPRM_MEMBANK_SIZE_L_BIT    : integer := 0;
constant C_HREG_FUNCPRM_MEMBANK_SIZE_M_BIT    : integer := 2;
constant C_HREG_FUNCPRM_FG_VCH_COUNT_L_BIT    : integer := 3;
constant C_HREG_FUNCPRM_FG_VCH_COUNT_M_BIT    : integer := 5;
constant C_HREG_FUNCPRM_FG_REV_BIT            : integer := 7;
constant C_HREG_FUNCPRM_FG_128_BIT            : integer := 9;
constant C_HREG_FUNCPRM_LAST_BIT              : integer := C_HREG_FUNCPRM_FG_128_BIT;


--Port of module pcie_main.vhd /p_in_dev_option/ Bit Map:
constant C_HDEV_OPTIN_TXFIFO_FULL_BIT         : integer := 0;
constant C_HDEV_OPTIN_RXFIFO_EMPTY_BIT        : integer := 1;
constant C_HDEV_OPTIN_MEM_DONE_BIT            : integer := 2;
constant C_HDEV_OPTIN_FG_FRMRK_L_BIT          : integer := 3;
constant C_HDEV_OPTIN_FG_FRMRK_M_BIT          : integer := 34;
constant C_HDEV_OPTIN_ETH_HEADER_L_BIT        : integer := 35;
constant C_HDEV_OPTIN_ETH_HEADER_M_BIT        : integer := 66;

constant C_HDEV_OPTIN_FST_BIT                 : integer := 0;
constant C_HDEV_OPTIN_LAST_BIT                : integer := C_HDEV_OPTIN_ETH_HEADER_M_BIT;


--Port of module pcie_main.vhd /p_out_dev_option/ Bit Map:
constant C_HDEV_OPTOUT_MEM_ADR_L_BIT          : integer := 0;
constant C_HDEV_OPTOUT_MEM_ADR_M_BIT          : integer := 31;
constant C_HDEV_OPTOUT_MEM_RQLEN_L_BIT        : integer := 32;
constant C_HDEV_OPTOUT_MEM_RQLEN_M_BIT        : integer := 49;--mem_rqlen: BYTE(max 128KB)
constant C_HDEV_OPTOUT_MEM_TRNWR_LEN_L_BIT    : integer := 50;
constant C_HDEV_OPTOUT_MEM_TRNWR_LEN_M_BIT    : integer := 57;--mem_trnwr:
constant C_HDEV_OPTOUT_MEM_TRNRD_LEN_L_BIT    : integer := 58;
constant C_HDEV_OPTOUT_MEM_TRNRD_LEN_M_BIT    : integer := 65;--mem_trnrd:

constant C_HDEV_OPTOUT_FST_BIT                : integer := 0;
constant C_HDEV_OPTOUT_LAST_BIT               : integer := C_HDEV_OPTOUT_MEM_TRNRD_LEN_M_BIT;



----------------------------------------------------------------
--module cfgdev.vhd
----------------------------------------------------------------
--CFG Device Address map:
constant C_CFGDEV_FG                          : integer := 0;
constant C_CFGDEV_SWT                         : integer := 1;
constant C_CFGDEV_TMR                         : integer := 2;
constant C_CFGDEV_ETH                         : integer := 3;
constant C_CFGDEV_COUNT                       : integer := C_CFGDEV_ETH + 1;
constant C_CFGDEV_COUNT_MAX                   : integer := 8;



----------------------------------------------------------------
--module timers.vhd
----------------------------------------------------------------
constant C_TMR_REG_CTRL                       : integer := 16#000#;
constant C_TMR_REG_CMP_L                      : integer := 16#001#;
constant C_TMR_REG_CMP_M                      : integer := 16#002#;


--Register C_TMR_REG_CTRL / Bit Map:
constant C_TMR_REG_CTRL_NUM_L_BIT             : integer := 0;--Number TMR
constant C_TMR_REG_CTRL_NUM_M_BIT             : integer := 1;
constant C_TMR_REG_CTRL_EN_BIT                : integer := 14;
constant C_TMR_REG_CTRL_DIS_BIT               : integer := 15;
--constant C_TMR_REG_CTRL_STATUS_EN_L_RBIT      : integer := 0;--
--constant C_TMR_REG_CTRL_STATUS_EN_M_RBIT      : integer := xxx;
constant C_TMR_REG_CTRL_LAST_BIT              : integer := C_TMR_REG_CTRL_DIS_BIT;


--
constant C_TMR_ETH                            : integer := 0;

constant C_TMR_COUNT                          : integer := C_TMR_ETH + 1;--max=3


----------------------------------------------------------------
--module switch_data.vhd
----------------------------------------------------------------
constant C_SWT_REG_DBG                        : integer := 16#06#;
constant C_SWT_REG_CTRL                       : integer := 16#07#;
constant C_SWT_REG_FRR_ETH2HOST               : integer := 16#08#;
constant C_SWT_REG_FRR_ETH2FG                 : integer := 16#10#;

--Register C_SWT_REG_DBG / Bit Map:
constant C_SWT_REG_DBG_HOST2FG_BIT            : integer := 0; --HOST(over ETH BUF) -> FG
constant C_SWT_REG_DBG_ETHLOOP_BIT            : integer := 1;
constant C_SWT_REG_DBG_LAST_BIT               : integer := C_SWT_REG_DBG_ETHLOOP_BIT;

--Register C_SWT_REG_CTRL / Bit Map:
constant C_SWT_REG_CTRL_RST_ETH_BUFS_BIT      : integer := 0;
constant C_SWT_REG_CTRL_RST_FG_BUFS_BIT       : integer := 1;
constant C_SWT_REG_CTRL_LAST_BIT              : integer := C_SWT_REG_CTRL_RST_FG_BUFS_BIT;


--Max count of rule FRR (frame routing):
constant C_SWT_FRR_COUNT_MAX                  : integer := 8;

--
constant C_SWT_ETH_HOST_FRR_COUNT             : integer := 3; --Кол-во правил машрутизации пакетов ETH-HOST
constant C_SWT_ETH_FG_FRR_COUNT               : integer := C_PCFG_FG_VCH_COUNT; --Кол-во правил машрутизации пакетов ETH-VCTRL

Type TEthFRRGet is array (0 to C_SWT_FRR_COUNT_MAX - 1) of integer;
----------------------------------------------------------------------------------------
--C_SWT_ETH_xxx_FRR_COUNT - value:                 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
----------------------------------------------------------------------------------------
constant C_SWT_GET_FRR_REG_COUNT   : TEthFRRGet := ( 1,  1,  2,  2,  3,  3,  4,  4 );
Type TEthFRR is array (0 to C_SWT_FRR_COUNT_MAX - 1) of std_logic_vector(7 downto 0);
--mask of filter (7...0),
-- 3..0 - packet type
-- 7..4 - packet subtype


----------------------------------------------------------------
--module  fg.vhd
----------------------------------------------------------------
constant C_FG_REG_CTRL                     : integer := 16#000#;
constant C_FG_REG_DATA_L                   : integer := 16#001#;
constant C_FG_REG_DATA_M                   : integer := 16#002#;
constant C_FG_REG_MEM_CTRL                 : integer := 16#003#;--(15..8)(7..0) - trn_mem_rd;trn_mem_wr
constant C_FG_REG_DBG                      : integer := 16#004#;


--Register C_FG_REG_CTRL / Bit Map:
constant C_FG_REG_CTRL_VCH_L_BIT           : integer := 0; --Index of video channel
constant C_FG_REG_CTRL_VCH_M_BIT           : integer := 3;
constant C_FG_REG_CTRL_PRM_L_BIT           : integer := 4; --Index of parameter video channel
constant C_FG_REG_CTRL_PRM_M_BIT           : integer := 6;
constant C_FG_REG_CTRL_WR_BIT              : integer := 7; --Write/Read parametrs
constant C_FG_REG_CTRL_SET_IDLE_BIT        : integer := 8;
constant C_FG_REG_CTRL_LAST_BIT            : integer := C_FG_REG_CTRL_SET_IDLE_BIT;

--
constant C_FG_REG_CTRL_WR : std_logic := '1';
constant C_FG_PKT_HD_SIZE_BYTE : integer := 16;

--Index of parametr video channel:
constant C_FG_PRM_MEM_ADR_WR               : integer := 0;
constant C_FG_PRM_MEM_ADR_RD               : integer := 1;
constant C_FG_PRM_FR_ZONE_SKIP             : integer := 2;
constant C_FG_PRM_FR_ZONE_ACTIVE           : integer := 3;
constant C_FG_PRM_FR_OPTIONS               : integer := 4;
constant C_FG_PRM_FR_STEP_RD               : integer := 5;

constant C_FG_PRM_COUNT_MAX                : integer := pwr(2, (C_FG_REG_CTRL_PRM_M_BIT - C_FG_REG_CTRL_PRM_L_BIT + 1));

--Count video channel:
constant C_FG_VBUF_COUNT                   : integer := C_PCFG_FG_VBUF_COUNT;
constant C_FG_VCH_COUNT                    : integer := C_PCFG_FG_VCH_COUNT;
constant C_FG_VCH_COUNT_MAX                : integer := 2;

--Video memory map:
constant C_FG_MEM_VLINE_M_BIT              : integer := log2(C_PCFG_FG_MEM_VBUF_SIZE) - 1;
constant C_FG_MEM_VFR_L_BIT                : integer := log2(C_PCFG_FG_MEM_VBUF_SIZE);--Index of frame buffer (MSB...LSB)
constant C_FG_MEM_VFR_M_BIT                : integer := log2(C_PCFG_FG_MEM_VBUF_SIZE)
+ selval(1, log2(C_FG_VBUF_COUNT), ((log2(C_FG_VBUF_COUNT) = 0) or (log2(C_FG_VBUF_COUNT) = 1))) - 1;

constant C_FG_MEM_VCH_L_BIT                : integer := log2(C_PCFG_FG_MEM_VBUF_SIZE)
+ selval(1, log2(C_FG_VBUF_COUNT), ((log2(C_FG_VBUF_COUNT) = 0) or (log2(C_FG_VBUF_COUNT) = 1)));

constant C_FG_MEM_VCH_M_BIT                : integer := log2(C_PCFG_FG_MEM_VBUF_SIZE)
+ selval(1, log2(C_FG_VBUF_COUNT), ((log2(C_FG_VBUF_COUNT) = 0) or (log2(C_FG_VBUF_COUNT) = 1)))
+ selval(1, log2(C_FG_VCH_COUNT), ((log2(C_FG_VCH_COUNT) = 0) or (log2(C_FG_VCH_COUNT) = 1))) - 1;

--Register C_FG_REG_DBG / Bit Map:
--constant C_FG_REG_DBG_L_BIT               : integer := 0;
--constant C_FG_REG_DBG_M_BIT               : integer := 3;
--constant C_FG_REG_DBG_LAST_BIT            : integer := C_FG_REG_DBG_M_BIT;

constant C_FG_REG_DBG_TBUFRD_BIT      : integer:=0;--Отладка модуля слежения - отображение содержимого RAM/TRACK/TBUF
constant C_FG_REG_DBG_EBUFRD_BIT      : integer:=1;--Отладка модуля слежения - отображение содержимого RAM/TRACK/EBUF
constant C_FG_REG_DBG_SOBEL_BIT       : integer:=2;--1/0 - Отладка модуля собела Выдача Grad/Video
constant C_FG_REG_DBG_ROTRIGHT_BIT    : integer:=3;--Поворот на 90 вправо
constant C_FG_REG_DBG_ROTLEFT_BIT     : integer:=4;--Поворот на 90 влево
constant C_FG_REG_DBG_DIS_DEMCOLOR_BIT: integer:=5;--1/0 - Запретить работу модуля vcoldemosaic_main.vhd
constant C_FG_REG_DBG_DCOUNT_BIT      : integer:=6;--1 - Вместо данных строки вставляется счетчик
constant C_FG_REG_DBG_PICTURE_BIT     : integer:=7;--Запрещаю запись видео в ОЗУ + запрещаю инкрементацию счетчика vbuf,
                                                           --при бит(7)=1 - vbuf=0
constant C_FG_REG_DBG_SKIPFR_CNT_CLR_BIT  : integer:=8;--При 1 - происходит сброс счетчиков пропущеных кадров tst_vfrskip,
                                                           --При 0 - нет
constant C_FG_REG_DBG_TIMESTUMP_BIT   : integer:=9;
constant C_FG_REG_DBG_RDHOLD_BIT      : integer:=10;--Эмуляция захвата видеобуфера модулем чтения
constant C_FG_REG_DBG_TRCHOLD_BIT     : integer:=11;--Эмуляция захвата видеобуфера модулем слежения
constant C_FG_REG_DBG_LAST_BIT            : integer:=C_FG_REG_DBG_TRCHOLD_BIT;


----------------------------------------------------------------
--module  eth_main.vhd
----------------------------------------------------------------
constant C_ETH_REG_CTRL                       : integer:=16#000#;
constant C_ETH_REG_MAC_PATRN0                 : integer:=16#001#;--DST MAC
constant C_ETH_REG_MAC_PATRN1                 : integer:=16#002#;
constant C_ETH_REG_MAC_PATRN2                 : integer:=16#003#;
constant C_ETH_REG_MAC_PATRN3                 : integer:=16#004#;--SRC MAC
constant C_ETH_REG_MAC_PATRN4                 : integer:=16#005#;
constant C_ETH_REG_MAC_PATRN5                 : integer:=16#006#;

end package prj_def;
