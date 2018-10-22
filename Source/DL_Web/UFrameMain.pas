{*******************************************************************************
  作者: dmzn@163.com 2018-06-13
  描述: 用户登录主页面
*******************************************************************************}
unit UFrameMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  uniGUITypes, uniGUIAbstractClasses, uniGUIRegClasses, uniGUIForm, uniGUIFrame,
  Vcl.Menus, uniMainMenu, uniSplitter, uniTreeView, uniMultiItem, uniComboBox,
  uniCheckBox, uniButton, uniGUIClasses, uniMemo, uniPanel, uniPageControl,
  uniLabel, uniImage, Vcl.Controls, uniGUIBaseClasses, uniStatusBar, Vcl.Forms;

type
  TfFrameMain = class(TUniFrame)
    Panel1: TUniSimplePanel;
    PageWork: TUniPageControl;
    SheetWelcome: TUniTabSheet;
    UniPanel1: TUniPanel;
    SheetMemory: TUniTabSheet;
    MemoMemory: TUniMemo;
    UniSimplePanel1: TUniSimplePanel;
    BtnFresh: TUniButton;
    CheckFriendly: TUniCheckBox;
    BtnUpdateMemory: TUniButton;
    PanelLeft: TUniPanel;
    UniSimplePanel3: TUniSimplePanel;
    ComboFactory: TUniComboBox;
    LabelFactory: TUniLabel;
    TreeMenu: TUniTreeView;
    PanelTop: TUniSimplePanel;
    ImageRight: TUniImage;
    ImageLeft: TUniImage;
    LabelHint: TUniLabel;
    StatusBar1: TUniStatusBar;
    UniSplitter1: TUniSplitter;
    PMenu1: TUniPopupMenu;
    N1: TUniMenuItem;
    N2: TUniMenuItem;
    N3: TUniMenuItem;
    procedure UniFrameCreate(Sender: TObject);
    procedure UniFrameDestroy(Sender: TObject);
    procedure BtnUpdateMemoryClick(Sender: TObject);
    procedure BtnFreshClick(Sender: TObject);
    procedure TreeMenuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure ComboFactoryChange(Sender: TObject);
    procedure TreeMenuClick(Sender: TObject);
    procedure PageWorkChange(Sender: TObject);
  private
    { Private declarations }
    procedure LoadFormConfig;
    procedure SaveFormConfig;
    //窗体配置
    procedure TabSheetClose(Sender: TObject; var AllowClose: Boolean);
    //分页关闭
  public
    { Public declarations }
    class procedure ActiveFactory(const nIdx: Integer);
    //设置工厂
  end;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, UManagerGroup, System.IniFiles, USysDB,
  USysBusiness, USysConst;

var
  gMainFrame: TfFrameMain = nil;

//Date: 2018-04-19
//Desc: 初始化窗体配置
procedure TfFrameMain.LoadFormConfig;
var nStr: string;
    nInt: Integer;
    nIni: TIniFile;
begin
  ImageLeft.Url := sImageDir + 'top_left.bmp';
  ImageRight.Url := sImageDir + 'top_right.bmp';

  with UniMainModule.FUserConfig do
  begin
    Caption := FMainTitle;
    LabelHint.Caption := FHintText;

    nStr := '用户:【%s】 来自:【%s】 系统:【%s】 浏览器:【%s】';
    nStr := Format(nStr, [FUserID, FLocalIP, FOSUser, FUserAgent]);
    StatusBar1.SimpleText := nStr;
  end;

  PageWork.ActivePage := SheetWelcome;
  SheetMemory.Visible := UniMainModule.FUserConfig.FIsAdmin;

  GetFactoryList(ComboFactory.Items);
  if ComboFactory.Items.Count > 0 then
    ComboFactory.ItemIndex := 0;
  //default factory

  nIni := nil;
  try
    nIni := UserConfigFile;
    //config object

    nInt := nIni.ReadInteger(ClassName, 'PanelLeft', 200);
    if nInt < 100 then nInt := 100;
    PanelLeft.Width := nInt;

    nInt := nIni.ReadInteger(ClassName, 'FactoryLast', 0);
    if (ComboFactory.ItemIndex >= 0) and (nInt >= 0) then
      ComboFactory.ItemIndex := nInt;
    UniMainModule.FUserConfig.FFactory := ComboFactory.ItemIndex;
  finally
    nIni.Free;
  end;
