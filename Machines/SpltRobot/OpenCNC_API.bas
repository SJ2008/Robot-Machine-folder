Attribute VB_Name = "OpenCNC_API"
'**************************************************************************
'* OpenCNC(R)
'* Copyright 1993-2001 by
'* Manufacturing Data Systems, Inc.(R)
'* All rights reserved.
'* http://www.mdsi2.com
'*
'* DOC $Id: OpenCNC_API.bas,v 1.51 2001/01/16 00:13:21 ewp Exp $
'* $Log: OpenCNC_API.bas,v $
'* Revision 1.51  2001/01/16 00:13:21  ewp
'* Updated copyright to 2001.
'*
'* Revision 1.50  2000/11/29 21:05:20  ewp
'* Changes for MDI as mode, added MODE_MDI.
'*
'* Revision 1.49  2000/11/10 16:36:36  jdg
'* Added min/max constant for orientation offsets.
'*
'* Revision 1.48  2000/09/15 12:50:15  etlarson
'* Make second argument optional for mdsiCloseMsg for compatibility.
'*
'* Revision 1.47  2000/09/13 20:50:12  jdg
'* Made the 'msg' argument to mdsiReceive and mdsiReply 'ByRef'.  Swapped
'* argument names in mdsiSignal.  Added a 2nd argument to mdsiCloseMsg.
'* Added mdsiProgramRemove.
'*
'* Revision 1.46  2000/09/07 19:58:12  etlarson
'* Add argument to mdsiCloseMsg to clear program name to help support
'* program cleanup for VB scripting.
'*
'* Revision 1.45  2000/07/14 14:23:31  jdg
'* Expanded language constants.
'*
'* Revision 1.44  2000/07/10 13:02:00  jdg
'* Added VARNAME_MAX, mdsiShmClose
'*
'* Revision 1.43  2000/06/08 13:10:50  jdg
'* Added constant for max # of user defined macros.
'*
'* Revision 1.42  2000/04/13 14:09:15  jdg
'* Added PRMAX.
'*
'* Revision 1.41  2000/03/07 16:05:06  jdg
'* Changed LBMAX to 10000, added LBDEFAULT (= 100)
'*
'* Revision 1.40  2000/02/07 19:49:59  jdg
'* Added def for LBMAX.
'*
'* Revision 1.39  2000/02/07 19:02:44  ewp
'* Removed old log messages from header.
'*
'* Revision 1.38  2000/01/27 22:47:10  ewp
'* Updated copyright.
'*
'* Revision 1.37  1999/10/15 14:38:09  jdg
'* Added constants for jog mode, run mode, etc.  (Copied from the .h file.)
'*
'* Revision 1.36  1999/10/14 21:34:21  jdg
'* Changed comment from "job stream" to "spindles".
'*
'* Revision 1.35  1999/10/06 20:08:50  jdg
'* Added an mdsiGetVersion function to the OpenCNC API.  Use it in the
'* "about" class to get the most up-to-date product name and version.
'*
'* Revision 1.34  1999/10/05 19:42:28  jdg
'* Added declare for API function mdsiPrintMsg.
'* Added declare for new API function mdsiVarBitSetReset().
'*
'* Revision 1.33  1999/09/27 13:38:59  jdg
'* Removed MAX_ENC and MAX_DAC; it turns out that "dac..." and "enc..."
'* variables are dynamically sized at run time, not fixed size.
'*
'* Revision 1.32  1999/09/24 21:43:12  jdg
'* Added mdsiSignal, MAX_DAC, MAX_ENC.
'*
'* Revision 1.31  1999/09/13 13:09:57  jdg
'* Added EGMAX, SPMAX.
'*
'* Revision 1.30  1999/08/31 13:49:44  jdg
'* Added constant MDSIVARREGISTER_FAILURE.
'* Added declaration for mdsiVariableRegisterVB.
'*
'* Revision 1.29  1999/08/19 16:15:22  etlarson
'* Remove mdsiErrno.
'*
'* Revision 1.28  1999/08/11 13:26:19  jdg
'* Modified declaration of mdsiShmOpen for use with winFeShow (VB).
'*
'* Revision 1.27  1999/08/10 22:14:01  ewp
'* Removed log entry containing CVS Log keyword (again).
'*
'* Revision 1.26  1999/08/05 13:53:55  jdg
'* Corrected declaration for mdsiVarNames2Ptrs.  Added declarations for
'* mdsiShmOpen and mdsiNotifyParent.
'*
'**************************************************************************


'Start of OpenCNC API constant declarations

