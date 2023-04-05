#VisualFreeBasic_Form#  Version=5.5.5
Locked=0

[Form]
Name=Form1
ClassStyle=CS_VREDRAW,CS_HREDRAW,CS_DBLCLKS
ClassName=
WinStyle=WS_THICKFRAME,WS_CAPTION,WS_SYSMENU,WS_MINIMIZEBOX,WS_MAXIMIZEBOX,WS_CLIPSIBLINGS,WS_CLIPCHILDREN,WS_VISIBLE,WS_EX_WINDOWEDGE,WS_EX_CONTROLPARENT,WS_EX_LEFT,WS_EX_LTRREADING,WS_EX_RIGHTSCROLLBAR,WS_POPUP,WS_SIZEBOX
Style=3 - 常规窗口
Icon=
Caption=MiniBlink下载演示
StartPosition=1 - 屏幕中心
WindowState=0 - 正常
Enabled=True
Repeat=False
Left=0
Top=0
Width=1122
Height=674
TopMost=False
Child=False
MdiChild=False
TitleBar=True
SizeBox=True
SysMenu=True
MaximizeBox=True
MinimizeBox=True
Help=False
Hscroll=False
Vscroll=False
MinWidth=0
MinHeight=0
MaxWidth=0
MaxHeight=0
NoActivate=False
MousePass=False
TransPer=0
TransColor=SYS,25
Shadow=0 - 无阴影
BackColor=SYS,15
MousePointer=0 - 默认
Tag=
Tab=True
ToolTip=
ToolTipBalloon=False
AcceptFiles=False

[Miniblink]
Name=Miniblink1
Enabled=True
Visible=True
Url=https://yasuo.360.cn
UserAgent=
HighDPI=True
MemCache=False
NewWin=False
CspCheck=True
NpapiPlus=False
Headless=False
JavaScript=True
Left=5
Top=7
Width=1102
Height=631
Layout=5 - 宽度和高度
Tab=True
Tag=


[AllCode]
'这是标准的工程模版，你也可做自己的模版。
'写好工程，复制全部文件到VFB软件文件夹里【template】里即可，子文件夹名为 VFB新建工程里显示的名称
'快去打造属于你自己的工程模版吧。

enum wkeLoadingResult
   WKE_LOADING_SUCCEEDED
   WKE_LOADING_FAILED
   WKE_LOADING_CANCELED
End enum

enum wkeDownloadOpt
   kWkeDownloadOptCancel
   kWkeDownloadOptCacheData
End enum

Type DownInfo 
   FileName As String
   Length As Integer
   Down As Integer  
End Type

Type wkeNetJobDataBind
   param          As Any Ptr
   recvCallback   As Sub cdecl(param As Any Ptr ,job As wkeNetJob ,dataIn As Any Ptr ,length As Integer)
   finishCallback As Sub cdecl(param As Any Ptr ,job As wkeNetJob ,result As wkeLoadingResult)
End Type

Sub wkeNetJobDataRecvCallback cdecl(ByVal param As Any Ptr ,ByVal job As wkeNetJob ,ByVal dataIn As Any Ptr ,ByVal length As Integer)
   Dim d As DownInfo Ptr = param
   Dim dataOut(length) As Byte
   CopyMemory(Varptr(dataOut(0)) ,dataIn ,length)
   Dim f As Integer = FreeFile()
   
   
   Open d->FileName For Binary As #f
      Put #f, LOF(f),dataOut()
   Close #f
   
End Sub
Sub wkeNetJobDataFinishCallback cdecl(ByVal param As Any Ptr ,ByVal job As wkeNetJob ,ByVal result As wkeLoadingResult)
   Dim d As DownInfo Ptr = param
   
   If MsgBox("是否需要打开文件？" ,"下载完成" ,MB_YESNO) = 6 Then
      ShellExecute Me.hWnd, "Open", d->FileName, "", "", 0
   End If
   
   Delete d
End Sub

Function Form1_Miniblink1_Download2(hWndForm As hWnd ,hWndControl As hWnd ,WebView As wkeWebView ,expectedContentLength As size_t ,url As CWSTR ,mime As CWSTR ,disposition As CWSTR ,job As wkeNetJob ,wkeNetJobDataBind As Any Ptr) As BOOL '页面下载事件。点击某些链接，触发下载会调用 
   Dim strFileName As String = ""
   If Len(disposition) > 0 Then
      strFileName = GetStrCenter(disposition ,"filename=""" ,"""")
   End If
   
   Dim nIndex As Integer
   If Len(strFileName) <= 0 Then
      nIndex = InStrRev(url ,"/")
      If nIndex > 0 Then
         Dim nQuery As Integer = InStr(nIndex ,url ,"?")
         If nQuery > 0 Then
            strFileName = Mid(url ,nIndex + 1 ,nQuery - nIndex - 1)
         Else
            strFileName = Mid(url, nIndex + 1)
         End If
      End If
   End If
   Dim strSaveFileName As String = FF_SaveFileDialog(hWndForm , "下载保存", strFileName, "", "所有的文件 (*.*)|*.*")
   If strSaveFileName = "" Then
      Function = 0
      Exit Function 
   End If
   
   nIndex = InStr(strSaveFileName ,"|")
   If nIndex > 0 Then
      strSaveFileName = Left(strSaveFileName, nIndex - 1)
   End If
 
   If FileExists(strSaveFileName) Then
      If MsgBox("文件已经存在，是否覆盖？" ,"文件覆盖提示" ,MB_YESNO) = 7 Then
         Function = 0 
         Exit Function
      End If
   End If
   
   Static d As DownInfo
   d.FileName = strSaveFileName
   d.Length = expectedContentLength
   d.Down = 0
   
   Static t As wkeNetJobDataBind
   t.param          = Varptr(d)
   t.finishCallback = @wkeNetJobDataFinishCallback
   t.recvCallback   = @wkeNetJobDataRecvCallback
   MoveMemory(wkeNetJobDataBind ,Varptr(t) ,Len(t))
   Function = 1
End Function




