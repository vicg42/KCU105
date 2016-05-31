/*
 *	file:		hwi.h
 *	date:		22.05.2010
 *	authors:	Topolsky
 *	company:	Linkos
 *	format:		tab4
 *	descript.:	H/W interface definition
 */

#ifndef __LSD_HWI_H
#define __LSD_HWI_H

#define LSD_MEMIO_BAR_INDEX				0
#define LSD_MEMIO_BAR_SIZE				256
#define LSD_IO_BAR_INDEX				1
#define LSD_IO_BAR_SIZE					256

// Unified prefixes:
// - LSD: Linkos Smart Device
// - RO: Register Offset (in bytes)
// - RI: Register Index (usually <cfg> register or register accessible via <cfg>)
// - R<X>B: <X> Register Bit
// - R<X>MO: <X> Register Mask Offset
// - R<X>M: <X> Register Mask
// - R<X>V: <X> Register Value (usually masked)
// - R<X>C: <X> Register Constant (usually masked)
// - LH/HH - lo/hi half of value (used for values constists of two parts)
// - LO/HI - lo/hi part of value (used for values constists of more then two parts)

// Board registers offsets -----------------------------------------------------

#define LSD_RO_FIRMWARE					(0x80 + 0x00 * 4)
#define LSD_RO_CTRL						(0x80 + 0x01 * 4)
#define LSD_RO_DMA_ADDR					(0x80 + 0x02 * 4)
#define LSD_RO_DMA_SIZE					(0x80 + 0x03 * 4)
#define LSD_RO_DEV_CTRL					(0x80 + 0x04 * 4)
#define LSD_RO_DEV_STATUS				(0x80 + 0x05 * 4)
#define LSD_RO_DEV_DATA					(0x80 + 0x06 * 4)
#define LSD_RO_IRQ_CTRL					(0x80 + 0x07 * 4)
#define LSD_RO_MEM_ADDR					(0x80 + 0x08 * 4)
#define LSD_RO_MEM_CTRL					(0x80 + 0x09 * 4)
#define LSD_RO_FG_TIMESTAMP				(0x80 + 0x0a * 4)
#define LSD_RO_FG_NLOST_FRAMES			(0x80 + 0x0b * 4)
#define LSD_RO_PCIE_CTRL				(0x80 + 0x0d * 4)
#define LSD_RO_TIMESTAMP				(0x80 + 0x0c * 4)
#define LSD_RO_HW_FUNC					(0x80 + 0x0e * 4)
#define LSD_RO_HW_OPT					(0x80 + 0x0f * 4)
#define LSD_RO_FIBER_DATA_HEAD			(0x80 + 0x10 * 4)
#define LSD_RO_CFG_CTRL			(0x80 + 0x11 * 4)
#define LSD_RO_CFG_DATA			(0x80 + 0x12 * 4)
#ifdef LSD_ENABLE_HWDBG
#	define LSD_RO_x1C					(0x80 + 0x1c * 4)
#	define LSD_RO_x1D					(0x80 + 0x1d * 4)
#	define LSD_RO_x1E					(0x80 + 0x1e * 4)
#endif

// LSD_RC*: REGISTER/CTRL -------------------------------------------------------

#define LSD_RCB_RESET					(u32)(0x00000001 << 0)
#define LSD_RCB_MEM_RESET				(u32)(0x00000001 << 1)
#define LSD_RCB_FIBER_RESET				(u32)(0x00000001 << 2)
#define LSD_RCB_FG_COMPLETE				(u32)(0x00000001 << 3)

// LSD_RDC*: REGISTER/DEV/CTRL --------------------------------------------------

#define LSD_RDCB_DMA_REQUEST			(u32)(0x00000001 << 1)
#define LSD_RDCMO_DMA_DIRECTION			2
#define LSD_RDCM_DMA_DIRECTION			(u32)(0x00000001 << LSD_RDCMO_DMA_DIRECTION)
#define LSD_RDCMO_DMA_BUFFER			3
#define LSD_RDCM_DMA_BUFFER				(u32)(0x000003ff << LSD_RDCMO_DMA_BUFFER)
#define LSD_RDCMO_DMA_NBUFFERS			13
#define LSD_RDCM_DMA_NBUFFERS			(u32)(0x000003ff << LSD_RDCMO_DMA_NBUFFERS)
#define LSD_RDCMO_IO_TARGET				23
#define LSD_RDCM_IO_TARGET				(u32)(0x0000000f << LSD_RDCMO_IO_TARGET)
#define LSD_RDCMO_FG_INDEX				27
#define LSD_RDCM_FG_INDEX				(u32)(0x00000007 << LSD_RDCMO_FG_INDEX)

#define LSD_RDCV_DMA_DIRECTION_OUT		0U
#define LSD_RDCV_DMA_DIRECTION_IN		1U

#define LSD_RDCV_IO_TARGET_FIBER		2U
#define LSD_RDCV_IO_TARGET_MEM			0U
#define LSD_RDCV_IO_TARGET_FG			1U