Public Const JSMAX = 8         'max job streams
Public Const AXMAX = 10        'max axes
Public Const EGMAX = 5      'maximum number of electronic gears allowed
Public Const SPMAX = 8      'maximum number of spindles
Public Const LONG_MAX As Long = 2147483647
Public Const LONG_MIN As Long = -2147483647
Public Const LBDEFAULT As Long = 100
Public Const LBMAX As Long = 10000
Public Const PRMAX As Long = 4 ' number of special proxies (size of mSpecialProxys[])
Public Const DEFGMACRO_MAX As Long = 25  'maximum of user defined macro G codes
Public Const VARNAME_MAX As Long = 20    ' max length of an OpenCNC variable name
Public Const MIN_TOOL_ORIENTATION As Long = 0  ' minimum value for tool orientation
Public Const MAX_TOOL_ORIENTATION As Long = 9  ' maximum value for tool orientation

' values for OpenCNC variable mRunMode
Public Const MODE_JOG As Long = 0
Public Const MODE_RUN As Long = 1
Public Const MODE_RETRACE  As Long = 2
Public Const MODE_WITHDRAW  As Long = 3
Public Const MODE_AUTOWDRAW  As Long = 4
Public Const MODE_MDI As Long = 5


  'colors
Public Const OpenCNC_LIGHTRED = &H5F5FFF
Public Const OpenCNC_LIGHTGREEN = &H5FBF00
Public Const OpenCNC_BLACK = &H0&
Public Const OpenCNC_LIGHTGRAY = &HBFBFBF
Public Const OpenCNC_DARKGRAY = &H3F3F3F
Public Const OpenCNC_WHITE = &HFFFFFF
Public Const OpenCNC_DARKGREEN = &H7F00&
Public Const OpenCNC_GREEN = &HFF00&
Public Const OpenCNC_LIGHTYELLOW = &H7FFFFF
Public Const OpenCNC_YELLOW = &HFFFF&
Public Const OpenCNC_OFFWHITE = &HBFE0FF
Public Const OpenCNC_VIOLET = &HFF7FFF
Public Const OpenCNC_RED = &HFF&
Public Const OpenCNC_BLUE = &HFF0000
Public Const OpenCNC_LIGHTBLUE = &HFF7F7F

Public Const SIGINT = 2
Public Const SIGTERM = 15
Public Const SIGHUP = 22
Public Const SIG_DFL = 0
Public Const SIG_IGN = 1

  'OpenCNC API return codes
Public Const MDSICLOSE_FAILURE = -1  'return code if mdsiOpen fails
Public Const MDSIFINDPROG_FAILURE = 0 '
Public Const MDSIOPEN_FAILURE = -1  'return code if mdsiOpen fails
Public Const MDSIREPLY_FAILURE = -1 '
Public Const MDSISEND_FAILURE = -1 '
Public Const MDSISYMNAMES2INDEXESVB_FAILURE = -1 '
Public Const MDSISYMREGISTERVB_FAILURE = -1 '
Public Const MDSIVARIN_FAILURE = -1 '
Public Const MDSIVARNAMES2INDEXESVB_FAILURE = -1 '
Public Const MDSIVAROUT_FAILURE = -1 '
Public Const MDSIVARREGISTER_FAILURE = -1

  'language IDs (no connection to Windows(tm) language IDs)
Public Enum languageIDType
  englishOffset = 0
  lastEnglishMsg = 1999
  germanOffset = 2000
  lastGermanMsg = 3999
  lastLanguageType = 4000
End Enum

'End of OpenCNC API constant declarations


'Start of OpenCNC API type declarations
'End of OpenCNC API type declarations


'Start of OpenCNC API function declarations

Public Declare Function mdsiOpen Lib "OpenCNC_api.dll" Alias "_mdsiOpen@8" (ByVal mid As Long, ByVal name As String) As Long
Public Declare Function mdsiClose Lib "OpenCNC_api.dll" Alias "_mdsiClose@0" () As Long

Public Declare Function mdsiFindProg Lib "OpenCNC_api.dll" Alias "_mdsiFindProg@12" (ByVal name$, ByVal mid As Long, ByVal buffer As Any) As Long

Public Declare Function mdsiSymNames2IndexesVB Lib "OpenCNC_api.dll" Alias "_mdsiSymNames2IndexesVB@12" (ByVal mPid As Long, ByVal p As String, OpensAccI As Any) As Long
  'Note:  mdsiSymNames2Indexes is an obsolete name; mdsiSymNames2IndexesVB is prefered.