end;

//Date: 2018-04-27
//Desc: 保存配置
procedure TfFrameMain.SaveFormConfig;
var nIni: TIniFile;
begin
  nIni := nil;
  try
    nIni := UserConfigFile;
    nIni.WriteInteger(ClassName, 'PanelLeft', PanelLeft.Width);
    nIni.WriteInteger(ClassName, 'FactoryLast', ComboFactory.ItemIndex);
  finally
    nIni.Free;
  end;
end;

procedure TfFrameMain.UniFrameCreate(Sender: TObject);
begin
  LoadFormConfig;
  BuidMenuTree(TreeMenu);
  gMainFrame := Self;
end;

procedure TfFrameMain.UniFrameDestroy(Sender: TObject);
begin
  gMainFrame := nil;
  SaveFormConfig;
end;

//------------------------------------------------------------------------------
//Desc: 刷新内存
procedure TfFrameMain.BtnFreshClick(Sender: TObject);
begin
  LoadSystemMemoryStatus(MemoMemory.Lines, CheckFriendly.Checked);
end;

//Desc: 更新内存
procedure TfFrameMain.BtnUpdateMemoryClick(Sender: TObject);
var nStr: string;
begin
  nStr := '服务器将重新加载配置数据,并断开所有连接.' + #13#10 +
          '继续操作请点"是"按钮.';
  MessageDlg(nStr, mtConfirmation, mbYesNo,
    procedure(Sender: TComponent; Res: Integer)
    begin
      if Res = mrYes then ReloadSystemMemory(True);
    end);
  //xxxxx
end;

procedure TfFrameMain.TreeMenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then PMenu1.Popup(X, Y, TreeMenu);
end;

procedure TfFrameMain.N1Click(Sender: TObject);
begin
  TreeMenu.FullExpand;
end;

procedure TfFrameMain.N3Click(Sender: TObject);
begin
  TreeMenu.FullCollapse;
end;

//Desc: 设置当前工厂
class procedure TfFrameMain.ActiveFactory(const nIdx: Integer);
var nInt: Integer;
begin
  if Assigned(gMainFrame) then
  begin
    nInt := gMainFrame.ComboFactory.ItemIndex;
    gMainFrame.ComboFactory.ItemIndex := nIdx;
    if nInt <> nIdx then
      gMainFrame.ComboFactoryChange(nil);
    //xxxxx
  end;
end;

//Desc: 切换工厂
procedure TfFrameMain.ComboFactoryChange(Sender: TObject);
var nStr: string;
    nFactory: TFactoryItem;
begin
  if GetFactory(ComboFactory.ItemIndex, nFactory) then
  begin
    GlobalSyncLock;
    try
      UniMainModule.FUserConfig.FFactory := ComboFactory.ItemIndex;
      //factory index
    finally
      GlobalSyncRelease;
    end;

    with nFactory do
    begin
      nStr := '当前所有业务只针对如下工厂:' + #13#10#13#10 +
              '工厂编号: %s' + #13#10 +
              '工厂名称: %s';
      nStr := Format(nStr, [FFactoryID, FFactoryName]);
      ShowMessage(nStr);
    end;
  end;
end;

procedure TfFrameMain.TreeMenuClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nForm: TUniForm;
    nFrame: TUniFrame;
    nFrameClass: TUniFrameClass;