// LSD_RDS*: REGISTER/DEV/STATUS ------------------------------------------------

#define LSD_RDSB_DMA_BUSY				(u32)(0x00000001 << 0)
#define LSD_RDSB_MEM_READY				(u32)(0x00000001 << 1)
#define LSD_RDSB_FIBER_READY			(u32)(0x00000001 << 2)
#define LSD_RDSB_FIBER_CARRIER			(u32)(0x00000001 << 3)
#define LSD_RDSB_FIBER_READABLE			(u32)(0x00000001 << 4)
#define LSD_RDSB_FIBER_WRITABLE			(u32)(0x00000001 << 5)
// first FG channel (up to channels number)
#define LSD_RDSB_FG_READABLE			(u32)(0x00000001 << 6)

// LSD_RIC*: REGISTER/IRQ_CTRL --------------------------------------------------

#define LSD_RICMO_SRC					0
#define LSD_RICM_SRC					(u32)(0x0000001f << LSD_RICMO_SRC)
#define LSD_RICB_ENABLE					(u32)(0x00000001 << 13)
#define LSD_RICB_RESET					(u32)(0x00000001 << 14)
#define LSD_RICB_IRQCLR					(u32)(0x00000001 << 15)
// will be continued after IRQ numbers definition

#define LSD_RICV_SRC_DMA				0U
#define LSD_RICV_SRC_FIBER				1U
// first FG channel (up to channels number)
#define LSD_RICV_SRC_FG					2U


#define LSD_RICB_DMA_EVENT				(u32)(0x00000001 << (LSD_RICV_SRC_DMA))
#define LSD_RICB_FIBER_EVENT			(u32)(0x00000001 << (LSD_RICV_SRC_FIBER))
// first FG channel (up to channels number)
#define LSD_RICB_FG_EVENT				(u32)(0x00000001 << (LSD_RICV_SRC_FG))

// LSD_RMA*: REGISTER/MEM_ADDR --------------------------------------------------

#define LSD_RMAMO_ADDR					0
#define LSD_RMAM_ADDR					(u32)(0x3fffffff << LSD_RMAMO_ADDR)

// LSD_RMC*: REGISTER/MEM_CTRL --------------------------------------------------

#define LSD_RMCO_WR_SIZE				0
#define LSD_RMC_WR_SIZE					(u32)(0x000000ff << LSD_RMCO_WR_SIZE)
#define LSD_RMCO_RD_SIZE				8
#define LSD_RMC_RD_SIZE					(u32)(0x000000ff << LSD_RMCO_RD_SIZE)

// LSD_RPC*: REGISTER/PCIE_CTRL -------------------------------------------------

#define LSD_RPCMO_LINK					0
#define LSD_RPCM_LINK					(u32)(0x0000003f << LSD_RPCMO_LINK)
#define LSD_RPCMO_MAX_PAYLOAD			6
#define LSD_RPCM_MAX_PAYLOAD			(u32)(0x00000007 << LSD_RPCMO_MAX_PAYLOAD)
#define LSD_RPCMO_MAX_RD_REQ			9
#define LSD_RPCM_MAX_RD_REQ				(u32)(0x00000007 << LSD_RPCMO_MAX_RD_REQ)
#define LSD_RPCB_SPEED_TESTING				(u32)(0x00000001 << 13)
#define LSD_RPCB_EN_TESTD_GEN				(u32)(0x00000001 << 14)

// LSD_RHF*: REGISTER/HW/FUNC ---------------------------------------------------

#define LSD_RHFB_MEM					(u32)(0x00000001 << 0)
#define LSD_RHFB_TIMER					(u32)(0x00000001 << 1)
#define LSD_RHFB_FG						(u32)(0x00000001 << 2)
#define LSD_RHFB_FIBER					(u32)(0x00000001 << 3)


// LSD_RHO*: REGISTER/HW/OPT -*--------------------------------------------------

#define LSD_RHOMO_MEM_SIZE				0
#define LSD_RHOM_MEM_SIZE				(u32)(0x00000007 << LSD_RHOMO_MEM_SIZE)
#define LSD_RHOMO_FG_NCHANNELS			3
#define LSD_RHOM_FG_NCHANNELS			(u32)(0x00000007 << LSD_RHOMO_FG_NCHANNELS)
//#define LSD_RHOB_FG_MIRROR			(u32)(0x00000001 << 6)
#define LSD_RHOB_FG2					(u32)(0x00000001 << 7)
#define LSD_RHOB_FIBER_DATA_HEAD		(u32)(0x00000001 << 8)
//#define LSD_RHOB_FG_4HALIGN				(u32)(0x00000001 << 9)
#define LSD_RHOMO_FG_HALIGN				9
#define LSD_RHOM_FG_HALIGN				(u32)(0x3 << LSD_RHOMO_FG_HALIGN)


// LSD_RHO*: REGISTER/CFG/CTRL -*--------------------------------------------------