Public Declare Function mdsiSymNames2Indexes Lib "OpenCNC_api.dll" Alias "_mdsiSymNames2IndexesVB@12" (ByVal mPid As Long, ByVal p As String, OpensAccI As Any) As Long

Public Declare Function mdsiVarIn Lib "OpenCNC_api.dll" Alias "_mdsiVarIn@24" (ByVal mPid As Long, ByVal mMsg As Long, sendMsg As Any, retMsg As Any, ByVal senLen As Long, ByVal retLen As Long) As Long
Public Declare Function mdsiVarOut Lib "OpenCNC_api.dll" Alias "_mdsiVarOut@20" (ByVal mPid As Long, ByVal mMsg As Long, ByVal wIndex As Long, vAddr As Any, ByVal vLen As Long) As Long

Public Declare Function mdsiSymRegisterVB Lib "OpenCNC_api.dll" Alias "_mdsiSymRegisterVB@12" (ByVal mPid As Long, ByVal symname As String, ByVal symValue As Long) As Long
  'Note:  mdsiSymRegister is an obsolete name; mdsiSymRegisterVB is prefered.
Public Declare Function mdsiSymRegister Lib "OpenCNC_api.dll" Alias "_mdsiSymRegisterVB@12" (ByVal mPid As Long, ByVal symname As String, ByVal symValue As Long) As Long

Public Declare Function mdsiVarNames2IndexesVB Lib "OpenCNC_api.dll" Alias "_mdsiVarNames2IndexesVB@16" (ByVal mPid As Long, ByVal table As String, indexes As Any, ByVal jid As Long) As Long
  'Note:  mdsiVarNames2Indexes is an obsolete name;  mdsiVarNames2IndexesVB is prefered.
Public Declare Function mdsiVarNames2Indexes Lib "OpenCNC_api.dll" Alias "_mdsiVarNames2IndexesVB@16" (ByVal mPid As Long, ByVal table As String, indexes As Any, ByVal jid As Long) As Long

Public Declare Function mdsiGetProxy Lib "OpenCNC_api.dll" Alias "_mdsiGetProxy@0" () As Long
Public Declare Function mdsiStartIntTimer Lib "OpenCNC_api.dll" Alias "_mdsiStartIntTimer@20" (ByVal proxy As Long, ByVal firstSec As Long, ByVal firstNSec As Long, ByVal nextSec As Long, ByVal nextNSec As Long) As Long
Public Declare Function mdsiVarRegister Lib "OpenCNC_api.dll" Alias "_mdsiVarRegister@12" (ByVal mPid As Long, ByVal varName As Long, ByVal jid As Long) As Long
Public Declare Function mdsiVariableRegisterVB Lib "OpenCNC_api.dll" Alias "_mdsiVarRegisterVB@12" (ByVal mPid As Long, ByVal varSetTab As Long, ByVal jid As Long) As Long
Public Declare Function mdsiVarNames2Ptrs Lib "OpenCNC_api.dll" Alias "_mdsiVarNames2Ptrs@20" (ByVal mPid As Long, table As Any, ptr As Any, ByVal jid As Long, shmPtr As Long) As Long

Public Declare Function mdsiCreceive Lib "OpenCNC_api.dll" Alias "_mdsiCreceive@12" (ByVal mPid As Long, ByRef msg As Any, ByVal nbytes As Long) As Long
Public Declare Function mdsiReceive Lib "OpenCNC_api.dll" Alias "_mdsiReceive@12" (ByVal mPid As Long, ByRef msg As Any, ByVal nbytes As Long) As Long
Public Declare Function mdsiReadMsg Lib "OpenCNC_api.dll" Alias "_mdsiReadMsg@16" (ByVal mPid As Long, ByVal offset As Long, ByRef msg As Any, ByVal nbytes As Long) As Long
Public Declare Function mdsiReply Lib "OpenCNC_api.dll" Alias "_mdsiReply@12" (ByVal mPid As Long, ByRef msg As Any, ByVal nbytes As Long) As Long
Public Declare Function mdsiSend Lib "OpenCNC_api.dll" Alias "_mdsiSend@20" (ByVal pid As Long, smsg As Any, rmsg As Any, ByVal snbytes As Long, ByVal rnbytes As Long) As Long
Public Declare Function mdsiTrigger Lib "OpenCNC_api.dll" Alias "_mdsiTrigger@4" (ByVal mPid As Long) As Long
Public Declare Function mdsiGetPriority Lib "OpenCNC_api.dll" Alias "_mdsiGetPriority@0" () As Long
Public Declare Function mdsiSetPriority Lib "OpenCNC_api.dll" Alias "_mdsiSetPriority@4" (ByVal prio As Long) As Long
Public Declare Function mdsiSignalWindow Lib "OpenCNC_api.dll" Alias "_mdsiSignalWindow@8" (ByVal sig As Long, ByVal hwnd As Long) As Long
Public Declare Function mdsiSignalOnExit Lib "OpenCNC_api.dll" Alias "_mdsiSignalOnExit@8" (ByVal sig As Long, ByVal pid As Long) As Long
Public Declare Function mdsiSignal Lib "OpenCNC_api.dll" Alias "_mdsiSignal@8" (ByVal signo As Long, ByVal func As Long) As Long