begin
  if (not Assigned(TreeMenu.Selected)) or
     (TreeMenu.Selected.HasChildren) then Exit;
  nIdx := NativeInt(TreeMenu.Selected.Data);

  nStr := GetMenuItemID(nIdx);
  if nStr = '' then Exit;
  //invalid menu

  with gAllMenus[nIdx],UniMainModule do
  if (FFlag = sMenuArea) and (FPMenu <> '') then //区域菜单项
  begin
    nIdx := Pos('_', FMenuID);
    nStr := Copy(FMenuID, nIdx + 1, Length(FMenuID) - nIdx);

    if not Assigned(FFactoryStatus) then
    begin
      nFrameClass := TUniFrameClass(GetClass('TfFrameFactoryStatus'));
      if not Assigned(nFrameClass) then
      begin
        nStr := 'Frame类[ %s ]无效.';
        ShowMessage(Format(nStr, ['TfFrameFactoryStatus']));
        Exit;
      end;

      FFactoryStatus := TUniTabSheet.Create(Self);
      with FFactoryStatus do
      begin
        Pagecontrol := PageWork;
        Closable := True;
        OnClose := TabSheetClose;
      end;

      nFrame := nFrameClass.Create(Self);
      nFrame.Parent := FFactoryStatus;
      nFrame.Align := alClient;
    end;

    FFactoryStatus.Tag := NativeInt(TreeMenu.Selected);
    FFactoryStatus.Caption := '运行总览 - ' + FTitle;
    PageWork.ActivePage := FFactoryStatus;

    FLoadFactoryStatus(nStr);
    //刷新
    Exit;
  end;

  //----------------------------------------------------------------------------
  for nIdx := Low(UniMainModule.FMenuModule) to High(UniMainModule.FMenuModule) do
  with UniMainModule.FMenuModule[nIdx] do
  begin
    if CompareText(FMenuID, nStr) <> 0 then Continue;
    //not match

    if FItemType = mtForm then
    begin
      nForm := SystemGetForm(FModule);
      if not Assigned(nForm) then
      begin
        nStr := '窗体类[ %s ]无效.';
        ShowMessage(Format(nStr, [FModule]));
        Exit;
      end;

      nForm.ShowModalN;
      //show form
    end else

    if FItemType = mtFrame then
    begin
      if not Assigned(FTabSheet) then
      begin
        nFrameClass := TUniFrameClass(GetClass(FModule));
        if not Assigned(nFrameClass) then
        begin
          nStr := 'Frame类[ %s ]无效.';
          ShowMessage(Format(nStr, [FModule]));
          Exit;
        end;

        FTabSheet := TUniTabSheet.Create(Self);
        with FTabSheet do
        begin
          Pagecontrol := PageWork;
          Caption := TreeMenu.Selected.Text;

          Closable := True;
          OnClose := TabSheetClose;
          Tag := NativeInt(TreeMenu.Selected);
        end;

        nFrame := nFrameClass.Create(Self);
        nFrame.Parent := FTabSheet;
        nFrame.Align := alClient;
      end;

      PageWork.ActivePage := FTabSheet;
      //active
    end;

    Break;
  end;
end;

//Desc: 页面关闭
procedure TfFrameMain.TabSheetClose(Sender: TObject; var AllowClose: Boolean);
var nStr: string;
    nIdx: Integer;
    nNode: TUniTreeNode;
begin
  nNode := Pointer((Sender as TUniTabSheet).Tag);
  if not Assigned(nNode) then Exit;

  if TreeMenu.Selected = nNode then
    TreeMenu.Selected := nil;
  //xxxxx

  nIdx := NativeInt(nNode.Data);
  nStr := GetMenuItemID(nIdx);

  with gAllMenus[nIdx] do
  if (FFlag = sMenuArea) and (FPMenu <> '') then //区域菜单项
  begin
    UniMainModule.FFactoryStatus := nil;
    UniMainModule.FLoadFactoryStatus := nil;
    Exit;
  end;

  for nIdx := Low(UniMainModule.FMenuModule) to High(UniMainModule.FMenuModule) do
  with UniMainModule.FMenuModule[nIdx] do
  begin
    if CompareText(FMenuID, nStr) <> 0 then Continue;
    //not match

    FTabSheet := nil;
  end;

  if (PageWork.PageCount <= 3) and (not UniMainModule.FUserConfig.FIsAdmin) then
    PageWork.ActivePage := SheetWelcome;
  //xxxxx
end;

//Desc: 页面切换
procedure TfFrameMain.PageWorkChange(Sender: TObject);
var nNode: TUniTreeNode;
begin
  if Assigned(PageWork.ActivePage) then
  begin
    nNode := Pointer(PageWork.ActivePage.Tag);
    if Assigned(nNode) then
      TreeMenu.Selected := nNode;
    //xxxxx
  end;
end;

initialization
  RegisterClass(TfFrameMain);
end.