#define LSD_RCCMO_TARGET			0
#define LSD_RCCM_TARGET			(u32)(0x0000000F << LSD_RCCMO_TARGET)
#define LSD_RCCMO_REGISTER			4
#define LSD_RCCM_REGISTER			(u32)(0x000000FF << LSD_RCCMO_REGISTER)


// CFG interface ---------------------------------------------------------------

#define LSD_CFG_MAX_NCHUNKS				4

#define LSD_CFG_RCV_TARGET_FG			0U
#define LSD_CFG_RCV_TARGET_TIMER		2U
#define LSD_CFG_RCV_TARGET_FIBER		3U
#define LSD_CFG_RCV_TARGET_FRR			1U

// FG interface (via CFG) ------------------------------------------------------

#define LSD_FG_RI_CTRL					0
#define LSD_FG_RI_PARAM					1
#define LSD_FG_RI_MEM_CTRL				2

// LSD_FG_RC*: FG/REGISTER/CTRL

#define LSD_FG_RCMO_INDEX				0
#define LSD_FG_RCM_INDEX				(u16)(0x000f << LSD_FG_RCMO_INDEX)
#define LSD_FG_RCMO_PARAM				4
#define LSD_FG_RCM_PARAM				(u16)(0x0007 << LSD_FG_RCMO_PARAM)
#define LSD_FG_RCMO_ACTION				7
#define LSD_FG_RCM_ACTION				(u16)(0x0001 << LSD_FG_RCMO_ACTION)
#define LSD_FG_RCB_RESET				(u16)(0x0001 << 8)

#define LSD_FG_RCV_PARAM_SHIFTS			0U
#define LSD_FG_RCV_PARAM_BOUNDS			1U
#define LSD_FG_RCV_PARAM_TRANSFORM		2U
#define LSD_FG_RCV_PARAM_NROWS			3U

#define LSD_FG_RCV_ACTION_SET			1U
#define LSD_FG_RCV_ACTION_GET			0U

#define LSD_FG_RCVO_H				0
#define LSD_FG_RCVM_H				(u32)(0x0000FFFF << LSD_FG_RCVO_H)

#define LSD_FG_RCVO_V				16
#define LSD_FG_RCVM_V				(u32)(0x0000FFFF << LSD_FG_RCVO_V)


// LSD_FG_RPT*: FG_PARAM/REGISTER/TRANSFORM

#define LSD_FG_RPTB_H_MIRROR			(0x0001 << 0)
#define LSD_FG_RPTB_V_MIRROR			(0x0001 << 1)

// LSD_FG_RM*: FG/REGISTER/MEM_CTRL

#define LSD_FG_RMMO_WR_SIZE				0
#define LSD_FG_RMM_WR_SIZE				(u16)(0x00ff << LSD_FG_RMMO_WR_SIZE)
#define LSD_FG_RMMO_RD_SIZE				8
#define LSD_FG_RMM_RD_SIZE				(u16)(0x00ff << LSD_FG_RMMO_RD_SIZE)

// FIBER interface (via CFG) ---------------------------------------------------

#define LSD_FIBER_RI_MAC_PATTERN0			0
#define LSD_FIBER_RI_MAC_PATTERN1			1
#define LSD_FIBER_RI_MAC_PATTERN2			2

// FRR interface (via CFG) -----------------------------------------------------

#define LSD_FRR_RI_CTRL					0x00
#define LSD_FRR_RI_HOST_FIRST			0x01
#define LSD_FRR_RI_HOST_LAST			0x02
#define LSD_FRR_RI_FG_FIRST				0x03
#define LSD_FRR_RI_FG_LAST				0x04
#ifdef LSD_ENABLE_DADBG
#	define LSD_FRR_RI_DA_FIRST			0x05
#	define LSD_FRR_RI_DA_LAST			0x06
#endif

// LSD_FRR_RC*: FRR/REGISTER/CTRL

#define LSD_FRR_RCB_HOST_RESET			(u16)(0x0001 << 0)
#define LSD_FRR_RCB_FG_RESET			(u16)(0x0001 << 1)

// constants

#define LSD_FRR_UNUSED					0

// TIMER interface (via CFG) ---------------------------------------------------

#define LSD_TIMER_RI_CTRL				0
#define LSD_TIMER_RI_CMP				1
#define LSD_TIMER_RI_LAST				LSD_TIMER_RI_CMP

// LSD_TIMER_RC*: TIMER/REGISTER/CTRL

#define LSD_TIMER_RCMO_INDEX			1
#define LSD_TIMER_RCM_INDEX				(u16)(0x000f << LSD_TIMER_RCMO_INDEX)
#define LSD_TIMER_RCB_ENABLE			(u16)(0x0001 << 0)

#define LSD_TIMER_RCV_INDEX_FIBER		0U
#define LSD_TIMER_RCV_INDEX_PORT0		1U
#define LSD_TIMER_RCV_INDEX_DESK		2U
#define LSD_TIMER_RCV_INDEX_PORT1		3U
#define LSD_TIMER_RCV_INDEX_PORT2		4U

#endif // __LSD_HWI_H