Public Declare Sub mdsiPutWindowMsg Lib "OpenCNC_api.dll" Alias "_mdsiPutWindowMsg@8" (ByVal prgName As String, ByVal msg As String)
Public Declare Sub mdsiPutSevMsg Lib "OpenCNC_api.dll" Alias "_mdsiPutSevMsg@8" (ByVal prgName As String, ByVal msg As String)

Public Declare Function mdsiResetSequenceLookAhead Lib "OpenCNC_api.dll" Alias "_mdsiResetSequenceLookAhead@4" (ByVal js As Long) As Long

Public Declare Function mdsiStartProcess Lib "OpenCNC_api.dll" Alias "_mdsiStartProcess@20" (ByVal mode As Long, ByVal pgm As String, argv As Long, handle As Long, notifyPid As Long) As Long
Public Declare Function mdsiCreateProcess Lib "OpenCNC_api.dll" Alias "_mdsiCreateProcess@12" (ByVal mode As Long, ByVal pgm As String, argv As Long) As Long
Public Declare Function mdsiProgramInfo Lib "OpenCNC_api.dll" Alias "_mdsiProgramInfo@16" (ByVal programId As Long, ByRef programName As String, _
                                                                                           ByRef pid As Long, ByRef nodeName As String) As Long
Public Declare Function mdsiCloseMsg Lib "OpenCNC_api.dll" Alias "_mdsiCloseMsg@8" (ByVal pid As Long, Optional ByVal clear As Long = 0) As Long
Public Declare Function mdsiProgramLookup Lib "OpenCNC_api.dll" Alias "_mdsiProgramLookup@8" (ByVal nodeId As Long, ByVal programName As String) As Long
Public Declare Function mdsiProgramDefine Lib "OpenCNC_api.dll" Alias "_mdsiProgramDefine@4" (ByVal name As String) As Long
Public Declare Function mdsiProgramRemove Lib "OpenCNC_api.dll" Alias "_mdsiProgramRemove@8" (ByVal nodeId As Long, ByVal programName As String) As Long

Public Declare Function mdsiProgramRunning Lib "OpenCNC_api.dll" Alias "_mdsiProgramRunning@4" (ByVal pid As Long) As Long
Public Declare Function mdsiSendSignal Lib "OpenCNC_api.dll" Alias "_mdsiSendSignal@8" (ByVal pid As Long, ByVal sig As Long) As Long

Public Declare Function mdsiShmOpen Lib "OpenCNC_api.dll" Alias "_mdsiShmOpen@20" (ByVal name As String, ByVal mid As Long, ByVal length As Long, shmFd As Long, ByVal shmPtr As Long) As Long
Public Declare Sub mdsiShmClose Lib "OpenCNC_api.dll" Alias "_mdsiShmClose@12" (ByVal shmFd As Long, ByVal name As String, ByVal mid As Long)

Public Declare Function mdsiNotifyParent Lib "OpenCNC_api.dll" Alias "_mdsiNotifyParent@4" (notifyPid As Long) As Long

Public Declare Function mdsiVarBitSetReset Lib "OpenCNC_api.dll" Alias _
  "_mdsiVarBitSetReset@28" (ByVal pid As Long, ByVal cmd As Long, _
                            ByVal mask As Long, _
                            sendMsg As Any, retMsg As Any, _
                            ByVal sendLen As Long, ByVal retLen As Long) As Long

Public Declare Sub mdsiPrintMsg Lib "OpenCNC_api.dll" _
  (ByVal prgName As String, ByVal pkgNum As Long, _
   ByVal msgNum As Long, ByVal msgStr As String)

Public Declare Function mdsiGetVersion Lib "OpenCNC_api.dll" Alias _
  "_mdsiGetVersion@16" (ByVal sVersion As Long, ByRef lVersion As Long, _
                        ByVal sProduct As Long, ByRef lProduct As Long) As Long


'End of OpenCNC API function declarations


