Attribute VB_Name = "mdlJog"

'**************************************************************************
'*
'*
'* OpenCNC(R) Macro
'* Portions Copyright 1993-2001 by
'* Manufacturing Data Systems, Inc.(R)
'* All rights reserved.
'* http://www.mdsi2.com
'*
'* DOC $Id:$
'*
'* $Log:$
'*
'*
'* Description:
'*
'*
'**************************************************************************

'Ensure that all variables must be declared
Option Explicit

' sequencer micro commands
Public Const MC_JOG_INC = 2  'incremental jog

' PLC commands
Public Const DIOS_JOG = 3    'incremental jog
Public Const JOG_POSITIVE = 2
Public Const JOG_NEGATIVE = 3
Public Const DIOM_SYSTEM = 2
Public Const DIOM_USER = 3

' User Message Defines
Public Const DIOU_ENERGIZE = 1
Public Const DIOU_SYNC = 2
Public Const DIOU_CYCLESTART = 3
Public Const DIOU_FEEDHOLD = 4
Public Const DIOU_MODESET = 5
Public Const DIOU_JOGMULT = 7
Public Const DIOU_SETMAP0 = 8
Public Const DIOU_SETMAP1 = 9
Public Const DIOU_RAPIDPT = 10
Public Const DIOU_FEEDPT = 11
Public Const PROGNAME = "Form2"

' message commands
Private Type sAccIType
  VARINDEXREAD   As Long
  VARINDEXWRITE  As Long
End Type
Dim sAccI As sAccIType
Dim sAccNames As String

Private Type vAccIFixedType
  jsMsgPid(JSMAX - 1) As Long
End Type
Dim vAccIFixed As Long
Private Type vAccFixedType
  jsMsgPid(JSMAX - 1) As Long  'sequencer PIDs
End Type
Dim vAccFixed As vAccFixedType
Dim vAccFixedNames As String

' jog command message structure for Send to Sequencer
Public Type SeqJogMsgType
  nLongs As Long
  microCmd As Long
  axisBits As Long
  delta As Long
End Type

' jog command message structure for Send to PLC
Public Type PLCJogMsgType
  systemMsg As Long
  cmd As Long
  direction As Long
  axis As Long
End Type

' User message structure for Send to PLC
Public Type PLCUserMsgType
  systemMsg As Long
  cmd As Long
  arg1 As Long
  arg2 As Long
  arg3 As Long
End Type

Public accMsgPid As Long, dioMsgPid As Long
Public mdsiOpenCalled As Boolean

' Since the VB macro library does not support sending arbitrary
' messages, init the low-level API to do so.
Public Function initForJog() As Long

Dim ret As Long

  sAccNames = "VARINDEXREAD" + vbLf + _
              "VARINDEXWRITE" + vbLf + _
              ""
  vAccFixedNames = "jsMsgPid" + vbLf + _
                 ""

  ' connect to the low-level API
  ret = mdsiOpen(Form2.mdsiMacroObj.machineID, PROGNAME)
  If (ret = MDSIOPEN_FAILURE) Then initForJog = -1: Exit Function
  mdsiOpenCalled = True
  
  ' get the messager service's PID
  accMsgPid = mdsiFindProg("accMsg", Form2.mdsiMacroObj.machineID, vbNullString)
  If accMsgPid = MDSIFINDPROG_FAILURE Then initForJog = -1: Exit Function
  
  ' get the PLC's PID
  dioMsgPid = mdsiFindProg("isaMsg", Form2.mdsiMacroObj.machineID, vbNullString)
  If dioMsgPid = MDSIFINDPROG_FAILURE Then
    dioMsgPid = mdsiFindProg("dioMsg", Form2.mdsiMacroObj.machineID, vbNullString)
  Else
    initForJog = -1: Exit Function
  End If
  
  ' get the command values for read/write
  ret = mdsiSymNames2Indexes(accMsgPid, sAccNames, sAccI)
  If ret = MDSISYMNAMES2INDEXESVB_FAILURE Then initForJog = -1: Exit Function
  
  ' get values of some fixed system variables
  ' (in this case, the sequencer PIDs)
  ret = mdsiVarNames2IndexesVB(accMsgPid, vAccFixedNames, vAccIFixed, 0)
  If ret = MDSIVARNAMES2INDEXESVB_FAILURE Then initForJog = -1: Exit Function
  ret = mdsiVarIn(accMsgPid, sAccI.VARINDEXREAD, vAccIFixed, vAccFixed, Len(vAccIFixed), Len(vAccFixed))
  If ret = MDSIVARIN_FAILURE Then initForJog = -1: Exit Function


End Function


' Send a jog command to the PLC.  This may be prefered over sending
' a command directly to the sequencer, because the PLC denies requests
' if the machine has not been enabled yet.
' delta:  a negative or positive increment in distance units
' jsAxis: the axis number for our jobstream
' Returns:  True on success, False otherwise
Public Function runJogIncrPLC(delta As Long, jsAxis As Long) As Boolean
  Dim ret As mdsiMacroReturnTypes, retVal As Long
  Dim myLong As Long
  Dim jogMsg As PLCJogMsgType
  'make sure axis is valid for this jobstream
  If (jsAxis < 0) Or (jsAxis >= Form2.mdsiMacroObj.axisCountJS) Then
    runJogIncrPLC = False                  ' parameter out of range
    Exit Function
  End If
  
  ' make sure that the sequencer is empty-- if not empty then abort
  ret = Form2.mdsiMacroObj.mdsiSequencerWaitEmptyVB(1, True, "Cannot jog now")
  If ret <> mdsiMacro_Succeeded Then Exit Function
  
  ret = Form2.mdsiMacroObj.mdsiVariableWriteByNameVB("plcJogType", _
                                               IIf(delta >= 0, JOG_POSITIVE, JOG_NEGATIVE), _
                                               1)
  If ret <> mdsiMacro_Succeeded Then Exit Function
  ret = Form2.mdsiMacroObj.mdsiVariableWriteByNameVB("plcJogDist", _
                                               IIf(delta >= 0, delta, -delta), _
                                               1)
  If ret <> mdsiMacro_Succeeded Then Exit Function
  
  ' set up the jog command message
  jogMsg.systemMsg = DIOM_SYSTEM
  jogMsg.cmd = DIOS_JOG
  jogMsg.direction = IIf(delta >= 0, JOG_POSITIVE, JOG_NEGATIVE)
  jogMsg.axis = jsAxis + Form2.mdsiMacroObj.axisBaseJS
  
  ' send the jog command to the PLC
  retVal = mdsiSend(dioMsgPid, jogMsg, 0, Len(jogMsg), 0)
                    
  runJogIncrPLC = True                  ' success
End Function


' Send a jog command to the sequencer.  Note:  the sequencer does not
' check first that the machine has been enabled, etc.
' delta:  a negative or positive increment in distance units
' jsAxis: the axis number for our jobstream
' Returns:  True on success, False otherwise
Public Function runJogIncrSequencer(delta As Long, jsAxis As Long) As Boolean
  Dim ret As mdsiMacroReturnTypes, retVal As Long
  Dim myLong As Long
  Dim jogMsg As SeqJogMsgType
  'make sure axis is valid for this jobstream
  If (jsAxis < 0) Or (jsAxis >= Form2.mdsiMacroObj.axisCountJS) Then
    runJogIncrSequencer = False                  ' parameter out of range
    Exit Function
  End If
  ' make sure that the sequencer is empty-- if not empty after
  ' one second, then abort
  ret = Form2.mdsiMacroObj.mdsiSequencerWaitEmptyVB(1, True, "Can't stack delta jogs ")
  If ret <> mdsiMacro_Succeeded Then Exit Function
  ' set up the jog command message
  jogMsg.delta = delta
  jogMsg.nLongs = 3
  jogMsg.microCmd = MC_JOG_INC
  ' set bit N for the given axis
  jogMsg.axisBits = 1
  For myLong = 1 To jsAxis
    jogMsg.axisBits = jogMsg.axisBits * 2
  Next myLong
  
  ' send the jog command to the appropriate sequencer
  retVal = mdsiSend(vAccFixed.jsMsgPid(Form2.mdsiMacroObj.jsid), jogMsg, _
                    0, (jogMsg.nLongs + 1) * Len(myLong), 0)
                    
  runJogIncrSequencer = True                  ' success
End Function

' Send a jog command to the PLC.  This may be prefered over sending
' a command directly to the sequencer, because the PLC denies requests
' if the machine has not been enabled yet.
' delta:  a negative or positive increment in distance units
' jsAxis: the axis number for our jobstream
' Returns:  True on success, False otherwise
Public Function runUserMsgPLC(MsgID As Long, arg1 As Long, Optional arg2 As Long, Optional arg3 As Long) As Boolean
  Dim ret As mdsiMacroReturnTypes, retVal As Long
  Dim myLong As Long
  Dim UserMsg As PLCUserMsgType
  
  ' set up the jog command message
  UserMsg.systemMsg = DIOM_USER
  UserMsg.cmd = MsgID
  UserMsg.arg1 = arg1
  UserMsg.arg2 = arg2
  UserMsg.arg3 = arg3
  
  ' send the jog command to the PLC
  retVal = mdsiSend(dioMsgPid, UserMsg, 0, Len(UserMsg), 0)
                    
  runUserMsgPLC = True                  ' success
End Function

  'make sure axis is valid for this jobstream
'  If (jsAxis < 0) Or (jsAxis >= MDSISampleInt.mdsiMacroObj.axisCountJS) Then
'    runJogIncrPLC = False                  ' parameter out of range
'    Exit Function
'  End If
  
  ' make sure that the sequencer is empty-- if not empty then abort
'  ret = MDSISampleInt.mdsiMacroObj.mdsiSequencerWaitEmptyVB(1, True, "Cannot jog now")
'  If ret <> mdsiMacro_Succeeded Then Exit Function
  
'  ret = MDSISampleInt.mdsiMacroObj.mdsiVariableWriteByNameVB("plcJogType", _
                                               IIf(delta >= 0, JOG_POSITIVE, JOG_NEGATIVE), _
                                               1)
'  If ret <> mdsiMacro_Succeeded Then Exit Function
'  ret = MDSISampleInt.mdsiMacroObj.mdsiVariableWriteByNameVB("plcJogDist", _
                                               IIf(delta >= 0, delta, -delta), _
                                               1)
'  If ret <> mdsiMacro_Succeeded Then Exit Function


